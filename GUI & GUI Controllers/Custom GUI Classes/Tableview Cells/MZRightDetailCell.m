//
//  MZRightDetailCell.m
//  Sterrio
//
//  Created by Mark Zgaljic on 2/1/16.
//  Copyright © 2016 Mark Zgaljic Apps. All rights reserved.
//

#import "MZRightDetailCell.h"

@interface MZRightDetailCell ()
{
    CGRect originalTextLabelFrame;
    CGRect originalDetailTextLabelFrame;
}
@end
@implementation MZRightDetailCell

/* Ensures that the detailTextLabel (the one on the right in gray text normally) is never
   cut off by the textLabel. On a regular UITableViewCell with the RightDetail style, the
   textLabel can completely push the detailTextLabel off of the contentView.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat accessoryWidth = 10.0f;
    if(self.accessoryType != UITableViewCellAccessoryNone) {
        accessoryWidth = 35.0f;  //the built in chevron and checkmarks are all this width.
    }
    if(self.accessoryView != nil) {
        accessoryWidth = self.accessoryView.frame.size.width + 4;  //4 for padding.
    }
    
    CGSize cgSizeMax = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    UIFont *currFont = self.detailTextLabel.font;
    CGRect detailTextLabelRect;
    CGRect temp = [self.detailTextLabel.text boundingRectWithSize:cgSizeMax
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : currFont}
                                                          context:nil];
    //must round up all float values because then this issue occurrs: http://goo.gl/AWQ0hj
    detailTextLabelRect = CGRectMake(ceilf(temp.origin.x), ceilf(temp.origin.y), ceilf(temp.size.width), ceilf(temp.size.height));
    
    CGFloat detailTextLabelWidth = detailTextLabelRect.size.width;
    
    CGRect detailTextLabelFrame;
    if(CGRectIsEmpty(originalDetailTextLabelFrame)) {
        detailTextLabelFrame = self.detailTextLabel.frame;
        originalDetailTextLabelFrame = detailTextLabelFrame;
    } else {
        detailTextLabelFrame = originalDetailTextLabelFrame;
    }
    
    if (detailTextLabelFrame.size.width < (detailTextLabelWidth + accessoryWidth)) {
        detailTextLabelFrame.size.width = detailTextLabelWidth;
        
        detailTextLabelFrame.origin.x = self.frame.size.width - accessoryWidth - detailTextLabelWidth;
        self.detailTextLabel.frame = detailTextLabelFrame;
        
        CGRect txtLabelFrame;
        if(CGRectIsEmpty(originalTextLabelFrame)) {
            txtLabelFrame = self.textLabel.frame;
            originalTextLabelFrame = txtLabelFrame;
        } else {
            txtLabelFrame = originalTextLabelFrame;
        }
        self.textLabel.frame = CGRectMake(txtLabelFrame.origin.x,
                                          txtLabelFrame.origin.y,
                                          self.frame.size.width - (detailTextLabelWidth + accessoryWidth + txtLabelFrame.origin.x),
                                          txtLabelFrame.size.height);
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        originalTextLabelFrame = CGRectNull;
        originalDetailTextLabelFrame = CGRectNull;
    }
    return self;
}

- (void)prepareForReuse
{
    originalTextLabelFrame = CGRectNull;
    originalDetailTextLabelFrame = CGRectNull;
    self.textLabel.text = @"";
    self.detailTextLabel.text = @"";
    [super prepareForReuse];
}

- (void)dealloc
{
    originalTextLabelFrame = CGRectNull;
    originalDetailTextLabelFrame = CGRectNull;
}

@end
