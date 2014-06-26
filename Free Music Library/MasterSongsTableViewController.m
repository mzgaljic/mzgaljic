//
//  MasterSongsTableViewController.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/21/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "MasterSongsTableViewController.h"
#import "SongItemViewController.h"
#import "Album.h"  //import songs!!

@interface MasterSongsTableViewController ()
@property(nonatomic, strong) NSMutableArray* allSongsInLibrary;
@end

@implementation MasterSongsTableViewController
@synthesize allSongsInLibrary = _allSongsInLibrary;

- (NSMutableArray *) results
{
    if(! _results){
        _results = [[NSMutableArray alloc] init];
    }
    return _results;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
                                              //change this to load from songs class!
   // self.allSongsInLibrary = [NSMutableArray arrayWithArray:[Album allLibraryAlbums]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize TableView from memory (loading list w/ song names) - using fake names for now!
    [self.allSongsInLibrary addObject:@"Let it go"];
    [self.allSongsInLibrary addObject:@"For the First Time in Forever"];
    [self.allSongsInLibrary addObject:@"Do You Want To Build A Snowman?"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allSongsInLibrary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongItemCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //change to song class later!
    Album *album = [self.allSongsInLibrary objectAtIndex: indexPath.row];
   // cell.imageView.image = album.albumImage;
    cell.textLabel.text = album.albumName;
    cell.detailTextLabel.text = album.artist.artistName;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString: @"SongItemSegue"]){        
//        [[segue destinationViewController] setSongNumberInSongCollection: self.selectedRowIndexValue];
    }
}

@end
