//
//  MyAVPlayer.h
//  Muzic
//
//  Created by Mark Zgaljic on 10/17/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <XCDYouTubeKit/XCDYouTubeClient.h>
#import "PlayerView.h"
#import "MRProgress.h"  //loading spinner
#import "Reachability.h"
#import "Song+Utilities.h"
#import "PreferredFontSizeUtility.h"
#import "MusicPlaybackController.h"  //for using queue, etc
#import "FetchVideoInfoOperation.h"
#import "DetermineVideoPlayableOperation.h"
#import "OperationQueuesSingeton.h"


@interface MyAVPlayer : AVPlayer
//exposed for the MusicPlayerController class to view these (when updating lock screen, etc)
@property (nonatomic, strong, readonly) NSNumber *elapsedTimeBeforeDisabling;
@property (nonatomic, assign, readonly) BOOL playbackStarted;
@property (nonatomic, assign, readonly) BOOL allowSongDidFinishToExecute;
@property (nonatomic, assign, readonly) NSUInteger secondsLoaded;

- (void)startPlaybackOfSong:(Song *)aSong
               goingForward:(BOOL)forward
            oldPlayableItem:(PlayableItem *)oldItem;

- (void)showSpinnerForInternetConnectionIssueIfAppropriate;
- (void)showSpinnerForBasicLoading;
- (void)showSpinnerForWifiNeeded;
- (void)dismissAllSpinnersIfPossible;

//should NEVER be called directly, except by the connectionStateChanged method
//or after song is done playing, or if a song is being skipped.
- (void)dismissAllSpinners;

- (void)songNeedsToBeSkippedDueToIssue;
- (BOOL)allowSongDidFinishValue;
- (void)allowSongDidFinishNotificationToProceed:(BOOL)proceed;

- (void)songDidFinishPlaying:(NSNotification *)notification;

@end
