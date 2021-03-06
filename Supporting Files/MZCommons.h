//
//  MZCommons.h
//  Sterrio
//
//  Created by Mark Zgaljic on 1/27/16.
//  Copyright © 2016 Mark Zgaljic Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMobileAds;

@interface MZCommons : NSObject

#pragma mark - Threads
void safeSynchronousDispatchToMainQueue(void (^block)(void));

#pragma mark - Regex Helpers
+ (void)replaceCharsMatchingRegex:(NSString *)pattern
                        withChars:(NSString *)replacementChars
                         onString:(NSMutableString **)regexMe;
+ (NSMutableString *)replaceCharsMatchingRegex:(NSString *)pattern
                                     withChars:(NSString *)replacementChars
                                   usingString:(NSString *)regexMe;

+ (BOOL)deleteCharsMatchingRegex:(NSString *)pattern onString:(NSMutableString **)regexMe;
+ (NSMutableString *)deleteCharsMatchingRegex:(NSString *)pattern usingString:(NSString *)regexMe;

#pragma mark - AdMob requests
+ (GADRequest *)getNewAdmobRequest;

#pragma mark - GUI Helpers
+ (void)presentQueuedHUD;
+ (UIViewController *)topViewController;
+ (UIStoryboard *)mainStoryboard;
+ (UIImage *)centerButtonImage;

#pragma mark - Convenience methods/helpers
+ (NSAttributedString *)makeAttributedString:(NSString *)string;
+ (NSAttributedString *)generateTapPlusToCreateNewPlaylistText;

@end
