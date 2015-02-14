//
//  CoreDataCustomTableViewController.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 2/5/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"
#import "UIColor+LighterAndDarker.h"
#import "MySearchBar.h"

@interface CoreDataCustomTableViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                                UITableViewDelegate>

//The controller (this class fetches nothing if it is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic) BOOL displaySearchResults;

// Causes the fetchedResultsController to refresh the data.
// You almost certainly never need to call this.
// The NSFetchedResultsController class observes the context,
// so if the objects in the context change, you do not need to call performFetch
// since the NSFetchedResultsController will notice and update the table automatically.

//This will also automatically be called if you change the fetchedResultsController @property.
- (void)performFetch;

//crucial for this to work (Marks add-on)
- (void)setTableForCoreDataView:(UITableView *)tableView;
- (void)setSearchBar:(MySearchBar *)searchBar;

@end