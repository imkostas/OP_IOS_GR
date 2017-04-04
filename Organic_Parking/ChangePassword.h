//
//  ChangePassword.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "KeyboardControls.h"

@interface ChangePassword : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, KeyboardControlDelegate, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn; //dismisses view
@property (strong, nonatomic) IBOutlet UIButton *saveBtn; //saves new password

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold contents of view
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UITextField *currentPassword; //for entering current password
@property (strong, nonatomic) IBOutlet UITextField *profilePasswordNew; //for entering new password
@property (strong, nonatomic) IBOutlet UITextField *confirmProfilePassword; //for confirming new password

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) KeyboardControls *keyboardControls; //keyboard controls
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
