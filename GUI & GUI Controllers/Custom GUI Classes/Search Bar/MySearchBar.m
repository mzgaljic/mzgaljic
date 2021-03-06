//
//  MySearchBar.m
//  Muzic
//
//  Created by Mark Zgaljic on 1/3/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "MySearchBar.h"
#import "UIImage+colorImages.h"
#import "PreferredFontSizeUtility.h"

@interface MySearchBar ()
{
    UIColor *textColor;
    int searchBarHeight;
}
@end
@implementation MySearchBar

- (id)initWithPlaceholderText:(NSString *)text
{
    int searchBarWidth = [UIScreen mainScreen].bounds.size.width;
    searchBarHeight = [self searchBarHeightBasedOnUsersPrefSize];
    CGRect frame = CGRectMake(0,
                              0,
                              searchBarWidth,
                              searchBarHeight);
    if(self = [super initWithFrame:frame]){
        textColor = [AppEnvironmentConstants appTheme].contrastingTextColor;
        self.placeholder = text;
        self.keyboardType = UIKeyboardTypeASCIICapable;

        [self customizeSearchBar];
        
        [self setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]
                                                              width:searchBarWidth
                                                             height:searchBarHeight - 5]
                                   forState:UIControlStateNormal];
    }
    return self;
}

- (void)updateFontSizeIfNecessary
{
    [self setFontSizeBasedOnUserSettings];
    [self setNeedsDisplay];
}

- (void)customizeSearchBar
{
    [self setFontSizeBasedOnUserSettings];
    
    //blinking cursor color
    self.tintColor = [UIColor darkGrayColor];
    self.barTintColor = [UIColor whiteColor];
}

- (void)setFontSizeBasedOnUserSettings
{
    float fontSize = [PreferredFontSizeUtility hypotheticalLabelFontSizeForPreferredSize:searchBarHeight];
    fontSize = fontSize * 1.45;
    UIFont *font = [UIFont fontWithName:[AppEnvironmentConstants regularFontName]
                                   size:fontSize];
    NSDictionary *dict = @{
                           NSFontAttributeName: font,
                           NSForegroundColorAttributeName : textColor
                           };
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:dict];
}

- (float)searchBarHeightBasedOnUsersPrefSize
{
    int minSearchBarHeight = [AppEnvironmentConstants minimumSongCellHeight] - 10;
    int maxSearchBarHeight = [AppEnvironmentConstants maximumSongCellHeight] - 30;
    
    float height = [AppEnvironmentConstants preferredSongCellHeight];
    int smallHeightReduction = height * 0.4;
    float newSearchBarHeight = height - smallHeightReduction;
    
    if(newSearchBarHeight < minSearchBarHeight)
        newSearchBarHeight = minSearchBarHeight;
    if(newSearchBarHeight > maxSearchBarHeight)
        newSearchBarHeight = maxSearchBarHeight;
    
    return newSearchBarHeight;
}

- (NSString *)trimmedText
{
    return [self.text stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
