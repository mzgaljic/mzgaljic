//
//  AllSongsDataSource.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 3/26/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayableBaseDataSource.h"
#import "PlaylistSongAdderDataSourceDelegate.h"


//for playlists
#define Done_String @"Add"
#define AddLater_String @"Add later"
#define Cancel_String @"Cancel"


@interface AllSongsDataSource : PlayableBaseDataSource <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, UISearchBarDelegate>
{
    StackController *stackController;
}

@property (nonatomic, assign, readonly) BOOL displaySearchResults;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PlaybackContext *playbackContext;
@property (nonatomic, strong) NSString *cellReuseId;
@property (nonatomic, assign) id <EditableSongDataSourceDelegate> editableSongDelegate;
@property (nonatomic, assign) id <PlaylistSongAdderDataSourceDelegate> playlistSongAdderDelegate;

- (NSArray *)minimallyFaultedArrayOfSelectedPlaylistSongs;
- (instancetype)initWithSongDataSourceType:(SONG_DATA_SRC_TYPE)type
               searchBarDataSourceDelegate:(id<SearchBarDataSourceDelegate>)delegate;

@end