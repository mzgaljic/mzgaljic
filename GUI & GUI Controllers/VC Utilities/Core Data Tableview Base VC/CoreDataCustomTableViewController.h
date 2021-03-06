//
//  CoreDataCustomTableViewController.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 2/5/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MySearchBar;
@class PlaybackContext;
@class PlayableBaseDataSource;
@interface CoreDataCustomTableViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                                UITableViewDelegate>

//The controller (this class fetches nothing if it is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;

@property (nonatomic, strong) PlayableBaseDataSource *tableDataSource;
@property (nonatomic, assign) BOOL displaySearchResults;
@property (nonatomic, strong) PlaybackContext *playbackContext;
@property (nonatomic, strong) NSAttributedString *emptyTableUserMessage;
@property (nonatomic, strong) NSString *cellReuseId;
@property (nonatomic, strong) NSString *playbackContextUniqueId;

// Causes the fetchedResultsController to refresh the data.
// You almost certainly never need to call this.
// The NSFetchedResultsController class observes the context,
// so if the objects in the context change, you do not need to call performFetch
// since the NSFetchedResultsController will notice and update the table automatically.

//This will also automatically be called if you change the fetchedResultsController @property.
- (void)performFetch;

//crucial for this to work (Marks add-on)
- (void)setTableForCoreDataView:(UITableView *)tableView;

//nice additions that allow code re-use for tableviews displaying songs
- (void)setSearchBar:(MySearchBar *)searchBar;

- (void)prepareFetchedResultsControllerForDealloc;

@end
