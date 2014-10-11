//
//  GenrePickerTableViewController.m
//  Muzic
//
//  Created by Mark Zgaljic on 8/14/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "GenrePickerTableViewController.h"

@interface GenrePickerTableViewController ()
@property (nonatomic, strong) NSDictionary *dictToGenreByLetter;
@property (nonatomic, strong) NSArray *dictKeys;  //key is names of headers (ie: 'A', 'B', 'C'...)
@property (nonatomic, strong) NSString *usersCurrentGenreString;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL displaySearchResults;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property (nonatomic, strong) NSString *notificationName;
@end

@implementation GenrePickerTableViewController
@synthesize searchResults = _searchResults;

- (id)initWithGenreCode:(int)aGenreCode notificationNameToPost:(NSString *)notifName;
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GenrePickerTableViewController* vc = [sb instantiateViewControllerWithIdentifier:@"genrePickerView"];
    self = vc;
    if (self) {
        //custom variables init here
        _usersCurrentGenreString = [GenreConstants genreCodeToString:aGenreCode];
        _notificationName = notifName;
    }
    return self;
}

- (void)setSearchResults:(NSArray *)searchResults
{
    if(searchResults != nil)
        _searchResults = searchResults;
    else
        _searchResults = [NSMutableArray array];
}

- (NSDictionary *)setUpDictionaryUsingAllGenreStrings
{
    NSArray *list = [GenreConstants alphabeticallySortedUserPresentableArrayOfGenreStringsAvailable];
    //will only get 26 letters of alphabet for english letters. will need to modify for other languages
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *word in list) {
        NSString *firstLetter = [[word substringToIndex:1] uppercaseString];
        NSMutableArray *letterList = [dict objectForKey:firstLetter];
        if (!letterList) {
            letterList = [NSMutableArray array];
            [dict setObject:letterList forKey:firstLetter];
        }
        [letterList addObject:word];
    }
    return dict;
}

#pragma mark - View Controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _dictToGenreByLetter = [self setUpDictionaryUsingAllGenreStrings];
    _dictKeys = [[_dictToGenreByLetter allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.searchResults = [NSMutableArray array];
    _navBar.title = @"All Genres";
    [GenreSearchService setDelegate:self];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _displaySearchResults = NO;
    [self setUpSearchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    [GenreSearchService removeDelegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
}

#pragma mark - Genre Search Delegate 
- (void)genreSearchDidCompleteWithResults:(NSArray *)arrayOfGenreStrings
{
    self.searchResults = arrayOfGenreStrings;
    [self.tableView reloadData];
}

#pragma mark - UISearchBar setup and Delegates
- (void)setUpSearchBar
{
    //create search bar, add to viewController
    _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    _searchBar.placeholder = @"Search Genres";
    _searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    _searchBar.delegate = self;
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = _searchBar;
}

//User touched the search box
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //show the cancel button
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    //now try to find results using old search term (if there is one)
    _navBar.title = @"Search Results";
    [GenreSearchService searchAllGenresForGenreString:searchBar.text];
    _displaySearchResults = NO;
}

//user tapped "Search"
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //search results already appear as the user types. Just hide the keyboard so user can see better...
    [_searchBar resignFirstResponder];
    _displaySearchResults = YES;
    [self.tableView reloadData];
}

//User tapped "Cancel"
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _navBar.title = @"All Genres";
    //dismiss search bar and hide cancel button
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    self.searchResults = [NSMutableArray array];
    _displaySearchResults = NO;
    [self.tableView reloadData];
}

//User typing as we speak, fetch latest results to populate results as they type
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0){
        _displaySearchResults = YES;  //mark was here
        _navBar.title = @"Search";
    }
    else{
        _displaySearchResults = YES;
        _navBar.title = @"Search Results";
    }
    [GenreSearchService searchAllGenresForGenreString:searchText];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_displaySearchResults)
        return 1;
    else
        return _dictKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_displaySearchResults)
        return _searchResults.count;  //user is searching and we need to show search results in table
    else{
        NSString *key = _dictKeys[section];  //'A', 'B', etc..
        
        //now grab # of values in this section
        NSArray *keyValues = _dictToGenreByLetter[key];
        return keyValues.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aGenreCell" forIndexPath:indexPath];
    
    NSString *aGenreString;
    // Configure the cell...
    if(_displaySearchResults)
        aGenreString = [_searchResults objectAtIndex:indexPath.row];
    else{
        //determine which section of the table we are populating, get the appropriate array from the dictionary
        NSString *key = _dictKeys[indexPath.section];
        NSArray *keyValues = _dictToGenreByLetter[key];
        //now just get the genre from the array
        aGenreString = keyValues[indexPath.row];
    }
    
    if([aGenreString isEqualToString:_usersCurrentGenreString]){  //disable this cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor defaultSystemTintColor];
        cell.detailTextLabel.textColor = [UIColor defaultSystemTintColor];
    } else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
        cell.detailTextLabel.enabled = YES;
    }

    //init cell fields
    cell.textLabel.text = aGenreString;
    if([ArtistTableViewFormatter artistNameIsBold])  //artist tab uses non bold sizes for both under the hood, so its ok to use it here.
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[ArtistTableViewFormatter nonBoldArtistLabelFontSize]];
    else
        cell.textLabel.font = [UIFont systemFontOfSize:[ArtistTableViewFormatter nonBoldArtistLabelFontSize]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //could also selectively choose which rows may be deleted here.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ArtistTableViewFormatter preferredArtistCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *chosenGenre;
    if(_displaySearchResults)
        chosenGenre = _searchResults[indexPath.row];
    else{
        //determine which section of the table we are populating, get the appropriate array from the dictionary
        NSString *key = _dictKeys[indexPath.section];
        NSArray *keyValues = _dictToGenreByLetter[key];
        //now just get the genre from the array
        chosenGenre = keyValues[indexPath.row];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:chosenGenre];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table View Data Source -'side letters' stuff
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_displaySearchResults)
        return nil;
    else
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(_displaySearchResults)
        return nil;
    else
        return _dictKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(_displaySearchResults)
        return 0;
    else
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - Rotation status bar methods
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // only iOS 7 methods, check http://stackoverflow.com/questions/18525778/status-bar-still-showing
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)prefersStatusBarHidden
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        return YES;
    }
    else
        return NO;  //returned when in portrait, or when app is first launching (UIInterfaceOrientationUnknown)
}

@end