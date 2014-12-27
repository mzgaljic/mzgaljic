//
//  SongPlayerViewController.h
//  Muzic
//
//  Created by Mark Zgaljic on 10/18/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>  //needed for avplayer
#import "Artist.h"
#import "Album.h"
#import "PlayerView.h"  //custom avplayer view
#import "ASValueTrackingSlider.h"  //slider
#import "PreferredFontSizeUtility.h"
#import "MRProgress.h"  //loading spinner
#import "SDCAlertView.h"  //custom alert view
#import "UIButton+ExpandedHitArea.h"
#import "MusicPlaybackController.h"  //controls queue playback
#import "Reachability.h"  //checking internet connectivity
#import "NSNull+AVPlayer.h"  //dealing with key value observer 'NSNull' issues
#import "UIImage+colorImages.h"  //for recoloring png images
#import "UIColor+LighterAndDarker.h"  //creating lighter and darker colors from base colors
#import "UIColor+SystemTintColor.h"
#import "AlbumArtUtilities.h"  //interface for accessing album art on disk
#import "SongPlayerCoordinator.h"  //controls the video player frame and responds to player events via delegates
#import "SongPlayerNavController.h"

@class MusicPlaybackController;


@interface SongPlayerViewController : UIViewController <AVAudioSessionDelegate,
                                                        AVAudioPlayerDelegate,
                                                        ASValueTrackingSliderDataSource,
                                                        VideoPlayerControlInterfaceDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;  //really the navBar title item
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *playbackTimeSlider;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;

- (IBAction)playbackSliderValueHasChanged:(id)sender;
- (IBAction)playbackSliderEditingHasBegun:(id)sender;
- (IBAction)playbackSliderEditingHasEnded:(id)sender;


@end