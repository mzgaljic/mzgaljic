//
//  ViewController.m
//  TestAVPlayer
//
//  Created by Mike on 2014-05-07.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "KSVideoPlayerView.h"
#import "KeepLayout.h"
#import "ReachabilitySingleton.h"

@interface KSVideoPlayerView ()
@property (assign, nonatomic, readwrite) BOOL isPlaying;
@property (assign, nonatomic, readwrite) BOOL isInStall;
@end
@implementation KSVideoPlayerView
{
    id playbackObserver;
    AVPlayerLayer *playerLayer;
    BOOL viewIsShowing;
    NSUInteger totalDuration;
    NSUInteger secondsLoaded;
    BOOL playbackStarted;
    BOOL playbackExplicitlyPaused;
}

-(id)initWithFrame:(CGRect)frame playerItem:(AVPlayerItem*)playerItem
{
    self = [super initWithFrame:frame];
    if (self) {
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        [self initObservers];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [playerLayer setFrame:frame];
        [self.moviePlayer seekToTime:kCMTimeZero];
        [self.layer addSublayer:playerLayer];
        self.contentURL = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self initializePlayer:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame contentURL:(NSURL*)contentURL
{
    self = [super initWithFrame:frame];
    if (self) {
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:contentURL];
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        [self initObservers];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.moviePlayer seekToTime:kCMTimeZero];
        [self.layer addSublayer:playerLayer];
        self.contentURL = contentURL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self initializePlayer:frame];
    }
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [playerLayer setFrame:frame];
}

-(void) setupConstraints
{
    
    // bottom HUD view
    self.playerHudBottom.keepHorizontalInsets.equal = 0;
    self.playerHudBottom.keepBottomInset.equal = 0;
    
    // play/pause button
    [self.playPauseButton keepHorizontallyCentered];
    [self.playPauseButton keepVerticallyCentered];
    
    // current time label
    self.playBackTime.keepLeftInset.equal = 5;
    [self.playBackTime keepVerticallyCentered];
    
    
    // progress bar
    self.progressBar.keepLeftOffsetTo(self.playBackTime).equal = 5;
    self.progressBar.keepBottomInset.equal = 0;
    [self.progressBar keepVerticallyCentered];
    
    // total time label
    self.playBackTotalTime.keepLeftOffsetTo(self.progressBar).equal = 5;
    [self.playBackTotalTime keepVerticallyCentered];
    
    // zoom button
    self.zoomButton.keepRightInset.equal = 5;
    [self.zoomButton keepVerticallyCentered];
    
    // airplay button
    self.airplayButton.keepRightOffsetTo(self.zoomButton).equal = self.airplayButton.frame.size.width;
    self.airplayButton.keepLeftOffsetTo(self.playBackTotalTime).equal = 7;
    self.airplayButton.keepBottomInset.equal = 6;
    [self.airplayButton keepVerticallyCentered];
    
}

-(void)initializePlayer:(CGRect)frame
{
    int frameWidth =  frame.size.width;
    int frameHeight = frame.size.height;
    
    self.backgroundColor = [UIColor blackColor];
    viewIsShowing =  NO;
    
    [self.layer setMasksToBounds:YES];
    
    self.playerHudBottom = [[UIView alloc] init];
    self.playerHudBottom.frame = CGRectMake(0, 0, frameWidth, 25);
    [self.playerHudBottom setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.playerHudBottom];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0, 0, frameWidth, 48*frameHeight/160);
    bgView.backgroundColor = [UIColor blackColor];

    // Create the colors for our gradient.
    UIColor *transparent = [UIColor colorWithWhite:1.0f alpha:0.f];
    UIColor *opaque = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    // Create a masklayer.
    CALayer *maskLayer = [[CALayer alloc]init];
    maskLayer.frame = bgView.bounds;
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc]init];
    gradientLayer.frame = CGRectMake(0,0,bgView.bounds.size.width, bgView.bounds.size.height);
    gradientLayer.colors = @[(id)transparent.CGColor, (id)transparent.CGColor, (id)opaque.CGColor, (id)opaque.CGColor];
    gradientLayer.locations = @[@0.0f, @0.09f, @0.8f, @1.0f];
    
    // Add the mask.
    [maskLayer addSublayer:gradientLayer];
    bgView.layer.mask = maskLayer;
    
    [self.playerHudBottom addSubview:bgView];
    
    //Play Pause Button
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playPauseButton.frame = CGRectMake(5*frameWidth/240, 6*frameHeight/160, 16*frameWidth/240, 16*frameHeight/160);
    [self.playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton setSelected:NO];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"avplayer.bundle/playback_pause"] forState:UIControlStateSelected];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"avplayer.bundle/playback_play"] forState:UIControlStateNormal];
    [self.playPauseButton setTintColor:[UIColor clearColor]];
    self.playPauseButton.layer.opacity = 0;
    [self addSubview:self.playPauseButton];
    
    //Seek Time Progress Bar
    self.progressBar = [[UISlider alloc] init];
    self.progressBar.frame = CGRectMake(0, 0, frameWidth, 15);
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(proressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
//    [self.progressBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
    [self.playerHudBottom addSubview:self.progressBar];

    //Current Time Label
    self.playBackTime = [[UILabel alloc] init];
    [self.playBackTime sizeToFit];
    self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.currentTime];
    [self.playBackTime setTextAlignment:NSTextAlignmentLeft];
    [self.playBackTime setTextColor:[UIColor whiteColor]];
    self.playBackTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTime];
    
    //Total Time label
    self.playBackTotalTime = [[UILabel alloc] init];
    [self.playBackTotalTime sizeToFit];
    self.playBackTotalTime.text = [self getStringFromCMTime:self.moviePlayer.currentItem.asset.duration];
    [self.playBackTotalTime setTextAlignment:NSTextAlignmentRight];
    [self.playBackTotalTime setTextColor:[UIColor whiteColor]];
    self.playBackTotalTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTotalTime];
    
    // Airplay button
    self.airplayButton = [ [MPVolumeView alloc] init] ;
    [self.airplayButton setShowsVolumeSlider:NO];
    [self.airplayButton sizeToFit];
    [self.playerHudBottom addSubview:self.airplayButton];
    
    //zoom button
    UIImage *image = [UIImage imageNamed:@"avplayer.bundle/zoomin"];
    self.zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.zoomButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [self.zoomButton addTarget:self action:@selector(zoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.playerHudBottom addSubview:self.zoomButton];
    
    for (UIView *view in [self subviews]) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
    playbackObserver = [self.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.moviePlayer.currentItem.asset.duration, weakself.moviePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.moviePlayer.currentTime.value / (double) endTime.value;
            weakself.progressBar.value = normalizedTime;
        }
        weakself.playBackTime.text = [weakself getStringFromCMTime:weakself.moviePlayer.currentTime];
        
        _elapsedTimeInSec = weakself.moviePlayer.currentTime.value;
    }];
    
    [self setupConstraints];
    [self showHud:NO];
}

-(void)zoomButtonPressed:(UIButton*)sender
{
//    [UIView animateWithDuration:0.5 animations:^{
//        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
//    }];
//    [self.delegate playerViewZoomButtonClicked:self];
}

-(void)setIsFullScreenMode:(BOOL)isFullScreenMode
{
    _isFullScreenMode = isFullScreenMode;
    if (isFullScreenMode) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)playerFinishedPlaying
{
    [self.moviePlayer pause];
    [self.moviePlayer seekToTime:kCMTimeZero];
    [self.playPauseButton setSelected:NO];
    self.isPlaying = NO;
    if ([self.delegate respondsToSelector:@selector(playerFinishedPlayback:)]) {
        [self.delegate playerFinishedPlayback:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(playerLayer.frame, point)) {
        [self showHud:!viewIsShowing];
    }
}

-(void) showHud:(BOOL)show
{
    __weak __typeof(self) weakself = self;
    if(show) {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            weakself.playPauseButton.layer.opacity = 0;
            viewIsShowing = show;
        }];
    } else {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height-self.playerHudBottom.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            weakself.playPauseButton.layer.opacity = 1;
            viewIsShowing = show;
        }];
    }
}

-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}

//-(void)volumeButtonPressed:(UIButton*)sender
//{
//    if (sender.isSelected) {
//        [self.moviePlayer setMuted:YES];
//        [sender setSelected:NO];
//    } else {
//        [self.moviePlayer setMuted:NO];
//        [sender setSelected:YES];
//    }
//}

-(void)playButtonAction:(UIButton*)sender
{
    if (self.isPlaying) {
        [self pause];
//        [sender setSelected:NO];
    } else {
        [self play];
//        [sender setSelected:YES];
    }
}

-(void)progressBarChanged:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer pause];
    }
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.moviePlayer.currentItem.asset.duration.value/(double)self.moviePlayer.currentItem.asset.duration.timescale, self.moviePlayer.currentTime.timescale);
    [self.moviePlayer seekToTime:seekTime];
}

-(void)proressBarChangeEnded:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer play];
    }
}

-(void)volumeBarChanged:(UISlider*)sender
{
    [self.moviePlayer setVolume:sender.value];
}

-(void)play
{
    playbackExplicitlyPaused = NO;
    [self.moviePlayer play];
    [self.playPauseButton setSelected:YES];
}

-(void)pause
{
    playbackExplicitlyPaused = YES;
    [self.moviePlayer pause];
    [self.playPauseButton setSelected:NO];
}

-(void)dealloc
{
    [self.moviePlayer removeTimeObserver:playbackObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

-(void)setKnownTotalDurationInSec:(NSUInteger)duration
{
    totalDuration = duration;
}

- (void)initObservers
{
    [self.moviePlayer addObserver:self
                       forKeyPath:@"currentItem.playbackBufferEmpty"
                          options:NSKeyValueObservingOptionNew
                          context:ksPlaybackBufferEmpty];
    [self.moviePlayer addObserver:self
                       forKeyPath:@"currentItem.loadedTimeRanges"
                          options:NSKeyValueObservingOptionNew
                          context:ksLoadedTimeRanges];
}

- (void)tearDownObservers
{
    [self.moviePlayer removeObserver:self forKeyPath:@"currentItem.playbackBufferEmpty" context:ksPlaybackBufferEmpty];
    [self.moviePlayer removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges" context:ksLoadedTimeRanges];
}

static void *ksLoadedTimeRanges = &ksLoadedTimeRanges;
static void *ksPlaybackBufferEmpty = &ksPlaybackBufferEmpty;
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(context == ksLoadedTimeRanges || context == ksPlaybackBufferEmpty){
        NSArray *timeRanges = self.moviePlayer.currentItem.loadedTimeRanges;
        if (timeRanges && [timeRanges count]){
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            NSUInteger newSecondsBuff = CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration));
            if(context == ksPlaybackBufferEmpty){
                if(newSecondsBuff == secondsLoaded && secondsLoaded != totalDuration && !self.isInStall){
                    NSLog(@"Preview is in stall");
                    self.isInStall = YES;
                    
                    if(self.moviePlayer.rate > 0){
                        self.isPlaying = NO;
                        [self.moviePlayer pause];
                    }
                }
                
            } else if(context == ksLoadedTimeRanges){
                NSUInteger currentTime = CMTimeGetSeconds(self.moviePlayer.currentItem.currentTime);
                CMTimeRange aTimeRange;
                NSUInteger lowBound;
                NSUInteger upperBound;
                BOOL inALoadedRange = NO;
                for(int i = 0; i < timeRanges.count; i++){
                    aTimeRange = [timeRanges[i] CMTimeRangeValue];
                    lowBound = CMTimeGetSeconds(timerange.start);
                    upperBound = CMTimeGetSeconds(CMTimeAdd(timerange.start, aTimeRange.duration));
                    if(currentTime >= lowBound && currentTime < upperBound)
                        inALoadedRange = YES;
                }
                
                if(! inALoadedRange && !self.isInStall){
                    NSLog(@"Preview is in stall");
                    self.isInStall = YES;
                    
                    if(self.moviePlayer.rate > 0){
                        self.isPlaying = NO;
                        [self.moviePlayer pause];
                    }
                    
                } else if(newSecondsBuff > secondsLoaded && self.isInStall && [[ReachabilitySingleton sharedInstance] isConnectedToInternet]){
                    NSLog(@"Preview has left stall");
                    self.isInStall = NO;
                    
                    if(! playbackExplicitlyPaused){
                        self.isPlaying = YES;
                        [self.moviePlayer play];
                    }
                }
                //check if playback began
                if(newSecondsBuff > secondsLoaded && self.moviePlayer.rate == 1 && !playbackStarted){
                    playbackStarted = YES;
                    self.isPlaying = YES;
                    
                    self.isInStall = NO;
                    NSLog(@"Preview playback started");
                }
                secondsLoaded = newSecondsBuff;
            }
        }
    }
}

- (void)destroyPlayer
{
    [self tearDownObservers];
    [self.moviePlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:nil]];
    self.moviePlayer = nil;
}


@end
