//
//  Chat.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface Chat : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //topr bar title
@property (strong, nonatomic) IBOutlet UIButton *cancelViewBtn; //dismisses view

//table view for displaying chat rooms
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//view variables
@property (nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
