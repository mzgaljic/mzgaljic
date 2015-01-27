//
//  CoreDataErrorViewController.m
//  Muzic
//
//  Created by Mark Zgaljic on 1/24/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "CoreDataErrorViewController.h"

@interface CoreDataErrorViewController ()
{
    short originalAlertTag;
    short emailAlertTag;
    short coreDataPromptUserSecondtimeToBeSafeAlertTag;
    short coreDataDBRecreatedAttemptAlertTag;
}
@property (nonatomic, strong) SDCAlertView *alertView;
@end

@implementation CoreDataErrorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    originalAlertTag = 1;
    emailAlertTag = 2;
    coreDataDBRecreatedAttemptAlertTag = 3;
    coreDataPromptUserSecondtimeToBeSafeAlertTag = 4;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self coreDataInitFail];
}

- (void)coreDataInitFail
{
    NSString *msg = @"It seems the database can no longer be read. This is possibly due to an update or because the database is corrupt. Your music can't be loaded in its current state. Sorry about that!😟";
    _alertView = [[SDCAlertView alloc] initWithTitle:@"Database Problem⚠️"
                                             message:msg
                                            delegate:self
                                   cancelButtonTitle:@"Quit the app"
                                   otherButtonTitles: @"Continue and delete old library", @"Email developer", nil];
    _alertView.titleLabelFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    _alertView.messageLabelFont = [UIFont systemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    _alertView.suggestedButtonFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    _alertView.tag = originalAlertTag;
    [_alertView show];
}

#pragma mark - Responding to alert view actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == originalAlertTag){
        if(buttonIndex == 2)
        {
            //email dev
            [self launchEmailPicker];
        }
        else if(buttonIndex == 1)
        {
            NSString *msg = @"Proceeding will erase ALL music within this App, and a new library will be created. This is premanent.";
            _alertView = [[SDCAlertView alloc] initWithTitle:@"CAUTION"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"Quit the app"
                                           otherButtonTitles: @"Delete my music", nil];
            _alertView.titleLabelFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
            _alertView.messageLabelFont = [UIFont systemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
            _alertView.suggestedButtonFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
            _alertView.tag = coreDataPromptUserSecondtimeToBeSafeAlertTag;
            _alertView.titleLabelTextColor = [UIColor redColor];
            [_alertView show];
        }
        else if(buttonIndex == 0)
        {
            //user wants to quit the app
            exit(0);
        }
    } else if(alertView.tag == emailAlertTag){
        //quit the app after email has been sent.
        exit(0);
    } else if(alertView.tag == coreDataDBRecreatedAttemptAlertTag){
        //user is knowingly quitting app to relaunch it, or to leave
        exit(0);
    } else if(alertView.tag == coreDataPromptUserSecondtimeToBeSafeAlertTag){
        _alertView.titleLabelTextColor = [UIColor blackColor];
        if(buttonIndex == 1)
        {
            //user is positive, continue and delete library
            [self deleteOldCoreDataStoreOnDiskAndRemake];
        }
        else if(buttonIndex == 0)
        {
            //user wants to quit the app
            exit(0);
        }
    }
}

#pragma mark - Recreating Core data DB store
- (void)deleteOldCoreDataStoreOnDiskAndRemake
{
    if([[CoreDataManager sharedInstance] deleteOldStoreAndMakeNewOne]){
        NSString *msg = @"New library has been created. \nPlease relaunch the app.";
        _alertView = [[SDCAlertView alloc] initWithTitle:@"Success"
                                                 message:msg
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        _alertView.titleLabelFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        _alertView.messageLabelFont = [UIFont systemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        _alertView.suggestedButtonFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        
        _alertView.tag = coreDataDBRecreatedAttemptAlertTag;
        [_alertView show];
    } else{
        NSString *msg = @"Something went wrong recreating your library. There is a larger issue with your app, consider reinstalling it.";
        _alertView = [[SDCAlertView alloc] initWithTitle:@"Failure"
                                                 message:msg
                                                delegate:self
                                       cancelButtonTitle:@"Quit App"
                                       otherButtonTitles:nil];
        _alertView.titleLabelFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        _alertView.messageLabelFont = [UIFont systemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        _alertView.suggestedButtonFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
        
        _alertView.tag = coreDataDBRecreatedAttemptAlertTag;
        [_alertView show];
    }
}

#pragma mark - Seguing to the main interface of the app
- (void)gotoMainTabBarInterface
{
    //post notification for app delegate, which will then take care of doing the necessary stuff
    [[NSNotificationCenter defaultCenter] postNotificationName:MZUserCanTransitionToMainInterface
                                                        object:nil];
}

#pragma mark - Emailing Dev code
- (void)launchEmailPicker
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
            [self displayComposerModalView];
        else
            [self launchMailAppOnDevice];
    }
    else
        [self launchMailAppOnDevice];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerModalView
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSString *emailSubject = @"CoreDate DB init problem";
    [picker setSubject:emailSubject];
    
    // Set up recipients
    [picker setToRecipients:@[MZEmailBugReport]];
    [picker setMessageBody:[self buildEmailBodyString] isHTML:NO];
    [self presentViewController:picker animated:YES completion: nil];
    if(picker)
        picker = nil;
}

- (NSString *)buildEmailBodyString
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceName = [UIDevice deviceName];
    NSString *body = @"Please provide as much information as possible...\n\n\n\n\ntime&date\nApp Version: appVersion#\niOS Version: iosVersion#\nDevice: deviceName#\n";
    
    body = [body stringByReplacingOccurrencesOfString:@"time&date"
                                           withString:[self buildCurrentEstTimeString]];
    body = [body stringByReplacingOccurrencesOfString:@"appVersion#" withString:appVersion];
    body = [body stringByReplacingOccurrencesOfString:@"iosVersion#" withString:iosVersion];
    body = [body stringByReplacingOccurrencesOfString:@"deviceName#" withString:deviceName];
    
    return body;
}

- (NSString *)buildCurrentEstTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yy, hh:mmaa";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *date = [dateFormatter dateFromString:dateString];  //right now date is in GMT +0:00
    
    // converts date to proper time zone, returns a string
    NSMutableString *returnMe = [NSMutableString stringWithString: [dateFormatter stringFromDate:date]];
    [returnMe appendString:@" EST"];
    return returnMe;
}

// Dismisses email composition gui when users tap Cancel or Send. Then it updates the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    NSString* alertMessage;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            alertMessage = @"Your email is now being sent.You may or may not receive a response to your email.\nThank You!";
            break;
        case MFMailComposeResultFailed:
            alertMessage = @"Failed to send email.";
            break;
        default:
            alertMessage = @"Failed to send email.";
            break;
    }
    if(alertMessage == nil){
        //user cancelled composing
        alertMessage = @"Unfortunately there is nothing else that can be done unless you wish to delete your music library, or reconsider reporting the problem. Sorry once again for the inconvenience.";
    }
    _alertView = [[SDCAlertView alloc] initWithTitle:@"Developer Email"
                                             message:alertMessage
                                            delegate:self
                                   cancelButtonTitle:@"Leave App"
                                   otherButtonTitles: nil];
    _alertView.titleLabelFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    _alertView.messageLabelFont = [UIFont systemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    _alertView.suggestedButtonFont = [UIFont boldSystemFontOfSize:[PreferredFontSizeUtility actualLabelFontSizeFromCurrentPreferredSize]];
    
    _alertView.tag = emailAlertTag;
    [_alertView show];
}

// Launches the Mail application on the device (when does this occur?)
-(void)launchMailAppOnDevice
{
    NSMutableString *recipients = [NSMutableString stringWithString: @"mailto:"];
    [recipients appendString:MZEmailBugReport];
    [recipients appendString:@"?cc=&subject="];
    NSString *body = @"&body=";
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


@end