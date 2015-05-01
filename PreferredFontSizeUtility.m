//
//  PreferredFontSizeUtility.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 7/21/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "PreferredFontSizeUtility.h"
#import "MZTableViewCell.h"

@implementation PreferredFontSizeUtility

+ (float)actualLabelFontSizeFromCurrentPreferredSize
{
    int prefSongCellHeight = [AppEnvironmentConstants preferredSongCellHeight];
    
    int fakeButRealisticWidth = [UIScreen mainScreen].bounds.size.width * 0.85;
    int height = prefSongCellHeight * [MZTableViewCell percentTextLabelIsDecreasedFromTotalCellHeight];
    CGSize labelSize = CGSizeMake(fakeButRealisticWidth, height);
    
    NSString *fontName = [AppEnvironmentConstants boldFontName];
    UIFont *font = [PreferredFontSizeUtility findAdaptiveFontWithName:fontName
                                                       forUILabelSize:labelSize
                                                      withMinimumSize:16];
    return font.pointSize;
}

+ (float)hypotheticalLabelFontSizeForPreferredSize:(int)aSize
{
    int prefSongCellHeight = aSize;
    int fakeButRealisticWidth = [UIScreen mainScreen].bounds.size.width * 0.85;
    int height = prefSongCellHeight * [MZTableViewCell percentTextLabelIsDecreasedFromTotalCellHeight];
    CGSize labelSize = CGSizeMake(fakeButRealisticWidth, height);
    
    NSString *fontName = [AppEnvironmentConstants regularFontName];
    UIFont *font = [PreferredFontSizeUtility findAdaptiveFontWithName:fontName
                                                       forUILabelSize:labelSize
                                                      withMinimumSize:16];
    return font.pointSize;
}

+ (float)actualDetailLabelFontSizeFromCurrentPreferredSize
{
    int prefSongCellHeight = [AppEnvironmentConstants preferredSongCellHeight];
    
    int fakeButRealisticWidth = [UIScreen mainScreen].bounds.size.width * 0.85;
    int height = prefSongCellHeight * [MZTableViewCell percentTextLabelIsDecreasedFromTotalCellHeight];
    CGSize labelSize = CGSizeMake(fakeButRealisticWidth, height);
    
    NSString *fontName = [AppEnvironmentConstants regularFontName];
    UIFont *font = [PreferredFontSizeUtility findAdaptiveFontWithName:fontName
                                                       forUILabelSize:labelSize
                                                      withMinimumSize:16];
    return font.pointSize;
}

+ (UIFont *)findAdaptiveFontWithName:(NSString *)fontName
                      forUILabelSize:(CGSize)labelSize
                     withMinimumSize:(NSInteger)minSize
{
    UIFont *tempFont = nil;
    NSString *testString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSInteger tempMin = minSize;
    NSInteger tempMax = 256;
    NSInteger mid = 0;
    NSInteger difference = 0;
    
    while (tempMin <= tempMax) {
        @autoreleasepool {
            mid = tempMin + (tempMax - tempMin) / 2;
            tempFont = [UIFont fontWithName:fontName size:mid];
            difference = labelSize.height - [testString sizeWithFont:tempFont].height;
            
            if (mid == tempMin || mid == tempMax) {
                if (difference < 0) {
                    return [UIFont fontWithName:fontName size:(mid - 1)];
                }
                return [UIFont fontWithName:fontName size:mid];
            }
            
            if (difference < 0) {
                tempMax = mid - 1;
            } else if (difference > 0) {
                tempMin = mid + 1;
            } else {
                return [UIFont fontWithName:fontName size:mid];
            }
        }
    }
    
    return [UIFont fontWithName:fontName size:mid];
}

@end
