//
//  MZPlaybackQueue.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 3/5/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "MZPlaybackQueue.h"

@interface MZPlaybackQueue ()
{
    MZPrivateMainPlaybackQueue *mainQueue;
    MZPrivateUpNextPlaybackQueue *upNextQueue;
}
@end
@implementation MZPlaybackQueue

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if([super init]){
        upNextQueue = [[MZPrivateUpNextPlaybackQueue alloc] init];
        mainQueue = [[MZPrivateMainPlaybackQueue alloc] init];
    }
    return self;
}

#pragma mark - Get info about queue
- (NSUInteger)numSongsInEntireMainQueue
{
    return [mainQueue numSongsInEntireMainQueue];
}

- (NSUInteger)numMoreSongsInMainQueue
{
    return [mainQueue numMoreSongsInMainQueue];
}

- (NSUInteger)numMoreSongsInUpNext
{
    return [upNextQueue numMoreUpNextSongsCount];
}


#pragma mark - Performing operations on queue
- (void)clearEntireQueue
{
    [upNextQueue clearUpNext];
    [mainQueue clearMainQueue];
}
- (void)clearUpNext
{
    [upNextQueue clearUpNext];
}

//should be used when a user moves into a different context and wants to destroy their
//current queue. This does not clear the "up next" section.
- (void)setMainQueueWithNewNowPlayingSong:(Song *)aSong inContext:(PlaybackContext *)aContext
{
    [mainQueue setMainQueueWithNewNowPlayingSong:aSong inContext:aContext];
    if([NowPlayingSong sharedInstance].nowPlaying.song_id == nil){
        //no songs currently playing, set defaults...
        [[NowPlayingSong sharedInstance] setPlayingBackFromPlayNextSongs:NO];
        [[NowPlayingSong sharedInstance] setNewNowPlayingSong:aSong context:aContext];
    }
}

- (void)addSongsToPlayingNextWithContexts:(NSArray *)contexts
{
    [upNextQueue addSongsToUpNextWithContexts:contexts];
}

- (Song *)skipToPrevious
{
    return [mainQueue skipToPrevious].aNewSong;
}
- (Song *)skipForward
{
    PreliminaryNowPlaying *newNowPlaying = [upNextQueue obtainAndRemoveNextSong];
    BOOL upNextQueueNotEmptyYet = (newNowPlaying.aNewSong != nil);
    if(upNextQueueNotEmptyYet){
        [[NowPlayingSong sharedInstance] setPlayingBackFromPlayNextSongs:YES];
    } else{
        newNowPlaying = [mainQueue skipForward];
        [[NowPlayingSong sharedInstance] setPlayingBackFromPlayNextSongs:NO];
    }
    
    [[NowPlayingSong sharedInstance] setNewNowPlayingSong:newNowPlaying.aNewSong context:newNowPlaying.aNewContext];
    return newNowPlaying.aNewSong;
}

@end