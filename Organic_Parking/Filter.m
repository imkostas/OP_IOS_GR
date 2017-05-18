//
//  Filter.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Filter.h"

@interface Filter ()

@end

@implementation Filter

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    NSLog(@"From Filter SCREEN = %f x %f",self.view.bounds.size.width, self.view.bounds.size.height);
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.topBar.bounds.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.size.height - self.topBarTitle.bounds.size.height, self.view.bounds.size.width, self.topBarTitle.bounds.size.height)];
    [self.clearFiltersBtn setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.size.height - self.clearFiltersBtn.bounds.size.height, self.clearFiltersBtn.bounds.size.width, self.clearFiltersBtn.bounds.size.height)];
    [self.updateFiltersBtn setFrame:CGRectMake(self.view.bounds.size.width - self.updateFiltersBtn.bounds.size.width, self.topBar.bounds.size.height - self.updateFiltersBtn.bounds.size.height, self.updateFiltersBtn.bounds.size.width, self.updateFiltersBtn.bounds.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.topBar.bounds.size.height)];
    [self.timeFilterView setFrame:CGRectMake(self.scrollView.bounds.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.timeFilterView.bounds.size.height)];
    [self.setTimeFilterView setFrame:self.view.bounds];
    [self.setTimeFilterViewContents setFrame:CGRectMake(self.view.bounds.size.width/2 - self.setTimeFilterViewContents.bounds.size.width/2, self.setTimeFilterView.bounds.size.height/2 - self.setTimeFilterViewContents.bounds.size.height/2, self.setTimeFilterViewContents.bounds.size.width, self.setTimeFilterViewContents.bounds.size.height)];
    
    
}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //set scroll view delegate and content size
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(MAX_WIDTH, 284)];
    
    //add custom thumb image to slider
    [self.slider setThumbImage:[UIImage imageNamed:@"pending_pin_circle_plain"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"pending_pin_circle_plain"] forState:UIControlStateHighlighted];
    
    //hide date picker from view until user wants to set time filter
    [self.setTimeFilterView setAlpha:0.0f];
 
}

- (void)viewWillAppear:(BOOL)animated {
    
    //if existing filter, load that data - otherwise, load current time
    if(self.user.filter.date && self.user.filter.date == [self.user.filter.date laterDate:[NSDate date]]){
        
        [self.timeLabel setText:self.user.filter.time];
        [self.dayLabel setText:self.user.filter.dateInfo];
        [self.ampmLabel setText:self.user.filter.ampm];
        
        [self.datePicker setDate:self.user.filter.date];
        
    } else {
        
        //create date formatter to extract particular data from current time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"EEEE"];
        NSString *startDayOfWeek = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
        [dateFormatter setDateFormat:@"MMM"];
        NSString *startMonth = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
        [dateFormatter setDateFormat:@"d"];
        NSString *startDay = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
        [dateFormatter setDateFormat:@"a"];
        NSString *startAMPM = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
        [self.ampmLabel setText:startAMPM];
        [dateFormatter setDateFormat:@"h:mm"];
        [self.timeLabel setText:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]]];
        
        self.dayLabel.text = [NSString stringWithFormat:@"%@, %@ %@",startDayOfWeek, startMonth, startDay];
        
        [self.user.filter setDateInfo:self.dayLabel.text];
        [self.user.filter setTime:self.timeLabel.text];
        [self.user.filter setAmpm:self.ampmLabel.text];
        
        [self.datePicker setDate:[NSDate date]];
        
    }
    
    //set slider and window values
    self.slider.value = (self.user.filter.window == 1) ? 0 : self.user.filter.window;
    [self.searchWindow setText:[NSString stringWithFormat:@"%i minutes", (int)self.slider.value]];
    
    //properly center time and ampm
    CGFloat timeWidth = [[[NSAttributedString alloc] initWithString:self.timeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:60]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    CGFloat ampmWidth = [[[NSAttributedString alloc] initWithString:self.ampmLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:17]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    [self.timeLabel setFrame:CGRectMake(self.timeFilterView.frame.size.width/2 - timeWidth/2 - ampmWidth/2, self.timeLabel.frame.origin.y, timeWidth, 50)];
    [self.ampmLabel setFrame:CGRectMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width, self.ampmLabel.frame.origin.y, ampmWidth, 20)];
    
}




- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)clearFilters:(id)sender {
    
    //clear filter and dismiss
    self.user.shouldRefreshMapPins = YES;
    self.user.filter = [[DateFilter alloc] init];
    
    self.user.postDetails = 0;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)updateFilters:(id)sender {
    
    self.user.shouldRefreshMapPins = YES;
    
    if(self.user.postDetails <= 0){
        [self customAlert:@"Your search needs a category" withDone:@"OK"];
        return;
    }

    
    //dismiss view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)setTimeFilter:(id)sender {
    
    //unhide date picker view so user can set time filter
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.setTimeFilterView setAlpha:1.0f];
        
    }];
    
}

- (IBAction)cancelTimeFilter:(id)sender {
    
    //hide date picker view
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.setTimeFilterView setAlpha:0.0f];
        
    }];
    
}

- (IBAction)updateTimeFilter:(id)sender {
    
    //get date from date picker and extract info from formatted date
    NSDate *date = [self.datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *startDayOfWeek = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    [dateFormatter setDateFormat:@"MMM"];
    NSString *startMonth = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    [dateFormatter setDateFormat:@"d"];
    NSString *startDay = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    [dateFormatter setDateFormat:@"a"];
    NSString *startAMPM = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    [dateFormatter setDateFormat:@"h:mm"];
    
    //update view objects with new date filter info
    [self.ampmLabel setText:startAMPM];
    [self.timeLabel setText:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]]];
    self.dayLabel.text = [NSString stringWithFormat:@"%@, %@ %@",startDayOfWeek, startMonth, startDay];
    
    //save date filter info to user info
    [self.user.filter setIsActive:YES];
    [self.user.filter setDate:[self.datePicker date]];
    [self.user.filter setDateInfo:self.dayLabel.text];
    [self.user.filter setTime:self.timeLabel.text];
    [self.user.filter setAmpm:self.ampmLabel.text];
    
    //properly center time and ampm
    CGFloat timeWidth = [[[NSAttributedString alloc] initWithString:self.timeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:60]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    CGFloat ampmWidth = [[[NSAttributedString alloc] initWithString:self.ampmLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:17]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    [self.timeLabel setFrame:CGRectMake(self.timeFilterView.frame.size.width/2 - timeWidth/2 - ampmWidth/2, self.timeLabel.frame.origin.y, timeWidth, 50)];
    [self.ampmLabel setFrame:CGRectMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width, self.ampmLabel.frame.origin.y, ampmWidth, 20)];
    
    //hide date picker view
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.setTimeFilterView setAlpha:0.0f];
        
    }];
    
}

- (IBAction)updateSearchWindow:(id)sender {
    
    //calculate snap value to the nearest factor of 5
    int snapValue = (int)(nearbyint(self.slider.value/5)*5);
    
    //if changed window value, update searchWindow text in view and save new filter info to user info
    if(snapValue != self.user.filter.window){
        
        self.searchWindow.text = [NSString stringWithFormat:@"%i minutes", snapValue];
        [self.user.filter setIsActive:YES];
        [self.user.filter setDate:[self.datePicker date]];
        [self.user.filter setDateInfo:self.dayLabel.text];
        [self.user.filter setTime:self.timeLabel.text];
        [self.user.filter setAmpm:self.ampmLabel.text];
        [self.user.filter setWindow:snapValue];
        
    }
 
}

- (IBAction)postVehicle:(id)sender {
    
    //turn it on and everything else off
    [self.postVehicle setBackgroundImage:[UIImage imageNamed:@"Vehicle Active"] forState:UIControlStateNormal];
    [self.vehicleLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    self.user.postDetails = 1;
    
    [self.postSeat setBackgroundImage:[UIImage imageNamed:@"Seat Inactive"] forState:UIControlStateNormal];
    [self.seatLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
    [self.postStand setBackgroundImage:[UIImage imageNamed:@"Stand Inactive"] forState:UIControlStateNormal];
    [self.standLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
    
}

- (IBAction)postSeat:(id)sender {
    
    //turn it on and everything else off
    
    [self.postSeat setBackgroundImage:[UIImage imageNamed:@"Seat Active"] forState:UIControlStateNormal];
    [self.seatLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    self.user.postDetails = 2;
    
    [self.postVehicle setBackgroundImage:[UIImage imageNamed:@"Vehicle Inactive"] forState:UIControlStateNormal];
    [self.vehicleLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
    [self.postStand setBackgroundImage:[UIImage imageNamed:@"Stand Inactive"] forState:UIControlStateNormal];
    [self.standLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
}

- (IBAction)postStand:(id)sender {
    
    //turn it on and everything else off
    
    [self.postStand setBackgroundImage:[UIImage imageNamed:@"Stand Active"] forState:UIControlStateNormal];
    [self.standLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    self.user.postDetails = 3;
    
    [self.postVehicle setBackgroundImage:[UIImage imageNamed:@"Vehicle Inactive"] forState:UIControlStateNormal];
    [self.vehicleLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
    [self.postSeat setBackgroundImage:[UIImage imageNamed:@"Seat Inactive"] forState:UIControlStateNormal];
    [self.seatLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
    
    
}


//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.frame withMessage:alert];
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    self.customAlert.customAlertDelegate = self;
    
    //add as subview and make alpha 1.0
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//custom alert object left button delegate method
- (void)leftActionMethod:(int)method {
    
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    switch (method) {
        case 0:
            [self hideAlert];
            
            break;
        case 1:
            //post log out notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
            break;
    }
    
    
}

-(void)hideAlert {
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
}

@end
