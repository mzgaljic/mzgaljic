//
//  SongPlayerCoordinator.m
//  Muzic
//
//  Created by Mark Zgaljic on 12/21/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "SongPlayerCoordinator.h"

@interface SongPlayerCoordinator ()
{
    BOOL canIgnoreToolbar;  //navigation controller toolbar
    CGRect currentPlayerFrame;
    short SMALL_VIDEO_WIDTH;
    short SMALL_VIDEO_FRAME_PADDING;
}
@end

@implementation SongPlayerCoordinator
@synthesize delegate = _delegate;
static BOOL isVideoPlayerExpanded;
static BOOL playerIsOnScreen;
float const disabledPlayerAlpa = 0.25;

#pragma mark - Class lifecycle stuff
+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if([super init]){
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if([MusicPlaybackController obtainRawPlayerView].frame.size.width == [appWindow bounds].size.width)
            isVideoPlayerExpanded = YES;
        else
            isVideoPlayerExpanded = NO;
        canIgnoreToolbar = YES;
        SMALL_VIDEO_FRAME_PADDING = 10;
        
        //make small video width smaller than usual on older (small) devices
        SMALL_VIDEO_WIDTH = [UIScreen mainScreen].bounds.size.width/2.0 - SMALL_VIDEO_FRAME_PADDING;
        if(SMALL_VIDEO_WIDTH > 200)
            SMALL_VIDEO_WIDTH = 200;
    }
    return self;
}

- (void)dealloc
{
    //singleton should never be released
    abort();
}

#pragma mark - Other
- (void)setDelegate:(id<VideoPlayerControlInterfaceDelegate>)theDelegate
{
    _delegate = theDelegate;
}

+ (BOOL)isVideoPlayerExpanded
{
    return isVideoPlayerExpanded;
}

- (void)begingExpandingVideoPlayer
{
    //toOrientation code from songPlayerViewController was removed here (code copied)
    if(isVideoPlayerExpanded == YES)
        return;
    
    //I want this to be set "too early", just playing it safe.
    isVideoPlayerExpanded = YES;
    
    PlayerView *playerView = [MusicPlaybackController obtainRawPlayerView];
    MyAVPlayer *player = (MyAVPlayer *)[MusicPlaybackController obtainRawAVPlayer];
    UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
    
    if(playerView == nil){
        //player not even on screen yet
        playerView = [[PlayerView alloc] init];
        player = [[MyAVPlayer alloc] init];
        [playerView setPlayer:player];  //attaches AVPlayer to AVPlayerLayer
        [MusicPlaybackController setRawAVPlayer:player];
        [MusicPlaybackController setRawPlayerView:playerView];
        [playerView setBackgroundColor:[UIColor blackColor]];
        [appWindow addSubview:playerView];
        //setting a temp frame in the bottom right corner for now
        [playerView setFrame:CGRectMake(appWindow.frame.size.width, appWindow.frame.size.height, 1, 1)];
        //real playerView frame set below...
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    __weak PlayerView *weakPlayerView = playerView;
    
    [UIView animateWithDuration:0.425f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
                         {
                             //entering view controller in landscape (fullscreen video)
                             CGRect screenRect = [appWindow bounds];
                             CGFloat screenWidth = screenRect.size.width;
                             CGFloat screenHeight = screenRect.size.height;
                             
                             //+1 is because the view ALMOST covered the full screen.
                             currentPlayerFrame = CGRectMake(0, 0, screenWidth, ceil(screenHeight +1));
                             [weakPlayerView setFrame:currentPlayerFrame];
                             //hide status bar
                             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                         }
                         else
                         {
                             //show portrait player
                             currentPlayerFrame = [self bigPlayerFrameInPortrait];
                             [weakPlayerView setFrame: currentPlayerFrame];
                         }
                         weakPlayerView.alpha = 1;  //in case player was killed.
                         [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
                     } completion:^(BOOL finished) {}];
}

- (void)beginShrinkingVideoPlayer
{
    if(isVideoPlayerExpanded == NO)
        return;
    
    __weak PlayerView *weakPlayerView = [MusicPlaybackController obtainRawPlayerView];
    __weak SongPlayerCoordinator *weakSelf = self;
    BOOL needLandscapeFrame = YES;
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
        needLandscapeFrame = NO;
    
    [UIView animateWithDuration:0.56
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if(needLandscapeFrame)
                             currentPlayerFrame = [weakSelf smallPlayerFrameInLandscape];
                         else
                             currentPlayerFrame = [weakSelf smallPlayerFrameInPortrait];
                         weakPlayerView.frame = currentPlayerFrame;
                         [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
                     } completion:^(BOOL finished) {
                         isVideoPlayerExpanded = NO;
                     }];
}

- (void)shrunkenVideoPlayerNeedsToBeRotated
{
    PlayerView *videoPlayer = [MusicPlaybackController obtainRawPlayerView];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        //landscape rotation...
        currentPlayerFrame = [self smallPlayerFrameInLandscape];
    }
    else{
        //portrait rotation...
        currentPlayerFrame = [self smallPlayerFrameInPortrait];
    }
    [videoPlayer setFrame:currentPlayerFrame];
}

- (void)shrunkenVideoPlayerShouldRespectToolbar
{
    canIgnoreToolbar = NO;
    //need to re-animate playerView into a new position
    
    PlayerView *playerView = [MusicPlaybackController obtainRawPlayerView];
    __weak PlayerView *weakPlayerView = [MusicPlaybackController obtainRawPlayerView];
    __weak SongPlayerCoordinator *weakSelf = self;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        //landscape rotation...
        [UIView animateWithDuration:0.6f animations:^{
            currentPlayerFrame = [weakSelf smallPlayerFrameInLandscape];
            weakPlayerView.frame = currentPlayerFrame;
            [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
        } completion:nil];
    } else{
        //portrait
        [UIView animateWithDuration:0.6f animations:^{
            currentPlayerFrame = [weakSelf smallPlayerFrameInPortrait];
            playerView.frame = currentPlayerFrame;
            [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
        } completion:nil];
    }
}

- (void)shrunkenVideoPlayerCanIgnoreToolbar
{
    canIgnoreToolbar = YES;
    //need to re-animate playerView into new position
    
    PlayerView *playerView = [MusicPlaybackController obtainRawPlayerView];
    __weak PlayerView *weakPlayerView = [MusicPlaybackController obtainRawPlayerView];
    __weak SongPlayerCoordinator *weakSelf = self;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        //landscape rotation...
        [UIView animateWithDuration:0.6f animations:^{
            currentPlayerFrame = [self smallPlayerFrameInLandscape];
            playerView.frame = currentPlayerFrame;
            [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
        } completion:nil];
    } else{
        //portrait
        [UIView animateWithDuration:0.6f animations:^{
            currentPlayerFrame = [weakSelf smallPlayerFrameInPortrait];
            playerView.frame = currentPlayerFrame;
            [[MRProgressOverlayView overlayForView:weakPlayerView] manualLayoutSubviews];
        } completion:nil];
    }
}

- (CGRect)smallPlayerFrameInPortrait
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    short toolbarHeight = 44;
    int width, height, x, y;
    
    //set frame based on what kind of VC we are over at the moment
    if(canIgnoreToolbar){
        width = SMALL_VIDEO_WIDTH;
        height = [SongPlayerViewDisplayUtility videoHeightInSixteenByNineAspectRatioGivenWidth:width];
        x = window.frame.size.width - width - SMALL_VIDEO_FRAME_PADDING;
        y = window.frame.size.height - height - SMALL_VIDEO_FRAME_PADDING;
    } else{
        width = SMALL_VIDEO_WIDTH - 70;
        height = [SongPlayerViewDisplayUtility videoHeightInSixteenByNineAspectRatioGivenWidth:width];
        x = window.frame.size.width - width - SMALL_VIDEO_FRAME_PADDING;
        y = window.frame.size.height - toolbarHeight - height - SMALL_VIDEO_FRAME_PADDING;
    }

    return CGRectMake(x, y, width, height);
}

- (CGRect)smallPlayerFrameInLandscape
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    short toolbarHeight = 34;
    int width, height, x, y;
    
    //set frame based on what kind of VC we are over at the moment
    if(canIgnoreToolbar){
        width = SMALL_VIDEO_WIDTH;
        height = [SongPlayerViewDisplayUtility videoHeightInSixteenByNineAspectRatioGivenWidth:width];
        x = window.frame.size.width - width - SMALL_VIDEO_FRAME_PADDING;
        y = window.frame.size.height - height - SMALL_VIDEO_FRAME_PADDING;
    } else{
        width = SMALL_VIDEO_WIDTH - 70;
        height = [SongPlayerViewDisplayUtility videoHeightInSixteenByNineAspectRatioGivenWidth:width];
        x = window.frame.size.width - width - SMALL_VIDEO_FRAME_PADDING;
        y = window.frame.size.height - toolbarHeight - height - SMALL_VIDEO_FRAME_PADDING;
    }
    
    return CGRectMake(x, y, width, height);
}

- (CGRect)bigPlayerFrameInPortrait
{
    CGPoint screenWidthAndHeight = [SongPlayerCoordinator widthAndHeightOfScreen];
    float videoFrameHeight = [SongPlayerViewDisplayUtility videoHeightInSixteenByNineAspectRatioGivenWidth:screenWidthAndHeight.x];
    float playerFrameYTempalue = roundf(((screenWidthAndHeight.y / 2.0) /1.5));
    int playerYValue = nearestEvenInt((int)playerFrameYTempalue);
    return CGRectMake(0, playerYValue, screenWidthAndHeight.x, videoFrameHeight);
}

+ (CGPoint)widthAndHeightOfScreen
{
    UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
    float widthOfScreenRoationIndependant;
    float heightOfScreenRotationIndependant;
    float  a = [appWindow bounds].size.height;
    float b = [appWindow bounds].size.width;
    if(a < b)
    {
        heightOfScreenRotationIndependant = b;
        widthOfScreenRoationIndependant = a;
    }
    else
    {
        widthOfScreenRoationIndependant = b;
        heightOfScreenRotationIndependant = a;
    }
    return CGPointMake(widthOfScreenRoationIndependant, heightOfScreenRotationIndependant);
}

- (void)temporarilyDisablePlayer
{
    __weak PlayerView *playerView = [MusicPlaybackController obtainRawPlayerView];
    [UIView animateWithDuration:1.0 animations:^{
        playerView.alpha = disabledPlayerAlpa;
        playerView.userInteractionEnabled = NO;
    }];
}

- (void)enablePlayerAgain
{
    __weak PlayerView *playerView = [MusicPlaybackController obtainRawPlayerView];
    [UIView animateWithDuration:1.0 animations:^{
        playerView.alpha = 1.0;
        playerView.userInteractionEnabled = YES;
    }];
}

+ (BOOL)isPlayerEnabled
{
    return ([MusicPlaybackController obtainRawPlayerView].alpha == 1) ? YES : NO;
}

+ (float)alphaValueForDisabledPlayer
{
    return disabledPlayerAlpa;
}

+ (BOOL)isPlayerOnScreen
{
    return playerIsOnScreen;
}

+ (void)playerWasKilled:(BOOL)killed
{
    playerIsOnScreen = !killed;
}

- (CGRect)currentPlayerViewFrame
{
    return currentPlayerFrame;
}

- (void)recordCurrentPlayerViewFrame:(CGRect)newFrame
{
    currentPlayerFrame = newFrame;
}

@end
