//
//  Post.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Post.h"

@interface Post () {
    
    BOOL postHasMeter; //indicates post is metered
    BOOL postHasPermit; //indicates post needs permit
    BOOL postHasTimeLimit; //indicates post has time limit
    BOOL isPostingSpot; //indicates currently posting spot
    
    int postDetails; //used for calculating details of post
    
}

@end

@implementation Post

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
//    CGRect newFrame = self.view.frame;
//    newFrame.size.width = 320;
//    newFrame.origin.x = super.view.bounds.size.width/2 - 320/2;
//    [self.view setFrame:newFrame];
  
    //position view objects
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.scrollView.frame.size.height)];
    [self.postTimeView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.postTimeContainerView setFrame:CGRectMake(self.postTimeView.frame.size.width/2 - self.postTimeContainerView.frame.size.width/2, self.postTimeView.frame.size.height/2 - self.postTimeContainerView.frame.size.height/2, self.postTimeContainerView.frame.size.width, self.postTimeContainerView.frame.size.height)];
    [self.postBackground setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.postBackground.frame.size.height)];
    [self.postBackgroundBottom setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, self.postBackground.frame.size.height, MAX_WIDTH, self.postBackgroundBottom.frame.size.height)];
    [self.postTimeContainer setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.postTimeContainer.frame.size.height)];
    [self.postPriceContainer setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.postPriceContainer.frame.size.height)];
    [self.postDetailsContainer setFrame:CGRectMake(self.view.frame.size.width*2 + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.postDetailsContainer.frame.size.height)];
    [self.postSpotContainer setFrame:CGRectMake(self.view.frame.size.width*3 + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.postSpotContainer.frame.size.height)];
    [self.pageController setFrame:CGRectMake(0, self.pageController.frame.origin.y, self.view.frame.size.width, self.pageController.frame.size.height)];
#ifdef DEBUG
    NSLog(@"From Post SCREEN (x,y) = %2.2f,%2.2f  (swxw) = %2.2f x %2.2f",self.view.frame.origin.x, self.view.frame.origin.y, super.view.bounds.size.width, self.view.frame.size.width);
#endif
    //initialize view objects
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, 197);

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    
    //initialize keyboard controls
    self.keyboardControls = [[KeyboardControls alloc] init];
    
    [self.postPrice setTextColor:OP_PINK_COLOR];
    [self.postPrice setTintColor:OP_PINK_COLOR];
    
    //initialize view variables
    postHasMeter = NO;
    postHasPermit = NO;
    postHasTimeLimit = NO;
    isPostingSpot = NO;
    postDetails = 0;
    
    //set delegates
    self.scrollView.delegate = self;
    self.keyboardControls.delegate = self;
    self.postPrice.delegate = self;
    
    //initialize view objects
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, 197);
    
    self.pageController.currentPage = 0;
    self.postTimeView.alpha = 0.0f;
    
    //create and initialize gestures for telling when to cancel post
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPostTap:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPostPan:)];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPostPinch:)];
    
    UITapGestureRecognizer *tapDateTimeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDateTimePicker:)];
    
    //add gestures to view
    [self.view addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:panGesture];
    [self.view addGestureRecognizer:pinchGesture];
    [self.postTimeView addGestureRecognizer:tapDateTimeGesture];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //reposition view objects if previously canceled mid-post
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 197, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self.postTimeView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.postTimeContainerView setFrame:CGRectMake(self.postTimeView.frame.size.width/2 - self.postTimeContainerView.frame.size.width/2, self.postTimeView.frame.size.height/2 - self.postTimeContainerView.frame.size.height/2, self.postTimeContainerView.frame.size.width, self.postTimeContainerView.frame.size.height)];
    
    //scroll scroll view to first page
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 197) animated:NO];
    
    //initialize post date to current date
    [self.datePicker setDate:[NSDate date]];
    [self.datePicker setMinimumDate:[NSDate date]];
    
    //make sure data and time are properly positioned
    [self formatPostTimeAndDate];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    //move self.view below the scroll view for proper gesture detection
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 197, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        [self showDateTimePicker];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //add keyboard controls to keyboard input accessory view
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:NO]];
    
}

- (void)previousPressed {
    
    //nothing for now
    
}

- (void)nextPressed {
    
    //nothing for now
    
}

- (void)donePressed {
    
    //dismiss keyboard
    [self.postPrice resignFirstResponder];
    
}

- (void)noAccount {
    
    //setup alert and ask user to confirm log out action
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame withMessage:@"You need to login or create an account"];
    
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"Later" forState:UIControlStateNormal];
    
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Now" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:1];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (void)cancelAlert {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //if user wants to cancel post, alert them with this message to confirm they really want to cancel
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame withMessage:@"Cancel this post?"];
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:0];
    
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //update pageController with current page
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    self.pageController.currentPage = page;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if(self.pageController.currentPage == 1){
        
        if(!self.postPrice.isFirstResponder)[self.postPrice becomeFirstResponder];
        
    } else {
        
        //dismiss keyboard if active
        [self donePressed];
        
    }
    
}

- (void)dismissView {
    
    //dismiss keyboard if active
    [self donePressed];
    
    //call parent method to perform certain actions
    [(MainViewController *)self.parentViewController dismissedPostView];
    
    //hide view and remove from parent
    [UIView animateWithDuration:0.25f animations:^{
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 197, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        //indicate no longer posting spot
        isPostingSpot = NO;
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
    
}

- (void)cancelPostTap:(UIGestureRecognizer *)recognizer {
    
    //if user tapped on self.view, show cancel alert
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
    if(tap.state == UIGestureRecognizerStateEnded && !isPostingSpot){
        
        if([tap locationInView:self.view].y > self.scrollView.frame.size.height){
            
            [self.postPrice resignFirstResponder];
            [self cancelAlert];
            
        }
        
    }
    
}

- (void)cancelPostPan:(UIGestureRecognizer *)recognizer {
    
    //if user panned on self.view, show cancel alert
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
    if(pan.state == UIGestureRecognizerStateBegan && !isPostingSpot){
        
        if([pan translationInView:self.view].y > self.scrollView.frame.size.height){
            
            [self.postPrice resignFirstResponder];
            [self cancelAlert];
            
        }
        
    }
    
}

- (void)cancelPostPinch:(UIGestureRecognizer *)recognizer {
    
    //if user pinched on self.view, show cancel alert
    UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)recognizer;
    if(pinch.state == UIGestureRecognizerStateBegan && !isPostingSpot){
        
        [self.postPrice resignFirstResponder];
        [self cancelAlert];
        
    }
    
}

- (IBAction)showPostTimePicker:(id)sender {
    
    [self showDateTimePicker];
    
}

- (void)showDateTimePicker {
    
    //unhide post date/time setter
    [self.postTimeView setFrame:self.view.frame];
    [UIView animateWithDuration:0.2 animations:^{
        
        self.postTimeView.alpha = 1.0f;
        
    }];
    
}

- (IBAction)cancelPostTimePicker:(id)sender {
    
    //hide post date/time setter
    [UIView animateWithDuration:0.2 animations:^{
        
        self.postTimeView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.postTimeView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        
    }];
    
}

- (void)dismissDateTimePicker:(UIGestureRecognizer *)recognizer {
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
    if(tap.state == UIGestureRecognizerStateEnded && !isPostingSpot){
        
        if([tap locationInView:self.postTimeView].y < self.postTimeContainerView.frame.origin.y ||
           [tap locationInView:self.postTimeView].x < self.postTimeContainerView.frame.origin.x ||
           [tap locationInView:self.postTimeView].y > (self.postTimeContainerView.frame.origin.y + self.postTimeContainerView.frame.size.height) ||
           [tap locationInView:self.postTimeView].x > (self.postTimeContainerView.frame.origin.x + self.postTimeContainerView.frame.size.width)){
            
            //hide post date/time setter
            [UIView animateWithDuration:0.2 animations:^{
                
                self.postTimeView.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                [self.postTimeView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
                
            }];
            
        }
        
    }
    
}

- (void)formatPostTimeAndDate {
    
    //use date formatter to extract parts of date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *startDayOfWeek = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.datePicker.date]];
    [dateFormatter setDateFormat:@"MMM"];
    NSString *startMonth = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.datePicker.date]];
    [dateFormatter setDateFormat:@"d"];
    NSString *startDay = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.datePicker.date]];
    [self.postDate setText:[NSString stringWithFormat:@"%@, %@ %@",startDayOfWeek, startMonth, startDay]];
    [dateFormatter setDateFormat:@"a"];
    NSString *startAMPM = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.datePicker.date]];
    [self.postMeridiems setText:startAMPM];
    [dateFormatter setDateFormat:@"h:mm"];
    NSString *startTimeVal = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.datePicker.date]];
    [self.postTime setText:startTimeVal];
    
    //calculate size of time and ampm
    CGFloat timeWidth = [[[NSAttributedString alloc] initWithString:startTimeVal attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:60]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    CGFloat ampmWidth = [[[NSAttributedString alloc] initWithString:startAMPM attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:17]}] boundingRectWithSize:CGSizeMake(230.0f, 99.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    //use calculated size to properly center objects
    [self.postTime setFrame:CGRectMake(MAX_WIDTH/2 - timeWidth/2 - ampmWidth/2, self.scrollView.frame.origin.y + 45, timeWidth, 48)];
    [self.postMeridiems setFrame:CGRectMake(self.postTime.frame.origin.x + self.postTime.frame.size.width, self.postTime.frame.origin.y - 2, ampmWidth, 21)];
    
}

- (IBAction)setPostTimePicker:(id)sender {
    
    //format selected post date/time
    [self formatPostTimeAndDate];
    
    //hide post date/time view
    [UIView animateWithDuration:0.2 animations:^{
        
        self.postTimeView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.postTimeView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        
    }];
    
}

- (IBAction)postMeter:(id)sender {
    
    //if post already has meter, turn it off - otherwise, turn it on
    if(postHasMeter){
        
        [self.postMeter setBackgroundImage:[UIImage imageNamed:@"Meter Inactive"] forState:UIControlStateNormal];
        [self.meterLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
        postHasMeter = false;
        postDetails -= 4;
        
    } else {
        
        [self.postMeter setBackgroundImage:[UIImage imageNamed:@"Meter Active"] forState:UIControlStateNormal];
        [self.meterLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
        postHasMeter = true;
        postDetails += 4;
        
    }
    
}

- (IBAction)postPermit:(id)sender {
    
    //if post already has permit, turn it off - otherwise, turn it on
    if(postHasPermit){
        
        [self.postPermit setBackgroundImage:[UIImage imageNamed:@"Permit Inactive"] forState:UIControlStateNormal];
        [self.permitLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
        postHasPermit = false;
        postDetails -= 2;
        
    } else {
        
        [self.postPermit setBackgroundImage:[UIImage imageNamed:@"Permit Active"] forState:UIControlStateNormal];
        [self.permitLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
        postHasPermit = true;
        postDetails += 2;
        
    }
    
}

- (IBAction)postTimeLimit:(id)sender {
    
    //if post alredy has time limit, turn it off - otherwise, turn it on
    if(postHasTimeLimit){
        
        [self.postTimeLimit setBackgroundImage:[UIImage imageNamed:@"Time Inactive"] forState:UIControlStateNormal];
        [self.timeLimitLabel setTextColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0]];
        postHasTimeLimit = false;
        postDetails -= 1;
        
    } else {
        
        [self.postTimeLimit setBackgroundImage:[UIImage imageNamed:@"Time Active"] forState:UIControlStateNormal];
        [self.timeLimitLabel setTextColor:[UIColor colorWithRed:1.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
        postHasTimeLimit = true;
        postDetails += 1;
        
    }
    
}

- (BOOL)isNumeric:(NSString*) checkText{
    
    //check that post price numeric
    //even though keyboard only allows numbers to be entered, user could have pasted non-numeric values into textfield
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:checkText];
    
    if (number != nil) {
        //NSLog(@"Price is = $%@ ",number);
        return true;
        
    }
    
    return false;
    
}

- (IBAction)postSpot:(id)sender {
    
    //indicate in the process of posting a spot
    isPostingSpot = YES;
    
    if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        //no account? stay or logout/create a new account
        [self noAccount];
        return;
    }
    else if(!self.user.vehicle.hasVehicle) {
        self.user.code = MISSING_VEHICLE;
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
        [self presentViewController:viewController animated:YES completion:nil];
        return;
    }

    //FREE POST (NO PAYMENT METHOD REQUIRED) IF PRICE IS 0
   if([self.postPrice.text floatValue] == 0.){
       ;
    }
   else if ( ( [self.user.braintree.subMerchant.status isEqual:[NSNull null]] ) && [self.postPrice.text floatValue] > 0.) {
       self.user.code = MISSING_FUNDING_SOURCE;
       MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
       [self presentViewController:viewController animated:YES completion:^{}];
       [self dismissView];
       return;
   }
    else if(![self.user.braintree.subMerchant.status isEqualToString:@"active"]) {
        self.user.code = MISSING_FUNDING_SOURCE;
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
        [self presentViewController:viewController animated:YES completion:^{}];
        [self dismissView];
        return;
    }


    //check that post price is valid
    if([self isNumeric:self.postPrice.text]){
        
        //create HUD
        [UserInfo createHUD:self.view withOffset:(self.view.frame.size.height/-2) + 130];
        
        //initialize a date formatter to set date picker time to UTC
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.user.apiKey, @"api_key", self.user.username, @"p_username",
                                [NSString stringWithFormat:@"%f", self.user.postCoordinate.latitude], @"latitude",
                                [NSString stringWithFormat:@"%f", self.user.postCoordinate.longitude], @"longitude",
                                [dateFormatter stringFromDate:self.datePicker.date], @"swap_time",
                                self.postPrice.text, @"price", [NSString stringWithFormat:@"%i", postDetails], @"details",
                                self.user.postAddress, @"address", self.user.postCityRegion, @"city_region", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@addPost", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  //indicate pins should be refreshed
                  [self.user setShouldRefreshMapPins:YES];
                  
                  //dismiss view
                  [self dismissView];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                      
                  } else {
                      
                      [self customAlert:@"We were unable to post your spot" withDone:@"Ok"];
                      
                  }
                  
                  NSLog(@"%@", operation.responseObject);
                  NSLog(@"%@", operation.response);
                  NSLog(@"%li", (long)operation.response.statusCode);
                  NSLog(@"%@", error);
                  
              }];
        
    } else {
        
        [self customAlert:@"Your post needs a price" withDone:@"Ok"];
        
    }
    
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
    
    //indicate no longer posting spot
    isPostingSpot = NO;
    
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
        [self dismissView];
        
    }];
}

@end
