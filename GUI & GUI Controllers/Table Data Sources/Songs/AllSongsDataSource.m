//
//  AllSongsDataSource.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 3/26/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "AllSongsDataSource.h"
#import "StackController.h"
#import "MZTableViewCell.h"
#import "AlbumArtUtilities.h"
#import "MusicPlaybackController.h"
#import "AlbumAlbumArt+Utilities.h"
#import "SongAlbumArt+Utilities.h"
#import "PlayableItem.h"
#import "PreviousNowPlayingInfo.h"
#import "SpotlightHelper.h"

@interface AllSongsDataSource ()
{
    NSString *cellReuseIdDetailLabelNull;
    PlayableDataSearchDataSource *playableSearchBarDataSourceDelegate;
}
@property (nonatomic, assign, readwrite) SONG_DATA_SRC_TYPE dataSourceType;
@property (nonatomic, strong) NSMutableArray *selectedSongIds;
@property (nonatomic, strong) NSOrderedSet *existingPlaylistSongs;
@property (nonatomic, strong) NSMutableArray *searchResults;
@end
@implementation AllSongsDataSource

- (void)setCellReuseId:(NSString *)cellReuseId
{
    _cellReuseId = cellReuseId;
    cellReuseIdDetailLabelNull = [NSString stringWithFormat:@"%@_nilDetail", cellReuseId];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    if(! playableSearchBarDataSourceDelegate)
        playableSearchBarDataSourceDelegate = [[PlayableDataSearchDataSource alloc] initWithTableView:self.tableView
                                                                 playableDataSearchDataSourceDelegate:self
                                                                          searchBarDataSourceDelegate:self];
}

#pragma mark - LifeCycle
- (void)dealloc
{
    playableSearchBarDataSourceDelegate = nil;
    self.fetchedResultsController = nil;
    self.tableView = nil;
    self.playbackContext = nil;
    self.cellReuseId = nil;
    self.editableSongDelegate = nil;
    self.playlistSongAdderDelegate = nil;
    self.searchBarDataSourceDelegate = nil;
    stackController = nil;
    
    self.selectedSongIds = nil;
    self.existingPlaylistSongs = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ dealloced!", NSStringFromClass([self class]));
}

- (instancetype)initWithSongDataSourceType:(SONG_DATA_SRC_TYPE)type
               searchBarDataSourceDelegate:(id<SearchBarDataSourceDelegate>)delegate
{
    if(self = [super init]){
        stackController = [[StackController alloc] init];
        self.dataSourceType = type;
        self.searchBarDataSourceDelegate = delegate;
        if(type == SONG_DATA_SRC_TYPE_Playlist_MultiSelect)
            self.selectedSongIds = [NSMutableArray array];
        
        _readOnlyDataSourceType = type;
        [self setupAppThemeColorObserver];
    }
    return self;
}

- (void)setupAppThemeColorObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCellsDueToAppThemeChange)
                                                 name:@"app theme color has possibly changed"
                                               object:nil];
}

#pragma mark - Overriding functionality
- (void)clearSearchResultsDataSource
{
    [self.searchResults removeAllObjects];
}

- (NSIndexPath *)indexPathInSearchTableForObject:(id)someObject
{
    if([someObject isMemberOfClass:[Song class]])
    {
        Song *someSong = (Song *)someObject;
        NSUInteger songIndex = [self.searchResults indexOfObject:someSong];
        if(songIndex == NSNotFound)
            return nil;
        else{
            return [NSIndexPath indexPathForRow:songIndex inSection:0];
        }
    }
    else
        return nil;
}

- (NSUInteger)tableObjectsCount
{
    return [self numObjectsInTable];
}

#pragma mark - UITableViewDataSource
static char songIndexPathAssociationKey;  //used to associate cells with images when scrolling
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song;
    if(self.displaySearchResults)
        song = [self.searchResults objectAtIndex:indexPath.row];
    else
        song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *reuseID;
    if(song.artist || song.album)
        reuseID = self.cellReuseId;
    else
        reuseID = cellReuseIdDetailLabelNull;
    
    MZTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseId
                                                             forIndexPath:indexPath];
    if (!cell)
        cell = [[MZTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:reuseID];
    else
    {
        // If an existing cell is being reused, reset the image to the default until it is
        // populated. Without this code, previous images are displayed against the new people
        // during rapid scrolling.
        cell.imageView.image = [UIImage imageWithColor:[UIColor clearColor] width:cell.frame.size.height height:cell.frame.size.height];
    }
    
    // Set up other aspects of the cell content.
    cell.editingAccessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR
                                                             color:[[AppEnvironmentConstants appTheme].mainGuiTint lighterColor]];
    cell.textLabel.text = song.songName;
    
    if(![reuseID isEqualToString:cellReuseIdDetailLabelNull]){
        cell.detailTextLabel.text = [AllSongsDataSource generateLabelStringForSong:song];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    BOOL isNowPlaying = [[NowPlaying sharedInstance].playableItem isEqualToSong:song
                                                                          withContext:self.playbackContext];
    if(isNowPlaying) {
        cell.textLabel.textColor = [super colorForNowPlayingItem];
        cell.isRepresentingANowPlayingItem = YES;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.isRepresentingANowPlayingItem = NO;
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Playlist_MultiSelect)
    {
        if([self.existingPlaylistSongs containsObject:song])
        {
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else
        {
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            
            if([_selectedSongIds containsObject:song.uniqueId])
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    // Store a reference to the current cell that will enable the image to be associated with the correct
    // cell, when the image is subsequently loaded asynchronously.
    objc_setAssociatedObject(cell,
                             &songIndexPathAssociationKey,
                             indexPath,
                             OBJC_ASSOCIATION_RETAIN);
    
    __weak Song *weakSong = song;
    cell.anAlbumArtClassObjId = song.albumArt.objectID;
    
    // Queue a block that obtains/creates the image and then loads it into the cell.
    // The code block will be run asynchronously in a last-in-first-out queue, so that when
    // rapid scrolling finishes, the current cells being displayed will be the next to be updated.
    [stackController addBlock:^{
        __block UIImage *albumArt;
        if(weakSong){
            NSString *artObjId = weakSong.albumArt.uniqueId;
            if(artObjId){
                
                //this is a background queue. get the object (image blob) on background context!
                NSManagedObjectContext *context = [CoreDataManager stackControllerThreadContext];
                [context performBlockAndWait:^{
                    albumArt = [weakSong.albumArt imageFromImageData];
                }];
                
                if(albumArt == nil)
                    albumArt = [UIImage imageNamed:@"Sample Album Art"];
            }
        }
        
        // The block will be processed on a background Grand Central Dispatch queue.
        // Therefore, ensure that this code that updates the UI will run on the main queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *cellIndexPath = (NSIndexPath *)objc_getAssociatedObject(cell, &songIndexPathAssociationKey);
            if ([indexPath isEqual:cellIndexPath]) {
                // Only set cell image if the cell currently being displayed is the one that actually required this image.
                // Prevents reused cells from receiving images back from rendering that were requested for that cell in a previous life.
                
                [UIView transitionWithView:cell.imageView
                                  duration:MZCellImageViewFadeDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    cell.imageView.image = albumArt;
                                } completion:nil];
            }
        });
    }];
    
    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Default)
        cell.delegate = self;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.displaySearchResults)
        return NO;

    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Playlist_MultiSelect)
        return NO;
    else if (self.dataSourceType == SONG_DATA_SRC_TYPE_Default)
        return YES;
    else
        return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AppEnvironmentConstants preferredSongCellHeight];
}

//editing the tableView items
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){  //user tapped delete on a row
        //obtain object for the deleted song
        Song *song;
        if(self.displaySearchResults)
            song = [self.searchResults objectAtIndex:indexPath.row];
        else
            song = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        CLSLog(@"User trying to delete song: %@ in context:%@", song.songName, self.playbackContext);
        [SpotlightHelper removeSongFromSpotlightIndex:song];
        [MusicPlaybackController songAboutToBeDeleted:song deletionContext:self.playbackContext];
        [MZCoreDataModelDeletionService prepareSongForDeletion:song];
        
        if(song == nil) {
            CLSLog(@"WARNING: Song was nil for some reason. Returning.");
            return;
        }
        [[CoreDataManager context] deleteObject:song];
        [[CoreDataManager sharedInstance] saveContext];
        
        //this class is responsible for animating this cell since the fetchedResultsController
        //isnt active when displaying search results.
        if(self.displaySearchResults)
        {
            BOOL lastRow =(self.searchResults.count == 1);
            [self.tableView beginUpdates];
            
            if(lastRow)
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                              withRowAnimation:UITableViewRowAnimationMiddle];
            else
                //just delete this row in the section
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationMiddle];
            
            [self.searchResults removeObjectAtIndex:indexPath.row];
            [self.tableView endUpdates];
        }
        
        if([self numObjectsInTable] == 0){ //dont need search bar anymore
            if(self.displaySearchResults){
                MySearchBar *searchbar = (MySearchBar *)self.tableView.tableHeaderView;
                [searchbar resignFirstResponder];
                self.displaySearchResults = NO;
                [self.searchBarDataSourceDelegate searchBarIsBecomingInactive];
            }
            self.tableView.tableHeaderView = nil;
            [self.tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Song *selectedSong;
    if(self.displaySearchResults)
        selectedSong = [self.searchResults objectAtIndex:indexPath.row];
    else
        selectedSong = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Default)
    {
        if(! tableView.editing){
            
            BOOL playerEnabled = [SongPlayerCoordinator isPlayerEnabled];
            BOOL playerOnScreen = [SongPlayerCoordinator isPlayerOnScreen];
            BOOL isNowPlaying = [[NowPlaying sharedInstance].playableItem isEqualToSong:selectedSong
                                                                                  withContext:self.playbackContext];
            BOOL nowPlayingAndActive = (isNowPlaying && playerEnabled && playerOnScreen);
            
            if(nowPlayingAndActive){
                UIViewController *visibleVc = [MZCommons topViewController];
                [SongPlayerViewDisplayUtility segueToSongPlayerViewControllerFrom:visibleVc];
            }
            
            [MusicPlaybackController newQueueWithSong:selectedSong withContext:self.playbackContext];
        }
        else if(tableView.editing)  //tapping song triggers edit segue
            [self.editableSongDelegate performEditSegueWithSong:selectedSong];
    }
    else if(self.dataSourceType == SONG_DATA_SRC_TYPE_Playlist_MultiSelect)
    {
        //do stuff for adding song to list of songs to place in playlist
        
        if([self.existingPlaylistSongs containsObject:selectedSong])
            return;
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if([selectedCell accessoryType] == UITableViewCellAccessoryNone) //selected row
        {
            [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [_selectedSongIds addObject:selectedSong.uniqueId];
            
            [self.playlistSongAdderDelegate setSuccessNavBarButtonStringValue:ADD_String];
        }
        else
        {  //deselected row
            [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
            [_selectedSongIds removeObject:selectedSong.uniqueId];
            
            BOOL isUserCreatingNewPlaylist = [self.playlistSongAdderDelegate isUserCreatingPlaylistFromScratch];
            
            if((_selectedSongIds.count == 0 && isUserCreatingNewPlaylist))
            {
                [self.playlistSongAdderDelegate setSuccessNavBarButtonStringValue:AddLater_String];
            }
            else if(_selectedSongIds.count > 0 && isUserCreatingNewPlaylist)
            {
                [self.playlistSongAdderDelegate setSuccessNavBarButtonStringValue:ADD_String];
            }
            else if(_selectedSongIds.count > 0 && !isUserCreatingNewPlaylist)
            {
                [self.playlistSongAdderDelegate setSuccessNavBarButtonStringValue:ADD_String];
            }
            else
                [self.playlistSongAdderDelegate setSuccessNavBarButtonStringValue:@""];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.displaySearchResults)
        return UITableViewCellEditingStyleNone;
    
    if(aTableView.editing)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.displaySearchResults)
    {
        if(self.searchResults.count > 0){
            [playableSearchBarDataSourceDelegate removeEmptyTableUserMessage];
            return 1;
        }
        else{
            NSAttributedString *text = [MZCommons makeAttributedString:@"No Search Results"];
            [playableSearchBarDataSourceDelegate displayEmptyTableUserMessageWithText:text];
            return 0;
        }
    }
    else
    {
        if([self numObjectsInTable] == 0){
            NSAttributedString *text = self.emptyTableUserMessage;
            [playableSearchBarDataSourceDelegate displayEmptyTableUserMessageWithText:text];
        } else
            [playableSearchBarDataSourceDelegate removeEmptyTableUserMessage];
        
        return self.fetchedResultsController.sections.count;
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if(self.displaySearchResults)
        return self.searchResults.count;
    else{
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
    }
}



#pragma mark - efficiently updating individual cells as needed
- (void)reflectNowPlayingChangesInTableview:(NSNotification *)notification
{
    if(self.playbackContext == nil)
        return;
    Song *oldSong = [PreviousNowPlayingInfo playableItemBeforeNewSongBeganLoading].songForItem;
    NowPlaying *nowPlaying = [NowPlaying sharedInstance];
    Song *newSong = nowPlaying.playableItem.songForItem;
    NSIndexPath *oldPath, *newPath;
    
    //tries to obtain the path to the changed songs if possible.
    if(self.displaySearchResults){
        oldPath = [self indexPathInSearchTableForObject:oldSong];
        newPath = [self indexPathInSearchTableForObject:newSong];
    } else{
        oldPath = [self.fetchedResultsController indexPathForObject:oldSong];
        newPath = [self.fetchedResultsController indexPathForObject:newSong];
    }
    
    if(oldPath || newPath){
        [self.tableView beginUpdates];
        if(oldPath)
            [self.tableView reloadRowsAtIndexPaths:@[oldPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        if(newPath != nil && newPath != oldPath)
            [self.tableView reloadRowsAtIndexPaths:@[newPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - MGSwipeTableCell delegates
- (BOOL)swipeTableCell:(MGSwipeTableCell*)cell canSwipe:(MGSwipeDirection)direction
{
    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Default)
        return YES;
    else
        return NO;
}

- (NSArray*)swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionClipCenter;
    swipeSettings.keepButtonsSwiped = NO;
    expansionSettings.buttonIndex = 0;
    expansionSettings.expansionLayout = MGSwipeExpansionLayoutCenter;
    expansionSettings.threshold = 1.0;
    expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunctionCubicOut;
    expansionSettings.fillOnTrigger = NO;
    UIColor *initialExpansionColor = [MZAppTheme expandingCellGestureInitialColor];
    __weak AllSongsDataSource *weakself = self;
    
    if(direction == MGSwipeDirectionLeftToRight){
        //queue
        Song *song = [self.fetchedResultsController objectAtIndexPath:
                      [self.tableView indexPathForCell:cell]];
        expansionSettings.expansionColor = [MZAppTheme expandingCellGestureQueueItemColor];
        
        __weak Song *weakSong = song;
        __weak MGSwipeTableCell *weakCell = cell;
        return @[[MGSwipeButton buttonWithTitle:@"Queue"
                                backgroundColor:initialExpansionColor
                                        padding:MZCellSpotifyStylePaddingValue
                                       callback:^BOOL(MGSwipeTableCell *sender) {
                                           [MZCommons presentQueuedHUD];
                                           PlaybackContext *context = [weakself contextForSpecificSong:weakSong];
                                           [MusicPlaybackController queueSongsOnTheFlyWithContext:context];
                                           [weakCell refreshContentView];
                                           return NO;
                                       }]];
    } else if(direction == MGSwipeDirectionRightToLeft){
        expansionSettings.expansionColor = [MZAppTheme expandingCellGestureDeleteItemColor];
        MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"Delete"
                                               backgroundColor:initialExpansionColor
                                                       padding:MZCellSpotifyStylePaddingValue
                                                      callback:^BOOL(MGSwipeTableCell *sender)
                                 {
                                     NSIndexPath *indexPath;
                                     indexPath = [weakself.tableView indexPathForCell:sender];
                                     [weakself tableView:weakself.tableView
                                      commitEditingStyle:UITableViewCellEditingStyleDelete
                                       forRowAtIndexPath:indexPath];
                                     return NO;
                                 }];
        return @[delete];
    }
    return nil;
}

- (PlaybackContext *)contextForSpecificSong:(Song *)aSong
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.predicate = [NSPredicate predicateWithFormat:@"smartSortSongName != nil && uniqueId == %@", aSong.uniqueId];
    //descriptor doesnt really matter here
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"songName"
                                                                     ascending:YES];
    
    request.sortDescriptors = @[sortDescriptor];
    return [[PlaybackContext alloc] initWithFetchRequest:[request copy]
                                         prettyQueueName:@""
                                               contextId:self.playbackContext.contextId];
}

- (Song *)songObjectGivenSongId:(NSString *)songId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", songId];
    //descriptor doesnt really matter here
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"songName"
                                                                     ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSArray *results = [[CoreDataManager context] executeFetchRequest:fetchRequest error:nil];
    if(results.count == 1)
        return results[0];
    else
        return nil;
}

- (NSArray *)minimallyFaultedArrayOfSelectedPlaylistSongs
{
    if(self.dataSourceType == SONG_DATA_SRC_TYPE_Playlist_MultiSelect)
    {
        //incomplete implementation
        NSMutableArray *selectedSongs = [NSMutableArray arrayWithCapacity:_selectedSongIds.count];
        Song *aSong;
        for(NSString *aSongId in _selectedSongIds)
        {
            aSong = [self songObjectGivenSongId:aSongId];
            if(aSong != nil)
                [selectedSongs addObject:aSong];
        }
        return selectedSongs;
    }
    else
        return nil;
}

- (MySearchBar *)setUpSearchBar
{
    return [playableSearchBarDataSourceDelegate setUpSearchBar];
}

#pragma mark - SearchBarDataSourceDelegate implementation
- (NSString *)placeholderTextForSearchBar
{
    return [self.searchBarDataSourceDelegate placeholderTextForSearchBar];
}

- (void)searchBarIsBecomingActive
{
    [self.searchBarDataSourceDelegate searchBarIsBecomingActive];
}

- (void)searchBarIsBecomingInactive
{
    [self.searchBarDataSourceDelegate searchBarIsBecomingInactive];
}

#pragma mark - PlayableDataSearchDataSourceDelegate implementation
- (NSFetchRequest *)fetchRequestForSearchBarQuery:(NSString *)query
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.returnsObjectsAsFaults = NO;
    [request setFetchBatchSize:MZDefaultCoreDataFetchBatchSize];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"smartSortSongName"
                                                   ascending:YES
                                                    selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptor];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"smartSortSongName != nil"];
    NSPredicate *otherPredicates = [self generateCompoundedPredicateGivenQuery:query];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, otherPredicates]];
    return request;
}

- (void)searchResultsShouldBeDisplayed:(BOOL)displaySearchResults
{
    self.displaySearchResults = displaySearchResults;
}

- (void)searchResultsFromUsersQuery:(NSArray *)modelObjects
{
    self.searchResults = [NSMutableArray arrayWithArray:modelObjects];
}

- (NSUInteger)playableDataSourceEntireModelCount
{
    return [self numObjectsInTable];
}

- (NSPredicate *)generateCompoundedPredicateGivenQuery:(NSString *)query
{
    NSMutableString *searchWithWildcards = [NSMutableString stringWithFormat:@"*%@*", query];
    if (searchWithWildcards.length > 3){
        for (int i = 2; i < query.length * 2; i += 2)
            [searchWithWildcards insertString:@"*" atIndex:i];
    }
    
    //matches against exact string ANYWHERE within the song name
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"songName contains[cd] %@",  query];
    
    //matches partial string with song name as long as sequence of letters is correct.
    //see: http://stackoverflow.com/questions/15091155/nspredicate-match-any-characters
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"songName LIKE[cd] %@",  searchWithWildcards];
    
    //matches against exact string ANYWHERE within the songs Album name
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"self.album.albumName contains[cd] %@",  query];
    
    //matches partial string with songs album name as long as sequence of letters is correct.
    //(see link few lines above)
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"self.album.albumName LIKE[cd] %@",  searchWithWildcards];
    
    //matches against exact string ANYWHERE within the songs artist name
    NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"self.artist.artistName contains[cd] %@",  query];
    
    //matches partial string with songs artist name as long as sequence of letters is correct.
    //(see link few lines above)
    NSPredicate *predicate6 = [NSPredicate predicateWithFormat:@"self.artist.artistName LIKE[cd] %@",  searchWithWildcards];
    
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1,
                                                               predicate2,
                                                               predicate3,
                                                               predicate4,
                                                               predicate5,
                                                               predicate6]];
}

#pragma mark - Miscellaneous
- (void)updateCellsDueToAppThemeChange
{
    if(self.tableView.editing)
    {
        //cell only has chevrons to update when the table is in editing mode...
        
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        if(visiblePaths.count > 0){
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:visiblePaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
}

- (NSUInteger)numObjectsInTable
{
    if(self.displaySearchResults)
        return self.searchResults.count;
    else
    {
        //used to avoid faulting objects when asking fetchResultsController how many objects exist
        NSString *totalObjCountPathNum = @"@sum.numberOfObjects";
        NSNumber *totalObjCount = [self.fetchedResultsController.sections valueForKeyPath:totalObjCountPathNum];
        return [totalObjCount integerValue];
    }
}

//exposed helper
+ (NSString *)generateLabelStringForSong:(Song *)aSong
{
    NSMutableString *text = [NSMutableString new];
    NSString *artistName = aSong.artist.artistName;
    NSString *albumName = aSong.album.albumName;
    if(artistName != nil && albumName != nil){
        [text appendString:artistName];
        [text appendString:@" — "];
        [text appendString:albumName];
    } else if(artistName == nil && albumName == nil){
        text = nil;
    } else if(artistName == nil && albumName != nil){
        [text appendString:albumName];
    } else if(artistName != nil && albumName == nil){
        [text appendString:artistName];
    } //else  --case should never happen
    return text;
}

@end
