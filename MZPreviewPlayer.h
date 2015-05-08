//
//  MZPreviewPlayer.h
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/7/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MZPreviewPlayer : UIView
@property (strong, nonatomic, readonly) AVPlayer *avPlayer;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (assign, nonatomic, readonly) BOOL isInStall;
@property (assign, nonatomic, readonly) NSUInteger elapsedTimeInSec;

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL;
- (void)setKnownTotalDurationInSec:(NSUInteger)duration;
- (void)play;
- (void)pause;
- (void)destroyPlayer;

@end
