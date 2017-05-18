//
//  Search.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "SearchCell.h"

@interface Search : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CustomAlertDelegate>

//search view contents
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar; //search bar for entering search location
@property (strong, nonatomic) IBOutlet UIButton *cancelSearchBtn; //dismisses search view
@property (strong, nonatomic) IBOutlet UITableView *tableView; //table view for listing search results

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
