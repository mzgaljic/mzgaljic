//
//  MainScreenViewController.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 2/5/15.
//  Copyright (c) 2015 Mark Zgaljic. All rights reserved.
//

#import "MainScreenViewController.h"
@import GoogleMobileAds;  //#import "GADBannerView.h"

NSString * const CENTER_BTN_IMG_NAME = @"plus_sign";
short const dummyTabIndex = 2;

@interface MainScreenViewController()
{
    //used to avoid a blank screen on initial launch when calling
    //'replaceNavControllerOnScreenWithNavController'
    NSUInteger numTimesViewHasAppeared;
    
    BOOL alwaysKeepStatusBarInvisible;
    BOOL tabBarAnimationInProgress;
    BOOL changingTabs;
    UIInterfaceOrientation lastVisibleTabBarOrientation;
    NSUInteger heightOfAdBanner;
}
@property (nonatomic, strong) UIView *tabBarView;  //contains the tab bar and center button - the whole visual thing.
@property (nonatomic, strong) UITabBar *tabBar;  //this tab bar is containing within a tab bar view
@property (nonatomic, strong) SSBouncyButton *centerButton;
@property (nonatomic, strong) NSArray *navControllers;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *tabBarUnselectedImageNames;
@property (nonatomic, strong) NSArray *tabBarSelectedImageNames;
@property (nonatomic, strong) NSArray *tabBarItems;
@property (nonatomic, strong) UINavigationController *currentNavController;
@end


@implementation MainScreenViewController

#pragma mark - ViewController Lifecycle
- (instancetype)initWithNavControllers:(NSArray *)navControllers
          correspondingViewControllers:(NSArray *)viewControllers
            tabBarUnselectedImageNames:(NSArray*)unSelectNames
              tabBarselectedImageNames:(NSArray*)selectNames
{
    if(self = [super init]){
        self.navControllers = navControllers;
        self.viewControllers = viewControllers;
        self.tabBarUnselectedImageNames = unSelectNames;
        self.tabBarSelectedImageNames = selectNames;
        [[UITabBar appearance] setTintColor:[[UIColor defaultAppColorScheme] lighterColor]];
        numTimesViewHasAppeared = 0;
        [AppEnvironmentConstants setTabBarHidden:NO];
        tabBarAnimationInProgress = NO;
        changingTabs = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentNavController = self.navControllers[0];
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(portraitStatusBarStateChanging:)
                                                 name:MZMainScreenVCStatusBarAlwaysInvisible
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTabBarAnimated:)
                                                 name:MZHideTabBarAnimated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appThemePossiblyChanged)
                                                 name:@"app theme color has possibly changed"
                                               object:nil];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)portraitStatusBarStateChanging:(NSNotification *)notification
{
    alwaysKeepStatusBarInvisible = [(NSNumber *)notification.object boolValue];
    [UIView animateWithDuration:0.35 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(numTimesViewHasAppeared != 0)
        [self replaceNavControllerOnScreenWithNavController:self.currentNavController];
    else{
        //initial launch...replaceNavController method optimizes and checks if the viewcontrollers
        //match. need to avoid the optimization the first time...will set the current nav controller too.
        self.currentNavController = nil;
        [self replaceNavControllerOnScreenWithNavController:self.navControllers[0]];
    }
    numTimesViewHasAppeared++;
    
    [self setupTabBarAndTabBarView];
    if(self.tabBarItems == nil)
        [self createTabBarItems];
    
    [self setTabBarItems];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

//this method fixes a bug where the tab bar would look screwed up mid-call (hard to reproduce)
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if(! changingTabs)
        [self setupTabBarAndTabBarViewUsingOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    changingTabs = NO;
}

#pragma mark - Tab bar delegates
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    int tabIndex = (int)[[tabBar items] indexOfObject:item];
    int visualTabIndex = tabIndex;
    if(tabIndex > dummyTabIndex)
        visualTabIndex--;
    [self replaceNavControllerOnScreenWithNavController:self.navControllers[visualTabIndex]];
}

#pragma mark - GUI helpers
- (void)replaceNavControllerOnScreenWithNavController:(UINavigationController *)newNavController
{
    if(self.currentNavController == newNavController)
        return;
    
    BOOL oldNavBarHidden = self.currentNavController.navigationBarHidden;
    [newNavController setNavigationBarHidden:oldNavBarHidden animated:NO];
    changingTabs = YES;
    
    //VC lifecycle methods not being called, i fix that here...
    NSUInteger index = [self.navControllers indexOfObjectIdenticalTo:self.currentNavController];
    UIViewController *oldVc;
    if(index != NSNotFound)
        oldVc = self.viewControllers[index];
    [oldVc viewWillDisappear:YES];
    [oldVc.navigationController.view removeFromSuperview];
    [oldVc viewDidDisappear:YES];
    [oldVc.navigationController removeFromParentViewController];
    
    GADBannerView *myAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    myAd.rootViewController = self;
    //real ad unit for production: ca-app-pub-3961646861945951/6727549027
    myAd.adUnitID = @"ca-app-pub-3940256099942544/2934735716";  //test ad unit
    
    heightOfAdBanner = myAd.frame.size.height;
    int yStartOfAdBanner = self.view.frame.size.height - heightOfAdBanner;
    [self.view addSubview:myAd];
    myAd.frame = CGRectMake(0, yStartOfAdBanner, myAd.frame.size.width, myAd.frame.size.height);
    [myAd loadRequest:[GADRequest request]];
    
    //containing the nav controller within a container
    CGRect desiredVcFrame = CGRectMake(0,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - heightOfAdBanner);
    [self addChildViewController:newNavController];
    newNavController.view.frame = desiredVcFrame;
    
    index = [self.navControllers indexOfObjectIdenticalTo:newNavController];
    UIViewController *newVc = self.viewControllers[index];
    
    [newVc viewWillAppear:YES];
    [self.view addSubview:newNavController.view];
    //make sure tab bar is not covered by the new nav controllers view
    [self.view insertSubview:self.tabBarView aboveSubview:self.view];
    
    [newNavController didMoveToParentViewController:self];
    [newVc viewDidAppear:YES];
    [UIView animateWithDuration:0.35 animations:^{
        [newVc setNeedsStatusBarAppearanceUpdate];
    }];
    
    self.currentNavController = newNavController;
    
    //init these constants only once.
    if(! newNavController.navigationBarHidden && [AppEnvironmentConstants navBarHeight] == 0){
        int navBarHeight = newNavController.navigationBar.frame.size.height;
        int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        [AppEnvironmentConstants setNavBarHeight:navBarHeight];
        [AppEnvironmentConstants setStatusBarHeight:statusBarHeight];
    }
}

//general setup when not rotating the screen
- (void)setupTabBarAndTabBarView
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self setupTabBarAndTabBarViewUsingOrientation:orientation];
}

//helper for setupTabBarAndTabBarView, and used for screen rotation
- (void)setupTabBarAndTabBarViewUsingOrientation:(UIInterfaceOrientation)orientation
{
    UIVisualEffectView *visualEffectView;
    
    if(self.tabBarView == nil){
        self.tabBarView = [[UIView alloc] init];
        
        self.tabBar = [[UITabBar alloc] init];
        self.tabBar.delegate = self;
        
        if([AppEnvironmentConstants isUserOniOS8OrAbove])
        {
            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.tabBarView addSubview:visualEffectView];
            [self.tabBar setBackgroundImage:[UIImage new]];
        }
        
        self.centerButtonImg = [UIImage colorOpaquePartOfImage:[UIColor defaultAppColorScheme]
                                                              :[UIImage imageNamed:CENTER_BTN_IMG_NAME]];
        self.centerButton = [[SSBouncyButton alloc] initAsImage];
        [self.centerButton setImage:self.centerButtonImg forState:UIControlStateNormal];
        [self.centerButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [self.centerButton addTarget:self action:@selector(centerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(UIInterfaceOrientationIsLandscape(orientation))
        self.tabBarView.frame = [self landscapeTabBarViewFrame];
    else
        self.tabBarView.frame = [self portraitTabBarViewFrame];
    
    if([AppEnvironmentConstants isTabBarHidden]){
        self.tabBarView.frame = CGRectMake(self.tabBarView.frame.origin.x,
                                           self.tabBarView.frame.origin.y + MZTabBarHeight,
                                           self.tabBarView.frame.size.width,
                                           self.tabBarView.frame.size.height);
    }
    
    
    self.tabBar.frame = CGRectMake(0, 0, self.tabBarView.frame.size.width, self.tabBarView.frame.size.height);
    self.centerButton.frame = [self centerBtnFrameGivenTabBarViewFrame:self.tabBarView.frame
                                                          centerBtnImg:self.centerButtonImg];
    if(visualEffectView){
        visualEffectView.frame = self.tabBarView.bounds;
    }
    [self.tabBarView addSubview:self.tabBar];
    [self.tabBarView addSubview:self.centerButton];
    [self.tabBarView setMultipleTouchEnabled:NO];
    
    if(! [AppEnvironmentConstants isTabBarHidden]){
        lastVisibleTabBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if(! self.tabBarView.superview)
            [self.view addSubview:self.tabBarView];
        self.tabBarView.alpha = 1;
    }
}

- (void)setTabBarItems
{
    UITabBarItem *selectedItem = [self.tabBar selectedItem];
    if(selectedItem == nil)  //setting default
        selectedItem = self.tabBarItems[0];
    [self.tabBar setItems:self.tabBarItems animated:NO];
    [self.tabBar setSelectedItem:selectedItem];
}

- (void)createTabBarItems
{
    NSMutableArray *tabBarItems = [NSMutableArray array];
    UITabBarItem *someItem;
    UIImage *unselectedImg;
    UIImage *selectedImg;
    NSString *unselectedImgFileName;
    NSString *selectedImgFileName;
    UINavigationController *aNavController;
    //the index in the loop when we need to create the dummy tab bar item
    //(dummy tab bar item will be exactly under our custom uibutton in the
    //superview...the tabBarView)
    short fakeTabIndex = dummyTabIndex;
    for(int i = 0; i < self.navControllers.count; i++){
        if(fakeTabIndex == i){
            [tabBarItems addObject:[[UITabBarItem alloc] initWithTitle:@"" image:nil selectedImage:nil]];
        }
        aNavController = self.navControllers[i];
        unselectedImgFileName = self.tabBarUnselectedImageNames[i];
        selectedImgFileName = self.tabBarSelectedImageNames[i];
        if(unselectedImgFileName.length > 0)  //not needed but faster since program doesnt need to check assets.
            unselectedImg = [UIImage imageNamed:unselectedImgFileName];
        if(selectedImgFileName.length > 0)
            selectedImg = [UIImage imageNamed:selectedImgFileName];
        someItem = [[UITabBarItem alloc] initWithTitle:aNavController.title image:unselectedImg selectedImage:selectedImg];
        [tabBarItems addObject:someItem];
        unselectedImgFileName = nil;
        unselectedImg = nil;
        someItem = nil;
    }
    self.tabBarItems = tabBarItems;
}

- (CGRect)portraitTabBarViewFrame
{
    float portraitWidth;
    float portraitHeight;
    float  a = self.view.frame.size.height;
    float b = self.view.frame.size.width;
    if(a < b){
        portraitHeight = b;
        portraitWidth = a;
    }else{
        portraitWidth = b;
        portraitHeight = a;
    }
    int yVal = portraitHeight - heightOfAdBanner - MZTabBarHeight;
    return CGRectMake(0, yVal, portraitWidth, MZTabBarHeight);
}

- (CGRect)landscapeTabBarViewFrame
{
    float landscapeWidth;
    float landscapeHeight;
    float  a = [[UIScreen mainScreen] bounds].size.height;
    float b = [[UIScreen mainScreen] bounds].size.width;
    if(a < b){
        landscapeWidth = b;
        landscapeHeight = a;
    }else{
        landscapeHeight = b;
        landscapeWidth = a;
    }
    int yVal = landscapeHeight - heightOfAdBanner - MZTabBarHeight;
    return CGRectMake(0, yVal, landscapeWidth, MZTabBarHeight);
}

- (CGRect)centerBtnFrameGivenTabBarViewFrame:(CGRect)tabBarViewFrame centerBtnImg:(UIImage *)img
{
    short centerBtnDiameter = img.size.height;  //same diameter in either dimension
    return CGRectMake((tabBarViewFrame.size.width/2) - (centerBtnDiameter/2),
                      ((tabBarViewFrame.size.height)/2) - (centerBtnDiameter/2),
                      centerBtnDiameter,
                      centerBtnDiameter);
}

- (void)hideTabBarAnimated:(NSNotification *)notification
{
    NSNumber *boolAsNum = [notification object];
    BOOL hide = [boolAsNum boolValue];
    CGRect visibleRect;
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait((currentInterfaceOrientation)))
        visibleRect = [self portraitTabBarViewFrame];
    else
        visibleRect = [self landscapeTabBarViewFrame];
    
    float hideDuration = 0.5;
    float showDuration = 0.35;
    float delay = 0;
    float springDamping = 0.80;
    float initialHideVelocity = 0.65;
    float initialShowVelocity = 0.9;
    
    if(hide)
    {
        if([AppEnvironmentConstants isTabBarHidden])
            return;
        [AppEnvironmentConstants setTabBarHidden:YES];
        lastVisibleTabBarOrientation = currentInterfaceOrientation;
        CGRect hiddenFrame = CGRectMake(visibleRect.origin.x,
                                        visibleRect.origin.y + MZTabBarHeight,
                                        visibleRect.size.width,
                                        visibleRect.size.height);
        [UIView animateWithDuration:hideDuration
                              delay:delay
             usingSpringWithDamping:springDamping
              initialSpringVelocity:initialHideVelocity
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.tabBarView setFrame:hiddenFrame];
                         }
                         completion:^(BOOL finished) {
                             self.tabBarView.hidden = YES;
                             [AppEnvironmentConstants setTabBarHidden:YES];
                             tabBarAnimationInProgress = NO;
                         }];
    }
    else
    {
        if(! [AppEnvironmentConstants isTabBarHidden])
            return;
        [AppEnvironmentConstants setTabBarHidden:NO];
        //checking if orientations have changed (meaningfully anyway...as far as needing to redraw the tab bar)
        if(! (UIInterfaceOrientationIsPortrait(lastVisibleTabBarOrientation)
              && UIInterfaceOrientationIsPortrait(currentInterfaceOrientation))
           ||
           ! (UIInterfaceOrientationIsLandscape(lastVisibleTabBarOrientation)
            && UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)))
        {
            [self setupTabBarAndTabBarViewUsingOrientation:currentInterfaceOrientation];
            [self.tabBarView setFrame:CGRectMake(self.tabBarView.frame.origin.x,
                                                 self.tabBarView.frame.origin.y + MZTabBarHeight,
                                                 self.tabBarView.frame.size.width,
                                                 self.tabBarView.frame.size.height)];
        }
             
        [UIView animateWithDuration:showDuration
                              delay:delay
             usingSpringWithDamping:springDamping + 0.1
              initialSpringVelocity:initialShowVelocity
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.tabBarView setFrame:visibleRect];
                             self.tabBarView.hidden = NO;
                         }
                         completion:^(BOOL finished) {
                             [AppEnvironmentConstants setTabBarHidden:NO];
                             tabBarAnimationInProgress = NO;
                         }];
    }
}

- (void)appThemePossiblyChanged
{
    [self forceTabBarToRedrawFromScratch];
}

- (void)forceTabBarToRedrawFromScratch
{
    [[UITabBar appearance] setTintColor:[[UIColor defaultAppColorScheme] lighterColor]];
    
    UIVisualEffectView *visualEffectView;
    [self.centerButton removeFromSuperview];
    [self.tabBar removeFromSuperview];
    [self.tabBarView removeFromSuperview];
    
    UITabBarItem *currentTabBarItem = self.tabBar.selectedItem;
    NSUInteger currentTabBarItemIndex = [self.tabBarItems indexOfObjectIdenticalTo:currentTabBarItem];
    self.tabBarView = [[UIView alloc] init];
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    
    if([AppEnvironmentConstants isUserOniOS8OrAbove])
    {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.tabBarView addSubview:visualEffectView];
        [self.tabBar setBackgroundImage:[UIImage new]];
    }
    
    self.centerButtonImg = [UIImage colorOpaquePartOfImage:[UIColor defaultAppColorScheme]
                                                          :[UIImage imageNamed:CENTER_BTN_IMG_NAME]];
    self.centerButton = [[SSBouncyButton alloc] initAsImage];
    [self.centerButton setImage:self.centerButtonImg forState:UIControlStateNormal];
    [self.centerButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.centerButton addTarget:self action:@selector(centerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        self.tabBarView.frame = [self landscapeTabBarViewFrame];
    else
        self.tabBarView.frame = [self portraitTabBarViewFrame];
    
    if([AppEnvironmentConstants isTabBarHidden]){
        self.tabBarView.frame = CGRectMake(self.tabBarView.frame.origin.x,
                                           self.tabBarView.frame.origin.y + MZTabBarHeight,
                                           self.tabBarView.frame.size.width,
                                           self.tabBarView.frame.size.height);
    }
    
    
    self.tabBar.frame = CGRectMake(0, 0, self.tabBarView.frame.size.width, self.tabBarView.frame.size.height);
    self.centerButton.frame = [self centerBtnFrameGivenTabBarViewFrame:self.tabBarView.frame
                                                          centerBtnImg:self.centerButtonImg];
    if(visualEffectView){
        visualEffectView.frame = self.tabBarView.bounds;
    }
    [self.tabBarView addSubview:self.tabBar];
    [self.tabBarView addSubview:self.centerButton];
    [self.tabBarView setMultipleTouchEnabled:NO];
    
    if(! [AppEnvironmentConstants isTabBarHidden]){
        lastVisibleTabBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if(! self.tabBarView.superview)
            [self.view addSubview:self.tabBarView];
        self.tabBarView.alpha = 1;
    }
    
    [self setTabBarItems];
    //restore selected tab bar item.
    [self.tabBar setSelectedItem:self.tabBarItems[currentTabBarItemIndex]];
}

#pragma nav bar helper
- (BOOL)prefersStatusBarHidden
{
    if(alwaysKeepStatusBarInvisible)
        return YES;
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        return YES;
    else{
        BOOL isNavBarHidden = self.currentNavController.navigationBar.frame.origin.y < 0;
        if(isNavBarHidden)
            return YES;
        else
            return NO;
    }
}

#pragma mark - VC Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if([AppEnvironmentConstants isTabBarHidden] && !tabBarAnimationInProgress)
        return;
    
    if(tabBarAnimationInProgress){
        if(! [AppEnvironmentConstants isTabBarHidden])
            //resolves issue
            self.tabBarView.alpha = 0;  //animation is going to hide it anyway...
        
        [self setupTabBarAndTabBarViewUsingOrientation:toInterfaceOrientation];
    }
    
    [self ensureTabBarRotatesSmoothlyToInterfaceOrientation:toInterfaceOrientation];
}

- (void)ensureTabBarRotatesSmoothlyToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             [self setupTabBarAndTabBarViewUsingOrientation:toInterfaceOrientation];
                         } completion:nil];
    } else{
        [UIView animateWithDuration:0.2 animations:^{
            int originalWidth = self.tabBarView.frame.size.width;
            [self.tabBarView setFrame:CGRectMake(self.tabBarView.frame.origin.x,
                                                 self.tabBarView.frame.origin.y,
                                                 originalWidth,
                                                 self.tabBarView.frame.size.height)];
        }];
    }
}

#pragma mark - adding music to library
- (void)centerButtonTapped
{
    UIViewController *currentVc;
    for(UIViewController *aViewController in self.viewControllers){
        if(aViewController.navigationController == self.currentNavController){
            currentVc = aViewController;
            break;
        }
    }
    if([currentVc conformsToProtocol:@protocol(MainScreenViewControllerDelegate)])
        [self performSelector:@selector(performCenterBtnTappedActionUsingVC:)
                   withObject:currentVc
                   afterDelay:0.2];
}

- (void)performCenterBtnTappedActionUsingVC:(UIViewController *)aVc
{
    UIViewController *topVc = aVc.navigationController.visibleViewController;
    if(topVc == aVc){
        if([aVc respondsToSelector:@selector(tabBarAddButtonPressed)]){
            [aVc performSelector:@selector(tabBarAddButtonPressed)];
        }
    } else{
        if([topVc respondsToSelector:@selector(tabBarAddButtonPressed)]){
            [topVc performSelector:@selector(tabBarAddButtonPressed)];
        }
    }
}

@end
