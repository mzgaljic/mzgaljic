//
//  UIColor+Strings.m
//  Sterrio
//
//  Created by Mark Zgaljic on 3/24/16.
//  Copyright © 2016 Mark Zgaljic Apps. All rights reserved.
//

#import "UIColor+Strings.h"

@implementation UIColor (Strings)
#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

- (NSString *) stringFromColor
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use stringFromColor");
    return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
}

- (NSString *) hexStringFromColor
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use hexStringFromColor");
    
    CGFloat r, g, b;
    r = self.red;
    g = self.green;
    b = self.blue;
    
    // Fix range if needed
    if (r < 0.0f) r = 0.0f;
    if (g < 0.0f) g = 0.0f;
    if (b < 0.0f) b = 0.0f;
    
    if (r > 1.0f) r = 1.0f;
    if (g > 1.0f) g = 1.0f;
    if (b > 1.0f) b = 1.0f;
    
    // Convert to hex string between 0x00 and 0xFF
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

+ (UIColor *) colorWithString: (NSString *) stringToConvert
{
    UIColor *DEFAULT_VOID_COLOR = Rgb2UIColor(220, 132, 71, 1);
    
    NSString *cString = [stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Proper color strings are denoted with braces
    if (![cString hasPrefix:@"{"]) return DEFAULT_VOID_COLOR;
    if (![cString hasSuffix:@"}"]) return DEFAULT_VOID_COLOR;
    
    // Remove braces
    cString = [cString substringFromIndex:1];
    cString = [cString substringToIndex:([cString length] - 1)];
    //CFShow((__bridge CFTypeRef)(cString));
    
    // Separate into components by removing commas and spaces
    NSArray *components = [cString componentsSeparatedByString:@", "];
    if ([components count] != 4) return DEFAULT_VOID_COLOR;
    
    // Create the color
    return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
                           green:[[components objectAtIndex:1] floatValue]
                            blue:[[components objectAtIndex:2] floatValue]
                           alpha:[[components objectAtIndex:3] floatValue]];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    UIColor *DEFAULT_VOID_COLOR = Rgb2UIColor(220, 132, 71, 1);
    
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return DEFAULT_VOID_COLOR;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return DEFAULT_VOID_COLOR;
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark - Helpers
- (BOOL) canProvideRGBComponents
{
    return (([self colorSpaceModel] == kCGColorSpaceModelRGB) ||
            ([self colorSpaceModel] == kCGColorSpaceModelMonochrome));
}

- (CGFloat) red
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat) green
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat) blue
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat) alpha
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

- (CGColorSpaceModel) colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *) colorSpaceString
{
    switch ([self colorSpaceModel])
    {
        case kCGColorSpaceModelUnknown:
            return @"kCGColorSpaceModelUnknown";
        case kCGColorSpaceModelMonochrome:
            return @"kCGColorSpaceModelMonochrome";
        case kCGColorSpaceModelRGB:
            return @"kCGColorSpaceModelRGB";
        case kCGColorSpaceModelCMYK:
            return @"kCGColorSpaceModelCMYK";
        case kCGColorSpaceModelLab:
            return @"kCGColorSpaceModelLab";
        case kCGColorSpaceModelDeviceN:
            return @"kCGColorSpaceModelDeviceN";
        case kCGColorSpaceModelIndexed:
            return @"kCGColorSpaceModelIndexed";
        case kCGColorSpaceModelPattern:
            return @"kCGColorSpaceModelPattern";
        default:
            return @"Not a valid color space";
    }
}

@end
