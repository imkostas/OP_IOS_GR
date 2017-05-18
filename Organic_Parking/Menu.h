//
//  Menu.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MainViewController.h"
#import "UserInfo.h"

@interface Menu : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate, CustomAlertDelegate>

//menu
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold the contents of menu
@property (strong, nonatomic) IBOutlet UIView *menuTopView; //menu top bar
@property (strong, nonatomic) IBOutlet UIView *settingsView; //view to hold the contents of settings
@property (strong, nonatomic) IBOutlet UIView *helpView; //view to hold the contents of help
@property (strong, nonatomic) IBOutlet UIView *logoutView; //view to log out

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIImageView *logoText;

@property (strong, nonatomic) IBOutlet UILabel *statusPlaceholder;
@property (strong, nonatomic) IBOutlet UILabel *statusDivider;
@property (strong, nonatomic) IBOutlet UILabel *divider0;

//settings
@property (strong, nonatomic) IBOutlet UIButton *settingsBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider1;
@property (strong, nonatomic) IBOutlet UIButton *profileBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider2;
@property (strong, nonatomic) IBOutlet UIButton *paymentBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider3;
@property (strong, nonatomic) IBOutlet UIButton *changePasswordBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider4;

//help
@property (strong, nonatomic) IBOutlet UIButton *helpBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider5;
@property (strong, nonatomic) IBOutlet UIButton *tutorialBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider6;
@property (strong, nonatomic) IBOutlet UIButton *faqsBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider7;
@property (strong, nonatomic) IBOutlet UIButton *contactBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider8;
@property (strong, nonatomic) IBOutlet UIButton *rateBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider9;
@property (strong, nonatomic) IBOutlet UIButton *termsPrivacyBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider10;

//log out
@property (strong, nonatomic) IBOutlet UIButton *logOutBtn;
@property (strong, nonatomic) IBOutlet UILabel *divider11;

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
