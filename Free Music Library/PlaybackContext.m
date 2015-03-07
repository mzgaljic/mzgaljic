//
//  PlaybackContext.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 3/5/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "PlaybackContext.h"

@implementation PlaybackContext

- (instancetype)initWithFetchRequest:(NSFetchRequest *)aRequest
{
    if([super init]){
        _request = aRequest;
    }
    return self;
}

- (BOOL)isEqualToContext:(PlaybackContext *)someContext
{
    return [_request isEqual:someContext.request];
}

@end
