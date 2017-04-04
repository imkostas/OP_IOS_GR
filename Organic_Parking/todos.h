//
//  todos.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface todos : UIViewController <UITableViewDataSource, UITableViewDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *backBtn; //dismisses view

//table view for displaying profile details left to complete
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) NSMutableArray *todos; //lists profile details left to complete

@end
