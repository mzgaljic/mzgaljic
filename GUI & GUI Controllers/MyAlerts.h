//
//  MyAlerts.h
//  Muzic
//
//  Created by Mark Zgaljic on 12/31/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAlerts : NSObject

typedef enum {
    ALERT_TYPE_SomeVideosNoLongerLoading,  //probably a vevo issue that happens once in a while lol.
    ALERT_TYPE_CannotConnectToYouTube,
    ALERT_TYPE_CannotLoadVideo,
    
    ALERT_TYPE_LongVideoSkippedOnCellular,
    ALERT_TYPE_Chosen_Song_Too_Long_For_Cellular,
    
    ALERT_TYPE_TroubleSharingVideo,
    ALERT_TYPE_TroubleSharingLibrarySong,
    
    ALERT_TYPE_Issue_Tapping_Song_InQueue,
    
    ALERT_TYPE_CannotOpenSafariError,
    ALERT_TYPE_CannotOpenSelectedImageError,
    ALERT_TYPE_SongSaveHasFailed,
    ALERT_TYPE_PlaylistCreationHasFailed,
    ALERT_TYPE_WarnUserOfCellularDataFees,
    ALERT_TYPE_NowPlayingSongWasDeletedOnOtherDevice,
    ALERT_TYPE_TosAndPrivacyPolicy,
    ALERT_TYPE_NEWTosAndPrivacyPolicy
} ALERT_TYPE;

+ (void)displayTestAlertWithText:(NSString *)alertBody;

+ (void)displayAlertWithAlertType:(ALERT_TYPE)type;

//customActions is NSArray of SDCAlertAction objs.
+ (void)displayVideoNoLongerAvailableOnYtAlertForSong:(NSString *)name
                                        customActions:(NSArray *)actions;

+ (void)showAlertWithNumSkippedSongs;
+ (void)skippedLibrarySongDueToLength;

/**
 * Displays app Terms (terms of service, privacy policy, etc.)
 * using the SFSafariViewController
 */
+ (void)presentAppTermsModally;

@end
