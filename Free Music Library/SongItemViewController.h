//
//  SongItemViewController.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/21/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
//for AVPlayer
#import <AVFoundation/AVFoundation.h>

//youtube link parser and internet connectivity
#import <XCDYouTubeKit/XCDYouTubeClient.h>
#import "Reachability.h"

#import "Song.h"
#import "Album.h"
#import "Artist.h"
#import "Playlist.h"
#import "SDWebImageManager.h"
#import "SDCAlertView.h"
#import "MRProgress.h"
#import "UIImage+colorImages.h"
#import "UIColor+LighterAndDarker.h"
#import "ASValueTrackingSlider.h"
#import "UIColor+SystemTintColor.h"
#import "PreferredFontSizeUtility.h"
#import "UIButton+ExpandedHitArea.h"
#import "AlbumArtUtilities.h"
#import "CoreDataManager.h"
#import "AutoScrollLabel.h"

#import "MusicPlaybackController.h"

@interface SongItemViewController : UIViewController <AVAudioSessionDelegate, AVAudioPlayerDelegate, ASValueTrackingSliderDataSource>
@property (strong, nonatomic) NSNumber *printFriendlySongIndex;

//GUI vars
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;  //really the navBar title item
@property (weak, nonatomic) IBOutlet MyAVPlayer *playerView;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *playbackTimeSlider;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;


- (IBAction)playbackSliderValueHasChanged:(id)sender;
- (IBAction)playbackSliderEditingHasBegun:(id)sender;
- (IBAction)playbackSliderEditingHasEnded:(id)sender;

@end
