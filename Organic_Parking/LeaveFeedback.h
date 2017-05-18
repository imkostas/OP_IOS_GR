//
//  Feedback.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeyboardControls.h"

@interface LeaveFeedback : UIViewController <UIScrollViewDelegate, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *backBtn; //dismisses view
@property (strong, nonatomic) IBOutlet UIButton *submitBtn; //submits rating

//view contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold view contents
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIImageView *swappedWithImage; //displays swapper profile image
@property (strong, nonatomic) IBOutlet UILabel *swappedWithLabel; //displays swapper username
@property (strong, nonatomic) IBOutlet UIButton *recommendNoBtn; //sets recommendation to no
@property (strong, nonatomic) IBOutlet UIButton *recommendYesBtn; //sets recommendation to yes
@property (strong, nonatomic) IBOutlet UIView *starView; //holds star rating images
@property (strong, nonatomic) IBOutlet UIImageView *starImageOne; //indicates a rating of one star
@property (strong, nonatomic) IBOutlet UIImageView *starImageTwo; //indicates a rating of two stars
@property (strong, nonatomic) IBOutlet UIImageView *starImageThree; //indicates a rating of three stars
@property (strong, nonatomic) IBOutlet UIImageView *starImageFour; //indicates a rating of four stars
@property (strong, nonatomic) IBOutlet UIImageView *starImageFive; //indicates a rating of five stars

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic, strong) NSThread *updateRaterImg; //thread for fetching rate image
@property (nonatomic) int rating; //indicates number of stars given
@property (nonatomic) int recommended; //indicates recommended or not

@end
