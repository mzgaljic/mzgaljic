//
//  YouTubeVideoSearchDelegate.h
//  zTunes
//
//  Created by Mark Zgaljic on 7/30/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol YouTubeVideoSearchDelegate <NSObject>

/**called after the json response from the YouTube server was parsed successfully.
 The parameter youTubeVideoObjects contains an array of YouTubeVideo objects.*/
- (void)ytVideoSearchDidCompleteWithResults:(NSArray *)youTubeVideoObjects;

- (void)ytVideoNextPageResultsDidCompleteWithResults:(NSArray *)moreYouTubeVideoObjects;

- (void)ytvideoResultsNoMorePagesToView;

- (void)ytVideoAutoCompleteResultsDidDownload:(NSArray *)arrayOfNSStrings;

- (void)networkErrorHasOccuredSearchingYoutube;

- (void)networkErrorHasOccuredFetchingMorePages;

@end