//
//  FundingSource.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "KeyboardControls.h"
#import "Funding2.h"

@interface Funding1 : UIViewController <UIScrollViewDelegate, KeyboardControlDelegate, UITextFieldDelegate, CustomAlertDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *topBar;
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UITextField *firstName;
@property (strong, nonatomic) IBOutlet UITextField *lastName;
@property (strong, nonatomic) IBOutlet UILabel *dateOfBirth;
@property (strong, nonatomic) IBOutlet UITextField *streetAddress;
@property (strong, nonatomic) IBOutlet UITextField *city;

@property (strong, nonatomic) IBOutlet UITextField *zipCode;
@property (strong, nonatomic) IBOutlet UILabel *state;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerContainerView;
@property (strong, nonatomic) IBOutlet UILabel *pickerViewTitle;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *statePicker;

@property (nonatomic, strong) UserInfo *user;
@property (nonatomic, strong) KeyboardControls *keyboardControls;
@property (nonatomic, strong) CustomAlert *customAlert;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *defaultDate;
@property (nonatomic, strong) NSString *braintreeFormattedDate;
@property (nonatomic, strong) NSArray *states;

@end
