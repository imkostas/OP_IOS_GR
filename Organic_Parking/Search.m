//
//  Search.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Search.h"

@interface Search () {
    
    NSArray *searchResultPlaces; //array for storing search results
    SPGooglePlacesAutocompleteQuery *searchQuery; //query object for searching places
    
    NSString *addressTitle; //used for saving parsed query results
    NSString *addressSubtitle; //used for saving parsed query results
    
}

@end

@implementation Search

#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.searchBar setFrame:CGRectMake(self.view.frame.origin.x, TOP_BAR_HEIGHT,
                                        self.searchBar.frame.size.width, self.searchBar.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.searchBar.frame.origin.y + self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height))];
    
    [self.cancelSearchBtn setFrame:CGRectMake((self.view.frame.size.width - self.cancelSearchBtn.frame.size.width), self.searchBar.frame.origin.y - 1, self.cancelSearchBtn.frame.size.width, self.cancelSearchBtn.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initialize query with search radius
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
    searchQuery.radius = 100.0;
    
    //initialize view variables
    addressTitle = @"";
    addressSubtitle = @"";
    
    //set delegates
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //initialize table view
    [self.tableView setAlpha:0.0f];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.delaysContentTouches = NO;
    
    //hide cancelSearchBtn
    [self.cancelSearchBtn setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //make search bar active
    [self.searchBar becomeFirstResponder];
    
    //fade in table view and unhide cancelSearchBtn
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.tableView setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        [self.cancelSearchBtn setHidden:NO];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    //make sure default cancel search bar button is shown
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    //make sure default cancel search bar button is shown
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //send new string to query
    [self handleSearchForSearchString:self.searchBar.text];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //when scrolling the table view dismiss keyboard if active
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    //dismisses view
    [self dismissSearchView];
    
}

- (IBAction)cancelSearch:(id)sender {
    
    //dismisses view
    [self dismissSearchView];
    
}

- (void)dismissSearchView {
    
    //clear search bar and hide cancelSearchBtn
    [self.cancelSearchBtn setHidden:YES];
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    //hide table view and remove child view from parent
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.tableView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Search" object:nil];
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section is needed
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //height for custom cell
	return 55;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //if table view
    if(tableView == self.tableView){
        
        //if search bar text length greater than 0, show query results - otherwise, show previous search history
        if(self.searchBar.text.length > 0){
            
            return [searchResultPlaces count];
            
        } else {
            
            return self.user.searches.count;
            
        }
        
    } else {
        
        return 0;
        
    }
    
}

- (SearchCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //initialize cell
    static NSString *CellIdentifier = @"Cell";
    SearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        
        cell = [[SearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    //if table view
    if(tableView == self.tableView){
        
        //if search bar text length greater than 0, return query address - otherwise, return search history address
        if(self.searchBar.text.length > 0){
            
            [self parseAddress:[self placeAtIndexPath:indexPath].name];
            cell.title.text = addressTitle;
            cell.subtitle.text = addressSubtitle;
            
        } else {
            
            SearchedLocation *search = self.user.searches[(self.user.searches.count-1)-indexPath.row];
            [self parseAddress:search.address];
            cell.title.text = addressTitle;
            cell.subtitle.text = addressSubtitle;
            
        }
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if table view
    if(tableView == self.tableView){
        
        //if search bar length greater than 0, selected query result - otherwise, selected search history
        if(self.searchBar.text.length > 0){
            
            //get place from index
            SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
            
            //get placemark info
            [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                
                if(error){
                    
                    NSLog(@"%@", error);
                    
                    [self customAlert:@"Search by location is currently unavailable" withDone:@"Ok"];
                    
                } else if (placemark) {
                    
                    BOOL searchExists = NO;
                    for(SearchedLocation *search in self.user.searches){
                        
                        if([search.address isEqualToString:place.name]){
                            
                            searchExists = YES;
                            break;
                            
                        }
                        
                    }
                    
                    if(!searchExists){
                        
                        SearchedLocation *search = [[SearchedLocation alloc] initWithSearchedLocation:place.name withCoordinate:placemark.location.coordinate];
                        
                        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                                self.user.username, @"username", place.name, @"address",
                                                [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude], @"latitude",
                                                [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude], @"longitude",
                                                self.user.apiKey, @"api_key", nil];
                        
                        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
                        [manager POST:[NSString stringWithFormat:@"%@addSearch", self.user.uri] parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  
                                  //save placemark info
                                  NSLog(@"%@", responseObject);
                                  
                                  [self.user.searches addObject:search];
                                  
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                                  NSLog(@"%@", operation.responseObject);
                                  
                              }];
                        
                    }
                    
                    //indicate centering should occur
                    self.user.shouldCenterMap = true;
                    
                    self.user.searchCoordinate = placemark.location.coordinate;
                    [self dismissSearchView];
                    
                }
                
            }];
            
        } else {
            
            //chose an existing search
            SearchedLocation *search = self.user.searches[(self.user.searches.count-1)-indexPath.row];
            [self.user.searches removeObjectAtIndex:(self.user.searches.count-1)-indexPath.row];
            [self.user.searches addObject:search];
            
            //indicate map should center and where
            self.user.shouldCenterMap = true;
            self.user.searchCoordinate = search.coordinate;
            
            //dismiss view
            [self dismissSearchView];
            
        }
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if search bar length equal to 0, allow to delete since it is previous search history data
    if(self.searchBar.text.length == 0){
        
        return true;
        
    }
    
    return false;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if can delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //if search bar text length equal to 0
        if(self.searchBar.text.length == 0){
            
            SearchedLocation *search = [self.user.searches objectAtIndex:(self.user.searches.count-1)-indexPath.row];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                self.user.username, @"username", search.address, @"address", self.user.apiKey, @"api_key", nil];
            
            AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
            [manager POST:[NSString stringWithFormat:@"%@deleteSearch", self.user.uri] parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {

                //remove search data from user info
                [self.user.searches removeObjectAtIndex:(self.user.searches.count-1)-indexPath.row];
                
                //reload table view data
                [self.tableView reloadData];

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                NSLog(@"%@", operation.responseObject);

            }];
        }
        
    }
    
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    
    //get place from query result
    return [searchResultPlaces objectAtIndex:indexPath.row];
    
}

- (void)handleSearchForSearchString:(NSString *)searchString {
    
    //query places based on search string
    searchQuery.location = self.user.userLocation;
    searchQuery.input = searchString;
    
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        
        if (error) {
            
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
            
        } else {
            
            //save query results
            searchResultPlaces = nil;
            searchResultPlaces = places;
            
            //reload table view data
            [self.tableView reloadData];
            
        }
        
    }];
    
}

- (void) parseAddress:(NSString *)addressString {
    
    //format address
    for(int i = 0; i < addressString.length; i++){
        
        //find first occurance of "," and separate first half into addressTitle and other half into addresSubtitle
        if([[addressString substringWithRange:NSMakeRange(i, 1)] isEqualToString:@","]) {
            
            addressTitle = [addressString substringWithRange:NSMakeRange(0, i)];
            addressSubtitle = [addressString substringWithRange:NSMakeRange(i+2, addressString.length-i-2)];
            break;
            
        }
        
    }
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.frame withMessage:alert];
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    self.customAlert.customAlertDelegate = self;
    
    //add as subview and make alpha 1.0
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//custom alert object left button delegate method
- (void)leftActionMethod:(int)method {
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    //nothing for now
    
}

@end
