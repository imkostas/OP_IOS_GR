//
//  LogIn.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeychainItemWrapper.h"

@interface LogIn : UIViewController <UITextFieldDelegate, CustomAlertDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *logoOuter;
@property (strong, nonatomic) IBOutlet UIImageView *logoInnerLoader;
@property (strong, nonatomic) IBOutlet UIImageView *logoInnerSolid;
@property (strong, nonatomic) IBOutlet UIImageView *textImage; //displays logo text

@property (strong, nonatomic) IBOutlet UIView *foreground; //view contains username and password entry textfields

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField; //for entering username textfield
@property (strong, nonatomic) IBOutlet UITextField *pass1TextField; //for entering password textfield
@property (strong, nonatomic) IBOutlet UIButton *loginButton; //button for validating user credentials and segues to main view

@property (strong, nonatomic) IBOutlet UIButton *createAccount; //segues to create account view
@property (strong, nonatomic) IBOutlet UIButton *forgotPassword; //segues to forgotten password view
@property (strong, nonatomic) IBOutlet UILabel *bullet; //bullet for spacing

@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic, strong) NSTimer *timer; //timer to launch after one second
@property (nonatomic, strong) CABasicAnimation *rotateAnimation;

@end
