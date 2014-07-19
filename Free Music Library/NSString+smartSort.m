//
//  NSString+smartSort.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 7/19/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "NSString+smartSort.h"

@implementation NSString (smartSort)

// This method can be exposed in a header
- (NSComparisonResult)smartSort:(NSString*)aString;
{
   [self removeArticles];
    return [self compare:aString];
}

- (NSString*)removeArticles  //makes sure to resort strings that START with the specified prefixes.
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    if ([self hasPrefix:@"a "])
        range = [self rangeOfString:@"a "];
    
    else if ([self hasPrefix:@"an "])
        range = [self rangeOfString:@"an "];
    
    else if ([self hasPrefix:@"the "])
        range = [self rangeOfString:@"the "];
    
    if (range.location != NSNotFound)
        return [self substringFromIndex:range.length];
    else
        return self;
}

@end