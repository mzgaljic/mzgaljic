//
//  AppDelegateSetupHelper.h
//  Muzic
//
//  Created by Mark Zgaljic on 8/9/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnvironmentConstants.h"
#import "Song.h"
#import "Album.h"
#import "Playlist.h"
#import "Artist.h"

@interface AppDelegateSetupHelper : NSObject

+ (void)setUpNSCodingFilePaths;
+ (void)setUpFakeLibraryContent;
+ (void)setAppSettingsAppLaunchedFirstTime:(BOOL)firstTime;

@end
