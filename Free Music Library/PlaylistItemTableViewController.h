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
#import "SongItemViewController.h"
#import "AppEnvironmentConstants.h"
#import "SongTableViewFormatter.h"
#import "UIColor+LighterAndDarker.h"
#import "SDWebImageManager.h"

@interface PlaylistItemTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *results;  //for searching tableView?
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, assign) int numSongsNotAddedYet;
@property (nonatomic, strong) NSArray *originalLeftBarButtonItems;
@property (nonatomic, strong) NSArray *originalRightBarButtonItems;

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButton;

- (IBAction)addButtonPressed:(id)sender;
@end
