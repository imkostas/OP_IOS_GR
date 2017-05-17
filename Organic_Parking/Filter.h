//
//  Filter.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface Filter : UIViewController <UIScrollViewDelegate, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *clearFiltersBtn; //clears any set filters
@property (strong, nonatomic) IBOutlet UIButton *updateFiltersBtn; //saves set filters

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold contents of view
@property (strong, nonatomic) IBOutlet UIView *timeFilterView; //holds time filtering objects
@property (strong, nonatomic) IBOutlet UILabel *dayLabel; //displays day
@property (strong, nonatomic) IBOutlet UILabel *timeLabel; //displays time
@property (strong, nonatomic) IBOutlet UILabel *ampmLabel; //displays AM or PM
@property (strong, nonatomic) IBOutlet UISlider *slider; //slider for adjusting search window
@property (strong, nonatomic) IBOutlet UILabel *searchWindow; //displays search window

@property (strong, nonatomic) IBOutlet UIButton *postMeter; //set if post is metered or not
@property (strong, nonatomic) IBOutlet UILabel *meterLabel; //changes color when active
@property (strong, nonatomic) IBOutlet UIButton *postPermit; //set if post requires permit or not
@property (strong, nonatomic) IBOutlet UILabel *permitLabel; //changes color when active
@property (strong, nonatomic) IBOutlet UIButton *postTimeLimit; //set if post has time limit or not
@property (strong, nonatomic) IBOutlet UILabel *timeLimitLabel; //changes color when active


//view for setting time to filter by
@property (strong, nonatomic) IBOutlet UIView *setTimeFilterView; //view to hold contents of filter view contents
@property (strong, nonatomic) IBOutlet UIView *setTimeFilterViewContents; //view to hold date picker
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker; //for selecting time to filter by

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
