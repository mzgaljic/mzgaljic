//
//  AdvancedOptionsTableViewController.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/3/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "AdvancedOptionsTableViewController.h"
#import "PreferredFontSizeUtility.h"
#import <MSCellAccessory.h>

@interface AdvancedOptionsTableViewController ()
{
    UISwitch *limitVideoLengthSwtich;
    UISwitch *onlyAirplayAudioSwitch;
    
    UIView *airplaySectionFooterView;
    UILabel *airplaySectionFooterLabel;
    UIView *limitVideoLengthSectionFooterView;
    UILabel *limitVideoLengthSectionFooterLabel;
}
@end
@implementation AdvancedOptionsTableViewController

short const NUMBER_OF_SECTIONS = 2;
short const PLAYER_AIRPLAY_OPTIONS_SECTION_NUM = 0;
short const LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM = 1;
//short const MUSIC_LIB_SORTING_SECTION_NUM = 2;

int const AIRPLAY_FOOTER_SWITCH_OFF_HEIGHT = 76;
int const AIRPLAY_FOOTER_SWITCH_ON_HEIGHT = 96;

int const LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_ON_HEIGHT = 76;
int const LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_OFF_HEIGHT = 96;

NSString * const AIRPLAY_AUDIO_ONLY_ENABLED_FOOTER = @"Video is displayed on this device while audio is streamed to the Airplay receiver. Volume can be controlled from this device.";
NSString * const AIRPLAY_AUDIO_ONLY_DISABLED_FOOTER = @"Both video and audio are streamed to the airplay receiver. Volume control is not supported.";

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Advanced";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == PLAYER_AIRPLAY_OPTIONS_SECTION_NUM)
    {
        if([AppEnvironmentConstants shouldOnlyAirplayAudio])
            return AIRPLAY_FOOTER_SWITCH_ON_HEIGHT;
        else
            return AIRPLAY_FOOTER_SWITCH_OFF_HEIGHT;
    }
    else if(section == LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM)
    {
        if([AppEnvironmentConstants limitVideoLengthOnCellular])
            return LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_ON_HEIGHT;
        else
            return LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_OFF_HEIGHT;
    } else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == PLAYER_AIRPLAY_OPTIONS_SECTION_NUM)
    {
        [airplaySectionFooterView removeFromSuperview];
        [airplaySectionFooterLabel removeFromSuperview];
        
        NSString *footerText;
        if([AppEnvironmentConstants shouldOnlyAirplayAudio]){
            footerText = AIRPLAY_AUDIO_ONLY_ENABLED_FOOTER;
        }else{
            footerText = AIRPLAY_AUDIO_ONLY_DISABLED_FOOTER;
        }

        airplaySectionFooterView = [[UIView alloc] initWithFrame:[self airplaySectionFooterViewRect]];
        airplaySectionFooterLabel = [[UILabel alloc] initWithFrame:[self airplaySectionFooterLabelRect]];
        airplaySectionFooterLabel.text = footerText;
        airplaySectionFooterLabel.numberOfLines = 0;
        airplaySectionFooterLabel.font = [UIFont fontWithName:[AppEnvironmentConstants regularFontName]
                                                         size:18];
        airplaySectionFooterLabel.textColor = [UIColor grayColor];
        airplaySectionFooterLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [airplaySectionFooterView addSubview:airplaySectionFooterLabel];
        return airplaySectionFooterView;
    }
    else if(section == LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM)
    {
        [limitVideoLengthSectionFooterView removeFromSuperview];
        [limitVideoLengthSectionFooterLabel removeFromSuperview];
        
        limitVideoLengthSectionFooterView = [[UIView alloc] initWithFrame:[self limitVideoLengthSectionFooterViewRect]];
        limitVideoLengthSectionFooterLabel = [[UILabel alloc] initWithFrame:[self limitVideoLengthSectionFooterLabelRect]];
        limitVideoLengthSectionFooterLabel.text = [self limitVideoLengthOnCellFooterText];
        limitVideoLengthSectionFooterLabel.numberOfLines = 0;
        limitVideoLengthSectionFooterLabel.font = [UIFont fontWithName:[AppEnvironmentConstants regularFontName]
                                                         size:18];
        limitVideoLengthSectionFooterLabel.textColor = [UIColor grayColor];
        limitVideoLengthSectionFooterLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [limitVideoLengthSectionFooterView addSubview:limitVideoLengthSectionFooterLabel];
        return limitVideoLengthSectionFooterView;
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PreferredFontSizeUtility recommendedRowHeightForCellWithSingleLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case PLAYER_AIRPLAY_OPTIONS_SECTION_NUM     :   return 1;
        //case MUSIC_LIB_SORTING_SECTION_NUM          :   return 1;
        case LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM :   return 1;
            
        default:    return -1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == PLAYER_AIRPLAY_OPTIONS_SECTION_NUM)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"advancedSettingRightDetailCell"
                                               forIndexPath:indexPath];
        
        if(indexPath.row == 0)
        {
          //streaming video during airplay
            
            cell.textLabel.text = @"Audio-Only Airplay";
            cell.detailTextLabel.text = nil;
            if(onlyAirplayAudioSwitch == nil){
                onlyAirplayAudioSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                BOOL switchShouldBeOn = [AppEnvironmentConstants shouldOnlyAirplayAudio];
                [onlyAirplayAudioSwitch setOn:switchShouldBeOn animated:NO];
                
                [onlyAirplayAudioSwitch addTarget:self
                                           action:@selector(videoDuringAirplaySwitchToggled)
                                 forControlEvents:UIControlEventValueChanged];
            }
            
            [onlyAirplayAudioSwitch setOnTintColor:[[AppEnvironmentConstants appTheme].mainGuiTint lighterColor]];
            cell.accessoryView = onlyAirplayAudioSwitch;
            UIImage *cloudImg = [UIImage colorOpaquePartOfImage:[AppEnvironmentConstants appTheme].mainGuiTint
                                                               :[UIImage imageNamed:@"airplay settings"]];
            cell.imageView.image = cloudImg;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    /*
    else if(indexPath.section == MUSIC_LIB_SORTING_SECTION_NUM)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"advancedSettingRightDetailCell"
                                               forIndexPath:indexPath];
        
        if(indexPath.row == 0)
        {
            //ignored prefixes when sorting library cell.
            
            cell.textLabel.text = @"Alphabetical Sorting Rules";
            cell.detailTextLabel.text = nil;
            
            UIImage *sortingImg = [UIImage colorOpaquePartOfImage:[AppEnvironmentConstants appTheme].mainGuiTint
                                                                 :[UIImage imageNamed:@"sorting"]];
            cell.imageView.image = sortingImg;
            
            short flatIndicator = FLAT_DISCLOSURE_INDICATOR;
            UIColor *appTheme = [AppEnvironmentConstants appTheme].mainGuiTint;
            MSCellAccessory *coloredDisclosureIndicator = [MSCellAccessory accessoryWithType:flatIndicator
                                                                                       color:appTheme];
            cell.accessoryView = coloredDisclosureIndicator;
        }
    }
     */
    else if(indexPath.section == LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"advancedSettingRightDetailCell"
                                               forIndexPath:indexPath];
        if(indexPath.row == 0) {
            //limiting which videos can be streamed on LTE/3G
            
            cell.textLabel.text = @"Limit Video Length on LTE/3G";
            cell.detailTextLabel.text = nil;
            
            if(limitVideoLengthSwtich == nil){
                limitVideoLengthSwtich = [[UISwitch alloc] initWithFrame:CGRectZero];
                BOOL switchShouldBeOn = [AppEnvironmentConstants limitVideoLengthOnCellular];
                [limitVideoLengthSwtich setOn:switchShouldBeOn animated:NO];
                
                [limitVideoLengthSwtich addTarget:self
                                           action:@selector(videoLengthLimitSwitchToggled)
                                 forControlEvents:UIControlEventValueChanged];
            }
            
            [limitVideoLengthSwtich setOnTintColor:[[AppEnvironmentConstants appTheme].mainGuiTint lighterColor]];
            cell.accessoryView = limitVideoLengthSwtich;
            UIImage *cellTower = [UIImage colorOpaquePartOfImage:[AppEnvironmentConstants appTheme].mainGuiTint
                                                              :[UIImage imageNamed:@"cellular tower"]];
            cell.imageView.image = cellTower;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    float fontSize = [PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize];
    cell.textLabel.font = [UIFont fontWithName:[AppEnvironmentConstants regularFontName]
                                          size:fontSize];
    cell.detailTextLabel.font = [UIFont fontWithName:[AppEnvironmentConstants regularFontName]
                                                size:fontSize];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.numberOfLines = 1;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Switches Toggled
- (void)videoDuringAirplaySwitchToggled
{
    if(onlyAirplayAudioSwitch.isOn == [AppEnvironmentConstants shouldOnlyAirplayAudio])
        return;
    [AppEnvironmentConstants setShouldOnlyAirplayAudio:onlyAirplayAudioSwitch.isOn];
    
    //force footer heights to animate
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    if([AppEnvironmentConstants shouldOnlyAirplayAudio])
        airplaySectionFooterLabel.text = AIRPLAY_AUDIO_ONLY_ENABLED_FOOTER;
    else
        airplaySectionFooterLabel.text = AIRPLAY_AUDIO_ONLY_DISABLED_FOOTER;
}

- (void)videoLengthLimitSwitchToggled
{
    if(limitVideoLengthSwtich.isOn == [AppEnvironmentConstants limitVideoLengthOnCellular])
        return;
    [AppEnvironmentConstants setLimitVideoLengthOnCellular:limitVideoLengthSwtich.isOn];
    
    //force footer heights to animate
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    limitVideoLengthSectionFooterLabel.text = [self limitVideoLengthOnCellFooterText];
}

#pragma mark - Helpers
- (void)orientationDidChange
{
    airplaySectionFooterView.frame = [self airplaySectionFooterViewRect];
    airplaySectionFooterLabel.frame = [self airplaySectionFooterLabelRect];
    
    CGRect temp = [self limitVideoLengthSectionFooterViewRect];
    limitVideoLengthSectionFooterView.frame = temp;
    limitVideoLengthSectionFooterLabel.frame = [self limitVideoLengthSectionFooterLabelRect];
}

#pragma mark - Footer Utils
//--- Airplay footer help ----
- (CGRect)airplaySectionFooterLabelRect
{
    return [self labelRectGivenFooterView:airplaySectionFooterView];
}
- (CGRect)airplaySectionFooterViewRect
{
    int footerViewHeight;
    if([AppEnvironmentConstants shouldOnlyAirplayAudio])
        footerViewHeight = AIRPLAY_FOOTER_SWITCH_ON_HEIGHT;
    else
        footerViewHeight = AIRPLAY_FOOTER_SWITCH_OFF_HEIGHT;
    int headerHeight = [self tableView:self.tableView heightForHeaderInSection:PLAYER_AIRPLAY_OPTIONS_SECTION_NUM];
    return [self footerViewRectGivenHeaderHeight:headerHeight footerViewHeight:footerViewHeight];
}

//--- Limiting video length footer help ----
- (CGRect)limitVideoLengthSectionFooterLabelRect
{
    return [self labelRectGivenFooterView:limitVideoLengthSectionFooterView];
}
- (CGRect)limitVideoLengthSectionFooterViewRect
{
    int footerViewHeight;
    if([AppEnvironmentConstants limitVideoLengthOnCellular])
        footerViewHeight = LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_ON_HEIGHT;
    else
        footerViewHeight = LIMIT_VIDEO_LENGTH_FOOTER_SWITCH_OFF_HEIGHT;
    int headerHeight = [self tableView:self.tableView heightForHeaderInSection:LIMIT_VIDEO_LENGTH_ON_CELL_SECTION_NUM];
    return [self footerViewRectGivenHeaderHeight:headerHeight footerViewHeight:footerViewHeight];
}

- (CGRect)footerViewRectGivenHeaderHeight:(int)headerHeight footerViewHeight:(int)footerHeight
{
    int rowHeight = [PreferredFontSizeUtility recommendedRowHeightForCellWithSingleLabel];
    int yOrigin = rowHeight + headerHeight;
    return CGRectMake(0,
                      yOrigin,
                      [UIScreen mainScreen].bounds.size.width,
                      footerHeight);
}

- (CGRect)labelRectGivenFooterView:(UIView *)footerView
{
    CGRect viewRect = footerView.frame;
    float labelWidth = viewRect.size.width * 0.9;
    float labelHeight = viewRect.size.height * 0.9;
    int topPadding = 4;
    CGRect labelRect = CGRectMake((viewRect.size.width - labelWidth)/2,
                                  topPadding,
                                  labelWidth,
                                  labelHeight);
    return labelRect;
}

- (NSString *)limitVideoLengthOnCellFooterText
{
    if(limitVideoLengthSwtich.isOn) {
        int maxCellVideoLengthInSec = MZLongestCellularPlayableDuration;
        int maxCellVideoLengthInMin = [AdvancedOptionsTableViewController secondsToMinutes:maxCellVideoLengthInSec];
        
        return [NSString stringWithFormat:@"Videos exceeding %i minutes will not be streamed on an LTE/3G connection.", maxCellVideoLengthInMin];
    } else {
        return @"When connected via LTE/3G, all videos are streamable - regardless of their duration. Fees from your provider may apply.";
    }
}

+ (int)secondsToMinutes:(int)seconds
{
    return seconds/60;
}

@end
