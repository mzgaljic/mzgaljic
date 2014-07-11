//
//  PlaylistItemTableViewController.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 6/27/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Playlist.h"
#import "Song.h"
#import "RNFrostedSideBar.h"
#import "AppEnvironmentConstants.h"

@interface PlaylistItemTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *results;  //for searching tableView?
@property(nonatomic, strong) Playlist *playlist;

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@end
