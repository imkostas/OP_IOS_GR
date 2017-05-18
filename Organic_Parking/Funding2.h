//
//  Funding2.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeyboardControls.h"
#import "SubMerchant.h"

@interface Funding2 : UIViewController <KeyboardControlDelegate, CustomAlertDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *topBar;
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIButton *accountBtn;

@property (strong, nonatomic) IBOutlet UITextField *venmo;
@property (strong, nonatomic) IBOutlet UITextField *routingNumber;
@property (strong, nonatomic) IBOutlet UITextField *accountNumber;

@property (nonatomic, strong) UserInfo *user;
@property (nonatomic, strong) KeyboardControls *keyboardControls;
@property (nonatomic, strong) CustomAlert *customAlert;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) SubMerchant *subMerchant;

@end
