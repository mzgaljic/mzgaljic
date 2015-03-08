//
//  MasterArtistsTableViewController.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/21/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppEnvironmentConstants.h"
#import "Album.h"
#import "Song+Utilities.h"
#import "ArtistTableViewFormatter.h"
#import "NSString+smartSort.h"
#import "SDWebImageManager.h"
#import "MusicPlaybackController.h"
#import "UIColor+LighterAndDarker.h"
#import <SDCAlertView.h>
#import "CoreDataCustomTableViewController.h"
#import "MainScreenViewControllerDelegate.h"
#import <MSCellAccessory.h>

@interface MasterArtistsTableViewController : CoreDataCustomTableViewController
                                                            <UISearchBarDelegate,
                                                            UITableViewDataSource,
                                                            UITableViewDelegate,
                                                            MainScreenViewControllerDelegate>

@end
