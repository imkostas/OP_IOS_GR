//
//  Profile.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "KeyboardControls.h"

@interface Profile : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, KeyboardControlDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn; //dismisses view
@property (strong, nonatomic) IBOutlet UIButton *saveBtn; //segues to edit profile info view

//profile view background
@property (strong, nonatomic) IBOutlet UIImageView *profileImageLarge; //displays large profie image
@property (strong, nonatomic) IBOutlet UIImageView *whiteShadow; //white alpha masking

//car color selection view
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerContainer;
@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;

//profile scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold profile contents
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage; //current profile image
@property (strong, nonatomic) IBOutlet UILabel *username; //username
@property (strong, nonatomic) IBOutlet UILabel *email; //email
@property (strong, nonatomic) IBOutlet UITextField *make;
@property (strong, nonatomic) IBOutlet UITextField *model;
@property (strong, nonatomic) IBOutlet UILabel *color;
@property (strong, nonatomic) IBOutlet UIButton *compact;
@property (strong, nonatomic) IBOutlet UIButton *midsize;
@property (strong, nonatomic) IBOutlet UIButton *large;

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) KeyboardControls *keyboardControls; //keyboard controls
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic, strong) UITapGestureRecognizer *tap; //dismisses keyboard
@property (nonatomic, strong) UIImagePickerController *imagePicker; //used to select/take profile image
@property (nonatomic, strong) NSArray *arrayOfColors; //list of car colors

@end
