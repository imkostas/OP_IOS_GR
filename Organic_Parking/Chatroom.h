//
//  Chatroom.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface Chatroom : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *cancelViewBtn; //dismisses view

//table view to list chat dialog
@property (strong, nonatomic) IBOutlet UITableView *tableView; //table view for holding message contents
@property (strong, nonatomic) IBOutlet UILabel *divider;
@property (strong, nonatomic) IBOutlet UIView *messageView; //view for styling message
@property (strong, nonatomic) IBOutlet UITextField *messageTextfield; //for entering message to send
@property (strong, nonatomic) IBOutlet UIButton *sendMessageBtn; //sends message

//view variables
@property (nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic) BOOL currentlySendingMessage; //indicates if message is currently being sent

@end
