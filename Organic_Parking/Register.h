//
//  Register.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeyboardControls.h"

@interface Register : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, KeyboardControlDelegate, CustomAlertDelegate>


//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //view title
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn; //cancel view button
@property (strong, nonatomic) IBOutlet UIButton *createBtn; //create account button

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold contents of view
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UITextField *username; //username textfield
@property (strong, nonatomic) IBOutlet UITextField *password; //password textfield
@property (strong, nonatomic) IBOutlet UITextField *email; //email textfield

//view variables
@property (nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) KeyboardControls *keyboardControls; //keyboard controls
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
