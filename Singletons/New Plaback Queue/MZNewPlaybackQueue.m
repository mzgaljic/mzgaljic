//
//  MZNewPlaybackQueue.m
//  Sterrio
//
//  Created by Mark Zgaljic on 6/23/16.
//  Copyright © 2016 Mark Zgaljic Apps. All rights reserved.
//

#import "MZNewPlaybackQueue.h"
#import "PlaylistItem.h"
#import "CoreDataManager.h"
#import "MZArrayShuffler.h"
#import "Queue.h"
#import "UpNextItem.h"
#import "NowPlaying.h"


@interface MZNewPlaybackQueue ()
@property (nonatomic, strong) PlaybackContext *mainContext;
@property (nonatomic, strong) MZEnumerator *mainEnumerator;
@property (nonatomic, strong) MZEnumerator *shuffledMainEnumerator;
@property (nonatomic, assign) BOOL usedUpNextQueueInsteadOfMainOrShuffledEnumerator;

//Note: user can never go 'back'. Tapping 'back' would take you to the previous song in the mainEnumerator
//(or main shuffled enumerator.)

//queue of UpNextItem objs. The current UpNextItem is at the head of the queue. UpNextItem objs are
//de-queued as they are used. Be VERY careful to not use .count on upNextQueue...it's usually not what
//you want. See the helper method 'upNextSongsCount' instead.
@property (nonatomic, strong) Queue *upNextQueue;
@property (nonatomic, weak) UpNextItem *lastTouchedUpNextItem;

//helps when the shuffle state changes.
@property (nonatomic, strong) MZEnumerator *lastUsedEnumerator;

@property (nonatomic, strong) PlayableItem *mostRecentItem;
@end
@implementation MZNewPlaybackQueue

short const INTERNAL_FETCH_BATCH_SIZE = 5;
short const EXTERNAL_FETCH_BATCH_SIZE = 150;


static id sharedNewPlaybackQueueInstance = nil;
+ (instancetype)sharedInstance
{
    return sharedNewPlaybackQueueInstance;
}

+ (void)discardInstance
{
    sharedNewPlaybackQueueInstance = nil;
}

+ (instancetype)newInstanceWithSongsQueuedOnTheFly:(PlaybackContext *)context
{
    sharedNewPlaybackQueueInstance = nil;
    sharedNewPlaybackQueueInstance = [[MZNewPlaybackQueue alloc] initWithSongsQueuedOnTheFly:context];
    return sharedNewPlaybackQueueInstance;
}

+ (instancetype)newInstanceWithNewNowPlayingPlayableItem:(PlayableItem *)item
{
    sharedNewPlaybackQueueInstance = nil;
    sharedNewPlaybackQueueInstance = [[MZNewPlaybackQueue alloc] initWithNewNowPlayingPlayableItem:item];
    return sharedNewPlaybackQueueInstance;
}

//private init
- (id)initWithSongsQueuedOnTheFly:(PlaybackContext *)context
{
    if(self = [super init]) {
        _upNextQueue = [[Queue alloc] init];
        [self queueSongsOnTheFlyWithContext:context];
        _mainContext = nil;  //main context should be nil here!
        if(_upNextQueue.count > 0) {
            UpNextItem *upNextItem = [_upNextQueue peek];
            id obj = [[upNextItem enumeratorForContext] currentObject];
            
            _mostRecentItem = [MZNewPlaybackQueue wrapAsPlayableItem:obj context:context queuedSong:YES];
            _lastTouchedUpNextItem = upNextItem;
        }
        _shuffleState = SHUFFLE_STATE_Disabled;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[CoreDataManager context]];
    }
    return self;
}

//private init
- (id)initWithNewNowPlayingPlayableItem:(PlayableItem *)item
{
    if(self = [super init]) {
        _upNextQueue = [[Queue alloc] init];
        _mainContext = item.contextForItem;
        _mostRecentItem = item;
        _shuffleState = SHUFFLE_STATE_Disabled;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[CoreDataManager context]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _mainContext = nil;
    _mainEnumerator = nil;
    _shuffledMainEnumerator = nil;
    _mostRecentItem = nil;
}

/** 
 Attempt to get the new index of the now-playing-song within the results (if they changed after the context 
 was saved.) Then, re-initialize the mainEnumerator so it doesn't get out of sync with the latest changes by 
 the user. 
 */
- (void)managedObjectContextDidSave:(NSNotification *)note
{
    //can no longer trust that the array in memory is reflecting what the user saved into the library.
    //Re-fetch & get current index.
    NSArray *results = [MZNewPlaybackQueue attemptFetchRequest:_mainContext.request batchSize:INTERNAL_FETCH_BATCH_SIZE];
    if(results != nil) {
        //should point to now playing within the new results (or NSNotFound)
        NSUInteger nowPlayingIndex = [self computeNowPlayingIndexInCoreDataArray:&results];
        if(nowPlayingIndex != NSNotFound) {
            _mainEnumerator = [results biDirectionalEnumeratorAtIndex:nowPlayingIndex
                                             withOutOfBoundsTolerance:1];
        }
    }
    
    if(_shuffledMainEnumerator != nil) {
        _shuffledMainEnumerator = nil;
        //shuffle mode is active. Now that the main enumerator has been refetched, lets shuffle it and
        //keep the cursor pointing to the same NowPlayingItem.
        [self reshuffleShuffledEnumeratorUsingMainEnumerator];
    }
}

- (MZPlaybackQueueSnapshot *)snapshotOfPlaybackQueue
{
#warning still need to get history items.
    NSArray *historyItems = @[];
    
    NSMutableArray *upNextQueueItems = [NSMutableArray array];
    for(UpNextItem *item in [_upNextQueue allQueueObjectsAsArray]) {
        NSArray *enumeratorsArray = [[item enumeratorForContext] underlyingArray];
        for(int i = 0 ; i < enumeratorsArray.count; i++) {
            if(i == 0 && [self initializeAndGetCurrentEnumeratorIfPossible] == nil) {
                //the first item in the up-next queue is actually the now playing item. Don't add it to the
                //upNextQueueItems array!
                continue;
            }
            id obj = enumeratorsArray[i];
            PlayableItem *playableItem = [MZNewPlaybackQueue wrapAsPlayableItem:obj
                                                                        context:item.context
                                                                     queuedSong:YES];
            [upNextQueueItems addObject:playableItem];
        }
    }
    
    NSMutableArray *unplayedCurrentEnumeratorItems;
    MZEnumerator *currentEnumerator = [self initializeAndGetCurrentEnumeratorIfPossible];
    if(currentEnumerator == nil) {
        unplayedCurrentEnumeratorItems = [NSMutableArray array];
    } else {
        NSArray *enumeratorsArray = [currentEnumerator underlyingArray];
        if(currentEnumerator.hasNext) {
            NSUInteger nextObjIndex = [currentEnumerator indexOfCurrentObjectInSourceArray] + 1;
            NSUInteger rangeLength = enumeratorsArray.count - nextObjIndex;
            unplayedCurrentEnumeratorItems = [NSMutableArray arrayWithCapacity:rangeLength];
            NSRange unplayedMainOrShuffledObjsRange = NSMakeRange(nextObjIndex, rangeLength);
            NSArray *unplayedObjs = [enumeratorsArray subarrayWithRange:unplayedMainOrShuffledObjsRange];
            for(id obj in unplayedObjs) {
                //Reminder: Main AND shuffled enumerators both originate from _mainContext.
                PlayableItem *playableItem = [MZNewPlaybackQueue wrapAsPlayableItem:obj
                                                                            context:_mainContext
                                                                         queuedSong:NO];
                [unplayedCurrentEnumeratorItems addObject:playableItem];
            }
        }
    }
    
    PlayableItem *nowPlayingItem = [[NowPlaying sharedInstance] playableItem];
    
    //added 1 for 'now playing'. Look at the order the capacity is computed if you forget how the contents
    //are organized in the 'items' array.
    NSMutableArray<PlayableItem*> *items = [NSMutableArray arrayWithCapacity:historyItems.count + 1 + upNextQueueItems.count + unplayedCurrentEnumeratorItems.count];
    [items addObjectsFromArray:historyItems];
    if(nowPlayingItem != nil) {
        //is nil if the snapshot is built after the last song in the queue ends.
        [items addObject:nowPlayingItem];
    }
    [items addObjectsFromArray:upNextQueueItems];
    [items addObjectsFromArray:unplayedCurrentEnumeratorItems];
    
    NSRange historyItemsRange;
    if(historyItems.count == 0) {
        historyItemsRange = NSMakeRange(NSNotFound, 0);
    } else {
        historyItemsRange = NSMakeRange(0, historyItems.count);
    }
    NSUInteger nowPlayingIndex = (nowPlayingItem == nil) ? NSNotFound : historyItems.count;
    NSRange upNextQueuedItemsRange;
    if(upNextQueueItems.count == 0) {
        upNextQueuedItemsRange = NSMakeRange(NSNotFound, 0);
    } else {
        upNextQueuedItemsRange = NSMakeRange(historyItems.count + 1, upNextQueueItems.count);
    }
    //'future' means future songs in the main/shuffled enumerator. NOT the up-next-queue.
    NSRange futureItemsRange;
    if(unplayedCurrentEnumeratorItems.count == 0) {
        futureItemsRange = NSMakeRange(NSNotFound, 0);
    } else if(upNextQueueItems.count == 0) {
        futureItemsRange = NSMakeRange(historyItems.count + 1, unplayedCurrentEnumeratorItems.count);
    } else {
        futureItemsRange = NSMakeRange(upNextQueuedItemsRange.location + upNextQueuedItemsRange.length, unplayedCurrentEnumeratorItems.count);
    }
    MZPlaybackQueueSnapshot *snapshot;
    snapshot = [[MZPlaybackQueueSnapshot alloc] initQueueSnapshotWithItems:items
                                                       rangeOfHistoryItems:historyItemsRange
                                                           nowPlayingIndex:nowPlayingIndex
                                                  rangeOfUpNextQueuedItems:upNextQueuedItemsRange
                                                     rangeOfAllFutureItems:futureItemsRange];
    return snapshot;
}

- (PlayableItem *)currentItem
{
    return _mostRecentItem;
}

- (PlayableItem *)seekBackOneItem
{
    _mostRecentItem = [self seekNextItemInDirection:SeekBackwards];
    return _mostRecentItem;
}
- (PlayableItem *)seekForwardOneItem
{
    _mostRecentItem = [self seekNextItemInDirection:SeekForward];
    return _mostRecentItem;
}

- (PlayableItem *)seekBy:(NSUInteger)value inDirection:(SeekDirection)direction
{
    if(value <= 0) {
        return nil;
    }
    
    NSUInteger upNextSongsCount = [self upNextSongsCount];
    if(value > upNextSongsCount) {
        value -= upNextSongsCount;
        MZEnumerator *enumerator = [self initializeAndGetCurrentEnumeratorIfPossible];
        if(enumerator != nil) {
            CursorDirection cursorDirection = (direction == SeekForward) ? CursorForward : CursorBackwards;
            id obj = [enumerator moveCursor:value direction:cursorDirection];
            if(obj != nil) {
                return [MZNewPlaybackQueue wrapAsPlayableItem:obj context:_mainContext queuedSong:NO];
            }
        }
        return nil;
    } else {
        #warning make this more efficient! Refactor the up-next items logic in seekNextItemInDirection to easily jump x amount in the up-next-items queue. Instead of 1 at a time...
        PlayableItem *item = nil;
        for(int i = 0; i < value; i++) {
            item = [self seekForwardOneItem];
        }
        return item;
    }
}

- (PlayableItem *)seekToFirstItemInMainQueueAndReshuffleIfNeeded
{
    if(_mainContext == nil || _mainContext.request == nil) {
        return nil;
    }
    
    //toggle shuffle state to trigger a re-shuffle (if shuffle was on to begin with)
    if(_shuffleState == SHUFFLE_STATE_Enabled) {
        [self setShuffleState:SHUFFLE_STATE_Disabled];
        [self setShuffleState:SHUFFLE_STATE_Enabled];
    }
    if(_mainEnumerator == nil) {
        NSArray *results = [MZNewPlaybackQueue attemptFetchRequest:_mainContext.request
                                                         batchSize:INTERNAL_FETCH_BATCH_SIZE];
        if(results != nil) {
            _mainEnumerator = [MZNewPlaybackQueue buildEnumeratorFromArray:&results
                                                  withCursorPointingToItem:_mostRecentItem
                                                      outOfBoundsTolerance:1];
        }
    }
    if(_mainEnumerator != nil) {
        id firstObj = [_mainEnumerator moveTofirstObject];
        return [MZNewPlaybackQueue wrapAsPlayableItem:firstObj
                                              context:_mainContext
                                           queuedSong:NO];
    }
    return nil;
}

//Queues the stuff described by PlaybackContext to the playback queue.
- (void)queueSongsOnTheFlyWithContext:(PlaybackContext *)context
{
    NSArray *results = [MZNewPlaybackQueue attemptFetchRequest:context.request
                                                     batchSize:INTERNAL_FETCH_BATCH_SIZE];
    if(results != nil && results.count > 0) {
        MZEnumerator *enumeratorForContext = [MZNewPlaybackQueue buildEnumeratorFromArray:&results
                                                                 withCursorPointingToItem:nil
                                                                     outOfBoundsTolerance:0];
        [_upNextQueue enqueue:[[UpNextItem alloc]initWithContext:context enumerator:enumeratorForContext]];
    }
}

//# of PlayableItem's that still need to play (includes main context and stuff queued by user on the fly.
- (NSUInteger)forwardItemsCount
{
    NSUInteger count = 0;
    MZEnumerator *enumerator = [self initializeAndGetCurrentEnumeratorIfPossible];
    count += [enumerator numberMoreObjects];
    count += [self upNextSongsCount];
    return count;
}

- (NSUInteger)totalItemsCount
{
    NSUInteger count = 0;
    MZEnumerator *enumerator = [self initializeAndGetCurrentEnumeratorIfPossible];
    count += enumerator.count;
    count += [self upNextSongsCount];
    return count;
}

- (void)setShuffleState:(SHUFFLE_STATE)state
{
    SHUFFLE_STATE prevShuffleState = _shuffleState;
    if(state == prevShuffleState) {
        return;
    }
    _shuffleState = state;
    //some setup since mainEnumerator is used in a few lines...
    if(_mainEnumerator == nil) {
        NSArray *results = [MZNewPlaybackQueue attemptFetchRequest:_mainContext.request
                                                         batchSize:INTERNAL_FETCH_BATCH_SIZE];
        if(results != nil) {
            _mainEnumerator = [MZNewPlaybackQueue buildEnumeratorFromArray:&results
                                                  withCursorPointingToItem:_mostRecentItem
                                                      outOfBoundsTolerance:1];
        }
    }
    
    if(_shuffleState == SHUFFLE_STATE_Enabled) {
        if(_shuffledMainEnumerator == nil) {
            [self reshuffleShuffledEnumeratorUsingMainEnumerator];
        }
    } else if(_shuffleState == SHUFFLE_STATE_Disabled) {
        //logic to get the same item in the unshuffled array now...
        NSArray *rawArray = [_mainEnumerator underlyingArray];
        NSUInteger nowPlayingIndex = [self computeNowPlayingIndexInCoreDataArray:&rawArray];
        if(nowPlayingIndex != NSNotFound) {
            _mainEnumerator = [rawArray biDirectionalEnumeratorAtIndex:nowPlayingIndex
                                             withOutOfBoundsTolerance:1];
        } else {
            //fallback for when something bad happens lol.
            _mainEnumerator = [rawArray biDirectionalEnumerator];
        }
        _shuffledMainEnumerator = nil;
    }
}

#pragma mark - DEBUG
//prints the queue contents and class info.
- (NSString *)description;
{
    //MZEnumerator performs a somewhat shallow copy. Everything is copied except for the underlying array.
    //(so a mod to an object in enumerator A will change it in enumerator B.)
    MZEnumerator *enumeratorCopy = [[self initializeAndGetCurrentEnumeratorIfPossible] copy];

    NSMutableString *output = [NSMutableString string];
    [output appendString:@"---Playback Queue State---\n"];
    if(enumeratorCopy != nil) {
        PlayableItem *nowPlaying = [enumeratorCopy currentObject];
        [output appendFormat:@"-> Now Playing: %@", nowPlaying];
        
        int queuedSongCount = 0;
        if(queuedSongCount) {
            [output appendString:@"-> Queued 'on the fly' songs:"];
            NSArray *queuedObjs = [_upNextQueue allQueueObjectsAsArray];
            for(int i = 0; i < queuedObjs.count; i++) {
                UpNextItem *upNextItem = queuedObjs[i];
                MZEnumerator *enumerator = [upNextItem enumeratorForContext];
                [output appendFormat:@"\nContext %i:\n", i+1];
                [output appendString:[enumerator description]];
            }
        }
        
        PlayableItem *item;
        NSUInteger index = 0;
        while([enumeratorCopy hasNext]) {
            if(index == 0) {
                [output appendString:@"\n-> Main queue songs coming up:"];
            }
            index++;
            item = [MZNewPlaybackQueue wrapIntoDummyPlayableItemObj:[enumeratorCopy nextObject]];
            [output appendFormat:@"\n%100lu - %@", (unsigned long)index, item];
        }
    }
    return output;
}


#pragma mark - Private helpers
+ (PlayableItem *)wrapAsPlayableItem:(id)obj context:(PlaybackContext *)cntx queuedSong:(BOOL)isQueuedItem
{
    if([obj isMemberOfClass:[Song class]]) {
        return [[PlayableItem alloc] initWithSong:(Song *)obj context:cntx fromUpNextSongs:isQueuedItem];
    } else if([obj isMemberOfClass:[PlaylistItem class]]) {
        return [[PlayableItem alloc] initWithPlaylistItem:(PlaylistItem *)obj
                                                  context:cntx
                                          fromUpNextSongs:isQueuedItem];
    } else {
        return nil;
    }

}

+ (PlayableItem *)wrapIntoDummyPlayableItemObj:(id)object
{
    return [MZNewPlaybackQueue wrapAsPlayableItem:object context:nil queuedSong:NO];
}


//---- Utils ----
// Grabs the next item in the direction specified. Item will be taken from the shuffled-enumerator if
//it exists. Otherwise, from the main-enumerator.
- (PlayableItem *)seekNextItemInDirection:(enum SeekDirection)direction
{
    if(_upNextQueue.count > 0 && direction == SeekForward) {
        UpNextItem *upNextItem = [_upNextQueue peek];
        MZEnumerator *enumerator = [upNextItem enumeratorForContext];
        BOOL isNewUpNextItem = (_lastTouchedUpNextItem != upNextItem);
        _lastTouchedUpNextItem = upNextItem;
        if(enumerator.count == 1 || !enumerator.hasNext) {
            //this enumerator will no longer be needed in the queue, remove it.
            [_upNextQueue dequeue];
        }
        if(enumerator.count == 1 || isNewUpNextItem || enumerator.hasNext) {
            //just went from main/shuffled enumerator to the up-next-queue and back to the main/shuffled
            // enumerator (via the back or forward seek button).
            _usedUpNextQueueInsteadOfMainOrShuffledEnumerator = YES;
        }
        
        //special care needed when entire enumerator is size 1. 'hasNext' will never be true.
        if(enumerator.count == 1 || isNewUpNextItem) {
            return [MZNewPlaybackQueue wrapAsPlayableItem:[enumerator currentObject]
                                                  context:upNextItem.context
                                               queuedSong:YES];
        } else if(enumerator.hasNext) {
            return [MZNewPlaybackQueue wrapAsPlayableItem:[enumerator nextObject]
                                                  context:upNextItem.context
                                               queuedSong:YES];
        } else {
            return [self seekNextItemInDirection:direction];  //recursive
        }
    }
    
    //going from up-next-queue back to the main/shuffled enumerator. will call previousObject()
    //in a second, but cursor hasn't been updated since we switched queues.
    BOOL returnCurrentObject = (_usedUpNextQueueInsteadOfMainOrShuffledEnumerator && direction == SeekBackwards);
    _usedUpNextQueueInsteadOfMainOrShuffledEnumerator = NO;
    MZEnumerator *enumerator = [self initializeAndGetCurrentEnumeratorIfPossible];
    if(enumerator != nil) {
        id obj = nil;
        if(returnCurrentObject) {
            obj =  [enumerator currentObject];
        } else {
            obj = (direction == SeekForward) ? [enumerator nextObject] : [enumerator previousObject];
        }
        return [MZNewPlaybackQueue wrapAsPlayableItem:obj context:_mainContext queuedSong:NO];
    }
    return nil;
}

- (MZEnumerator *)initializeAndGetCurrentEnumeratorIfPossible
{
    if(_mainContext == nil || _mainContext.request == nil) {
        return nil;
    }
    if(_mainEnumerator == nil) {
        NSArray *results = [MZNewPlaybackQueue attemptFetchRequest:_mainContext.request
                                                         batchSize:INTERNAL_FETCH_BATCH_SIZE];
        if(results != nil) {
            _mainEnumerator = [MZNewPlaybackQueue buildEnumeratorFromArray:&results
                                                  withCursorPointingToItem:_mostRecentItem
                                                      outOfBoundsTolerance:1];
        }
    }
    MZEnumerator *enumerator = nil;
    if(_shuffledMainEnumerator != nil) { enumerator = _shuffledMainEnumerator; }
    if(_shuffledMainEnumerator == nil && _mainEnumerator != nil) { enumerator = _mainEnumerator; }
    return enumerator;
}

//Determine the location of the PlayableItem in the core data array, returns index or NSNotFound.
+ (NSUInteger)indexOfItem:(PlayableItem *)item inCoreDataArray:(NSArray **)array
{
    NSUInteger index = NSNotFound;
    //only 1 of the following should be non-nil: playlistItemForItem | songForItem
    if(item.playlistItemForItem == nil) {
        index = [*array indexOfObject:item.songForItem];
    } else if(item.playlistItemForItem != nil) {
        index = [*array indexOfObject:item.playlistItemForItem];
    }
    return index;
}

//this is used to make sure we always work with PlayableItem objects.
- (PlayableItem *)itemAtIndex:(NSUInteger)index
                      inArray:(NSArray **)array
                  withContext:(PlaybackContext *)context
                   queuedSong:(BOOL)queued
{
    if((*array) == nil || index >= (*array).count) {
        return nil;
    }
    
    id obj = [*array objectAtIndex:index];
    if([obj isMemberOfClass:[PlayableItem class]]) {
        return (PlayableItem *)obj;
        
    } else if([obj isMemberOfClass:[Song class]]){
        return [[PlayableItem alloc] initWithSong:(Song *)obj context:context fromUpNextSongs:queued];
        
    } else if([obj isMemberOfClass:[PlaylistItem class]]) {
        return [[PlayableItem alloc] initWithPlaylistItem:(PlaylistItem *)obj context:context fromUpNextSongs:queued];
    } else {
        return nil;
    }
}

/** Returns the fetched array, or nil. */
+ (NSArray *)attemptFetchRequest:(NSFetchRequest *)request batchSize:(NSUInteger)size
{
    if(request == nil) {
        //not much we can do to recover! lets continue using the enumerator (even if its not perfect.)
        return nil;
    }
    [request setFetchBatchSize:size];
    NSError *error = NULL;
    NSArray *array = [[CoreDataManager context] executeFetchRequest:request error:&error];
    return (error) ? nil : array;
}

/**
 * Returns the index of the now playing PlayableItem within the array, or NSNotFound if computation fails.
 */
- (NSUInteger)computeNowPlayingIndexInCoreDataArray:(NSArray **)array
{
    NSUInteger nowPlayingIndex = NSNotFound;  //should point to now playing within the main context
    nowPlayingIndex = [MZNewPlaybackQueue indexOfItem:[NowPlaying sharedInstance].playableItem
                                      inCoreDataArray:array];
    return nowPlayingIndex;
}

+ (MZEnumerator *)buildEnumeratorFromArray:(NSArray **)array
                  withCursorPointingToItem:(PlayableItem *)playableItem
                      outOfBoundsTolerance:(NSUInteger)toleranceValue
{
    if(playableItem == nil) {
        return [(*array) biDirectionalEnumeratorWithOutOfBoundsTolerance:toleranceValue];
    } else {
        NSUInteger idx = [MZNewPlaybackQueue indexOfItem:playableItem
                                         inCoreDataArray:array];
        if(idx == NSNotFound) {
            return [MZNewPlaybackQueue buildEnumeratorFromArray:array
                                       withCursorPointingToItem:nil
                                           outOfBoundsTolerance:toleranceValue];
        }
        return [(*array) biDirectionalEnumeratorAtIndex:idx withOutOfBoundsTolerance:toleranceValue];
    }
}

- (NSUInteger)upNextSongsCount
{
    NSArray *items = [_upNextQueue allQueueObjectsAsArray];
    NSUInteger count = 0;
    for(UpNextItem *upNextItem in items) {
        MZEnumerator *enumerator = [upNextItem enumeratorForContext];
        count += enumerator.numberMoreObjects;
    }
    return count;
}

- (void)reshuffleShuffledEnumeratorUsingMainEnumerator
{
    NSMutableArray *shallowCopy = [[_mainEnumerator underlyingArray] mutableCopy];
    NSUInteger nowPlayingIndex = [_mainEnumerator indexOfCurrentObjectInSourceArray];
    if(nowPlayingIndex == NSNotFound) {
        //brute force way of finding it lol.
        nowPlayingIndex = [self computeNowPlayingIndexInCoreDataArray:&shallowCopy];;
    }
    [MZArrayShuffler shuffleArray:&shallowCopy moveItemAtIndexToFront:nowPlayingIndex];
    _shuffledMainEnumerator = [shallowCopy biDirectionalEnumeratorAtIndex:0
                                                 withOutOfBoundsTolerance:1];
}

@end
