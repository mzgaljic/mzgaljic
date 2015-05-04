//
//  AppEnvironmentConstants.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 7/3/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "AppEnvironmentConstants.h"
#import "UIColor+LighterAndDarker.h"
#import "AppDelegateSetupHelper.h"
#import "CoreDataManager.h"
#import "SDCAlertController.h"
#import "MusicPlaybackController.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

@implementation AppEnvironmentConstants

static const BOOL PRODUCTION_MODE = YES;
static BOOL shouldShowWhatsNewScreen = NO;
static BOOL shouldDisplayWelcomeScreen = NO;
static BOOL isFirstTimeAppLaunched = NO;
static BOOL whatsNewMsgIsNew = NO;
static BOOL isBadTimeToMergeEnsemble = NO;
static BOOL userIsPreviewingAVideo = NO;
static BOOL tabBarIsHidden = NO;
static BOOL isIcloudSwitchWaitingForActionToComplete = NO;
static BOOL playbackTimerActive = NO;
static NSInteger activePlaybackTimerThreadNum;
static PLABACK_REPEAT_MODE repeatType;
static PREVIEW_PLAYBACK_STATE currentPreviewPlayerState = PREVIEW_PLAYBACK_STATE_Uninitialized;

static int navBarHeight;
static short statusBarHeight;
static NSInteger lastPlayerViewIndex = NSNotFound;

//setting vars
static int preferredSongCellHeight;
static short preferredWifiStreamValue;
static short preferredCellularStreamValue;
static BOOL icloudSyncEnabled;
static BOOL shouldOnlyAirplayAudio;
//end of setting vars


//runtime configuration
+ (BOOL)isUserOniOS8OrAbove
{
    // conditionally check for any version >= iOS 8 using 'isOperatingSystemAtLeastVersion'
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
        return YES;
    else
        return NO;
}


+ (BOOL)isUserCurrentlyOnCall
{    
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    for (CTCall *call in callCenter.currentCalls)  {
        if (call.callState == CTCallStateConnected) {
            return YES;
        }
    }
    return NO;
}

+ (void)recordIndexOfPlayerView:(NSUInteger)index
{
    lastPlayerViewIndex = index;
}

+ (NSUInteger)lastIndexOfPlayerView
{
    return lastPlayerViewIndex;
}


+ (BOOL)isAppInProductionMode
{
    return PRODUCTION_MODE;
}

+ (BOOL)shouldDisplayWhatsNewScreen
{
    return shouldShowWhatsNewScreen;
}

+ (void)markShouldDisplayWhatsNewScreenTrue
{
    shouldShowWhatsNewScreen = YES;
}

+ (BOOL)shouldDisplayWelcomeScreen
{
    return shouldDisplayWelcomeScreen;
}

+ (void)markShouldDisplayWelcomeScreenTrue
{
    shouldDisplayWelcomeScreen = YES;
}

+ (BOOL)whatsNewMsgIsActuallyNew
{
    return whatsNewMsgIsNew;
}

+ (void)marksWhatsNewMsgAsNew
{
    whatsNewMsgIsNew = YES;
}

+ (BOOL)isFirstTimeAppLaunched
{
    return isFirstTimeAppLaunched;
}

+ (void)markAppAsLaunchedForFirstTime
{
    isFirstTimeAppLaunched = YES;
}

+ (BOOL)isTabBarHidden
{
    return tabBarIsHidden;
}
+ (void)setTabBarHidden:(BOOL)hidden
{
    tabBarIsHidden = hidden;
}


+ (BOOL)isABadTimeToMergeEnsemble
{
    return isBadTimeToMergeEnsemble;
}
+ (void)setIsBadTimeToMergeEnsemble:(BOOL)aValue
{
    isBadTimeToMergeEnsemble = aValue;
}

+ (BOOL)isUserPreviewingAVideo
{
    return userIsPreviewingAVideo;
}

+ (void)setUserIsPreviewingAVideo:(BOOL)aValue
{
    userIsPreviewingAVideo = aValue;
    if(! userIsPreviewingAVideo)
        [AppEnvironmentConstants setCurrentPreviewPlayerState:PREVIEW_PLAYBACK_STATE_Uninitialized];
}

+ (void)setCurrentPreviewPlayerState:(PREVIEW_PLAYBACK_STATE)state
{
    currentPreviewPlayerState = state;
}

+ (PREVIEW_PLAYBACK_STATE)currrentPreviewPlayerState
{
    return currentPreviewPlayerState;
}


static NSLock *playbackTimerLock;
+ (void)setPlaybackTimerActive:(BOOL)active onThreadNum:(NSInteger)threadNum
{
    [playbackTimerLock lock];
    
    playbackTimerActive = active;
    activePlaybackTimerThreadNum = threadNum;
    
    [playbackTimerLock unlock];
}

+ (BOOL)isPlaybackTimerActive
{
    return playbackTimerActive;
}

+ (NSInteger)threadNumOfPlaybackSleepTimerThreadWhichShouldFire
{
    return activePlaybackTimerThreadNum;
}


+ (PLABACK_REPEAT_MODE)playbackRepeatType
{
    return repeatType;
}

+ (void)setPlaybackRepeatType:(PLABACK_REPEAT_MODE)type
{
    repeatType = type;
}

+ (NSString *)stringRepresentationOfRepeatMode
{
    switch (repeatType)
    {
        case PLABACK_REPEAT_MODE_disabled:
            return @"Repeat Off";
            break;
        case PLABACK_REPEAT_MODE_Song:
            return @"Repeat Song";
        case PLABACK_REPEAT_MODE_All:
            return @"Repeat All";
        default:
            return @"";
            break;
    }
}

//fonts
+ (NSString *)regularFontName
{
    return @"Ubuntu";
}
+ (NSString *)boldFontName
{
    return @"Ubuntu-Bold";
}
+ (NSString *)italicFontName
{
    return @"Ubuntu-Italic";
}
+ (NSString *)boldItalicFontName
{
    return @"Ubuntu-BoldItalic";
}

//app settings
+ (int)preferredSongCellHeight
{
    return preferredSongCellHeight;
}
+ (void)setPreferredSongCellHeight:(int)cellHeight
{
    preferredSongCellHeight = cellHeight;
}
+ (int)minimumSongCellHeight
{
    return 49;
}
+ (int)maximumSongCellHeight
{
    return 115;
}
+ (int)defaultSongCellHeight
{
    return 60;
}

+ (short)preferredWifiStreamSetting
{
    return preferredWifiStreamValue;
}

+ (short)preferredCellularStreamSetting
{
    return preferredCellularStreamValue;
}

+ (void)setPreferredWifiStreamSetting:(short)resolutionValue
{
    preferredWifiStreamValue = resolutionValue;
}

+ (void)setPreferredCellularStreamSetting:(short)resolutionValue
{
    preferredCellularStreamValue = resolutionValue;
}

+ (void)setShouldOnlyAirplayAudio:(BOOL)airplayAudio
{
    MyAVPlayer *player = (MyAVPlayer *)[MusicPlaybackController obtainRawAVPlayer];
    shouldOnlyAirplayAudio = airplayAudio;
    if(shouldOnlyAirplayAudio)
        player.allowsExternalPlayback = NO;
    else
        player.allowsExternalPlayback = YES;
}

+ (BOOL)shouldOnlyAirplayAudio
{
    return shouldOnlyAirplayAudio;
}

+ (BOOL)icloudSyncEnabled
{
    return icloudSyncEnabled;
}

+ (BOOL)isIcloudSwitchWaitingForActionToFinish
{
    return isIcloudSwitchWaitingForActionToComplete;
}

static int icloudEnabledCounter = 0;
+ (void)set_iCloudSyncEnabled:(BOOL)enabled
{
    icloudEnabledCounter++;
    if(icloudEnabledCounter != 1){
        //the icloud switch is disabled from touches (in interface) until the action
        //succeeds or fails.
        isIcloudSwitchWaitingForActionToComplete = YES;
    }

    if(enabled)
        [AppEnvironmentConstants tryToLeechMainContextEnsemble];
    else
        [AppEnvironmentConstants tryToDeleechMainContextEnsemble];
    
    icloudSyncEnabled = enabled;
}

+ (void)tryToDeleechMainContextEnsemble
{
    CDEPersistentStoreEnsemble *ensemble =[[CoreDataManager sharedInstance] ensembleForMainContext];
    if(! ensemble.isLeeched){
        isIcloudSwitchWaitingForActionToComplete = NO;
        return;
    }
    
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        if(error)
        {
            //could not de-leech
            NSString *message = @"A problem occured disabling iCloud sync.";
            SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:@"iCloud"
                                                                             message:message
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
            SDCAlertAction *ok = [SDCAlertAction actionWithTitle:@"OK"
                                                           style:SDCAlertActionStyleDefault
                                                         handler:^(SDCAlertAction *action) {
                                                             [AppEnvironmentConstants notifyThatIcloudSyncFailedToDisable];
                                                         }];
            SDCAlertAction *tryAgain = [SDCAlertAction actionWithTitle:@"Try Again"
                                                                 style:SDCAlertActionStyleRecommended
                                                               handler:^(SDCAlertAction *action) {
                                                                   [AppEnvironmentConstants tryToDeleechMainContextEnsemble];
                                                               }];
            [alert addAction:ok];
            [alert addAction:tryAgain];
            [alert performSelectorOnMainThread:@selector(presentWithCompletion:)
                                    withObject:nil
                                 waitUntilDone:NO];
            
            NSLog(@"De-leeched ensemble failed.");
        }
        else
        {
            [AppEnvironmentConstants notifyThatIcloudSyncSuccessfullyDisabled];
            NSLog(@"De-leeched ensemble successfuly");
        }
        
        isIcloudSwitchWaitingForActionToComplete = NO;
    }];
}

+ (void)tryToLeechMainContextEnsemble
{
    CDEPersistentStoreEnsemble *ensemble = [[CoreDataManager sharedInstance] ensembleForMainContext];
    if(ensemble.isLeeched){
        isIcloudSwitchWaitingForActionToComplete = NO;
        return;
    }
    
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        if(error)
        {
            //could not leech
            NSString *message = @"A problem occured enabling iCloud sync.";
            SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:@"iCloud"
                                                                             message:message
                                                                      preferredStyle:SDCAlertControllerStyleAlert];
            SDCAlertAction *ok = [SDCAlertAction actionWithTitle:@"OK"
                                                           style:SDCAlertActionStyleDefault
                                                         handler:^(SDCAlertAction *action) {
                                                             [AppEnvironmentConstants notifyThatIcloudSyncFailedToEnable];
                                                         }];
            SDCAlertAction *tryAgain = [SDCAlertAction actionWithTitle:@"Try Again"
                                                                 style:SDCAlertActionStyleRecommended
                                                               handler:^(SDCAlertAction *action) {
                                                                   [AppEnvironmentConstants tryToLeechMainContextEnsemble];
                                                               }];
            [alert addAction:ok];
            [alert addAction:tryAgain];
            [alert performSelectorOnMainThread:@selector(presentWithCompletion:)
                                    withObject:nil
                                 waitUntilDone:NO];
            
            NSLog(@"Leeching ensemble failed.");
        }
        else
        {
            [AppEnvironmentConstants notifyThatIcloudSyncSuccessfullyEnabled];
            NSLog(@"Leeched ensemble successfuly");
            
            //now lets go the extra mile and try to merge here.
            CDEPersistentStoreEnsemble *ensemble = [[CoreDataManager sharedInstance] ensembleForMainContext];
            [ensemble mergeWithCompletion:^(NSError *error) {
                if(error){
                    NSLog(@"Leeched successfully, but couldnt merge.");
                } else{
                    NSLog(@"Just merged successfully.");
                }
            }];
        }
        
        isIcloudSwitchWaitingForActionToComplete = NO;
    }];
}

#pragma mark - Notifying user interface about success or failure of icloud operations.
+ (void)notifyThatIcloudSyncFailedToEnable
{
    icloudSyncEnabled = NO;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSNotificationCenter defaultCenter] postNotificationName:MZTurningOnIcloudFailed object:nil];
    }];
}

+ (void)notifyThatIcloudSyncFailedToDisable
{
    icloudSyncEnabled = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSNotificationCenter defaultCenter] postNotificationName:MZTurningOffIcloudFailed object:nil];
    }];
}

+ (void)notifyThatIcloudSyncSuccessfullyEnabled
{
    icloudSyncEnabled = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSNotificationCenter defaultCenter] postNotificationName:MZTurningOnIcloudSuccess object:nil];
    }];
}

+ (void)notifyThatIcloudSyncSuccessfullyDisabled
{
    icloudSyncEnabled = NO;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSNotificationCenter defaultCenter] postNotificationName:MZTurningOffIcloudSuccess object:nil];
    }];
}

+ (void)setAppTheme:(UIColor *)appThemeColor
{
    const CGFloat* components = CGColorGetComponents(appThemeColor.CGColor);
    NSNumber *red = [NSNumber numberWithFloat:components[0]];
    NSNumber *green = [NSNumber numberWithFloat:components[1]];
    NSNumber *blue = [NSNumber numberWithFloat:components[2]];
    NSNumber *alpha = [NSNumber numberWithFloat:components[3]];
    
    NSArray *defaultColorRepresentation = @[red, green, blue, alpha];
    [[NSUserDefaults standardUserDefaults] setObject:defaultColorRepresentation
                                              forKey:APP_THEME_COLOR_VALUE_KEY];
    
    [UIColor defaultAppColorScheme:appThemeColor];
    [AppDelegateSetupHelper setGlobalFontsAndColorsForAppGUIComponents];
}

+ (UIColor *)defaultAppThemeBeforeUserPickedTheme
{
    return Rgb2UIColor(240, 110, 50, 1);
}

+ (int)navBarHeight
{
    return navBarHeight;
}

+ (void)setNavBarHeight:(int)height
{
    navBarHeight = height;
}

+ (int)statusBarHeight
{
    return statusBarHeight;
}

+ (void)setStatusBarHeight:(int)height
{
    statusBarHeight = height;
}



//color stuff
+ (UIColor *)expandingCellGestureInitialColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)expandingCellGestureQueueItemColor
{
    return Rgb2UIColor(114, 218, 58, 1);
}

+ (UIColor *)expandingCellGestureDeleteItemColor
{
    return Rgb2UIColor(255, 39, 39, 1);
}

+ (UIColor *)nowPlayingItemColor
{
    return [[UIColor defaultAppColorScheme] lighterColor];
}

@end
