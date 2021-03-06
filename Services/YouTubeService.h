//
//  YouTubeVideoSearchService.h
//  zTunes
//
//  Created by Mark Zgaljic on 7/29/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+HTTP_Char_Escape.h"
#import "YouTubeVideoQueryDelegate.h"
#import "YouTubeVideoDetailLookupDelegate.h"
#import "YouTubeVideo.h"

@interface YouTubeService : NSObject <NSURLConnectionDelegate>

+ (instancetype)sharedInstance;

#pragma mark - Video Queries
- (void)searchYouTubeForVideosUsingString:(NSString *)searchString;
- (void)fetchNextYouTubePageUsingLastQueryString;

- (void)cancelAllYtAutoCompletePendingRequests;
- (void)fetchYouTubeAutoCompleteResultsForString:(NSString *)currentString;

- (void)setVideoQueryDelegate:(id<YouTubeServiceSearchingDelegate>)delegate;
- (void)removeVideoQueryDelegate;


#pragma mark - Video Details
- (void)fetchDetailsForVideo:(YouTubeVideo *)ytVideo;

- (void)setVideoDetailLookupDelegate:(id<YouTubeVideoDetailLookupDelegate>)delegate;
- (void)removeVideoDetailLookupDelegate;

#pragma mark - Managing recent YT searches
/** Sets the most recent searches by the user locally on this device (async). Array must be non-nil.
    First object in the array is the newest search, the last is the oldest search.*/
+ (void)setRecentYoutubeSearches:(NSArray *)searches;
/** Gets the most recent searches by the user (saved locally on this device) - synchronously. 
 Guranteed to be non-nil.First object in the array is the newest search, the last is the oldest search. */
+ (NSArray *)getRecentYoutubeSearches;

#pragma mark - Video Presence on Youtube.com
/*
 * Blocks the caller. 
 *
 * Will return NO only if the video corresponding to the given videoID is no longer available.
 * YES will be returned if the video still exists, or if the operation failed (network issue,
 * the REST endpoint was discontinued, etc.)
 */
+ (BOOL)doesVideoStillExist:(NSString *)youtubeVideoId;

@end
