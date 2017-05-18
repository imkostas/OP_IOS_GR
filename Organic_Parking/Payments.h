//
//  Payments.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "DetailPaymentCell.h"
#import "DetailPaymentExpiredCell.h"
#import "AddPaymentCell.h"
#import "NoFundingSourceHeader.h"
#import "LinkedFundingSourceHeader.h"
#import "NoPaymentMethodHeader.h"
#import "LinkedPaymentMethodHeader.h"
#import "PaymentMethod.h"

@interface Payments : UIViewController <CustomAlertDelegate, BTDropInViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *cancelViewBtn; //dismisses view

//tableview
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NoFundingSourceHeader *noFundingSourceHeader;
@property (nonatomic, strong) LinkedFundingSourceHeader *linkedFundingSourceHeader;
@property (nonatomic, strong) NoPaymentMethodHeader *noPaymentMethodHeader;
@property (nonatomic, strong) LinkedPaymentMethodHeader *linkedPaymentMethodHeader;

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic, strong) UIRefreshControl *refreshControl; //refresh control for payment methods
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic) int rowToDelete;

@end
