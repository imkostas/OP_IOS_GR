//
//  Post.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeyboardControls.h"
#import "MainViewController.h"

@interface Post : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, KeyboardControlDelegate, UIAlertViewDelegate, CustomAlertDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *postBackground; //posting view background image
@property (weak, nonatomic) IBOutlet UIImageView *postBackgroundBottom;
@property (strong, nonatomic) IBOutlet UIPageControl *pageController; //displays stage in post process

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold view contents
@property (strong, nonatomic) IBOutlet UIView *postTimeContainer;
@property (strong, nonatomic) IBOutlet UIView *postPriceContainer;
@property (strong, nonatomic) IBOutlet UIView *postDetailsContainer;
@property (strong, nonatomic) IBOutlet UIView *postSpotContainer;
@property (strong, nonatomic) IBOutlet UILabel *postTime; //displays post time
@property (strong, nonatomic) IBOutlet UILabel *postMeridiems; //displays AM or PM
@property (strong, nonatomic) IBOutlet UILabel *postDate; //displays post date
@property (strong, nonatomic) IBOutlet UITextField *postPrice; //displays post price

@property (strong, nonatomic) IBOutlet UIButton *postVehicle; //set if post is vehicle or not
@property (strong, nonatomic) IBOutlet UILabel *vehicleLabel; //changes color when active
@property (strong, nonatomic) IBOutlet UIButton *postSeat; //set if post is seat or not
@property (strong, nonatomic) IBOutlet UILabel *seatLabel; //changes color when active
@property (strong, nonatomic) IBOutlet UIButton *postStand; //set if post is stand or not
@property (strong, nonatomic) IBOutlet UILabel *standLabel; //changes color when active

//view for setting post time
@property (strong, nonatomic) IBOutlet UIView *postTimeView; //view for holding contents of container view
@property (strong, nonatomic) IBOutlet UIView *postTimeContainerView; //view for holding date picker
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker; //used to select post time

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) KeyboardControls *keyboardControls; //keyboard controls
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
