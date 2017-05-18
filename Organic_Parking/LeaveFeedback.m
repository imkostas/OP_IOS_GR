//
//  Feedback.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "LeaveFeedback.h"

@interface LeaveFeedback ()

@end

@implementation LeaveFeedback

#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.bounds.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    [self.submitBtn setFrame:CGRectMake(self.view.bounds.size.width - self.submitBtn.frame.size.width, self.topBar.frame.size.height - self.submitBtn.frame.size.height, self.submitBtn.frame.size.width, self.submitBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    [self.container setFrame:CGRectMake(self.scrollView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, 491)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //set delegates
    self.scrollView.delegate = self;
    
    //initialize view variables
    self.rating = 0;
    self.recommended = -1;
    
    [self.view bringSubviewToFront:self.topBar];
    
    if(self.user.code == RATE_NOW){
        
        [self.backBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.backBtn setTitle:@"Cancel" forState:UIControlStateHighlighted];
        
    } else if (self.user.code == RATE_LATER){
        
        [self.backBtn setTitle:@"Later" forState:UIControlStateNormal];
        [self.backBtn setTitle:@"Later" forState:UIControlStateHighlighted];
        
    }
    
    //initialize view objects
    self.scrollView.contentSize = CGSizeMake(320, 491);
    [self.submitBtn setEnabled:NO];
    [self.submitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.swappedWithLabel.text = [self.user.feebackInfo.ratee uppercaseString];
    
    //initialize gesture recognizers
    UITapGestureRecognizer *tappedStarView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapStarView:)];
    UIPanGestureRecognizer *swipedStarView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanStarView:)];
    
    //add gesture recognizers to starView
    [self.starView addGestureRecognizer:tappedStarView];
    [self.starView addGestureRecognizer:swipedStarView];
    
    //initialize rating image
    [self.swappedWithImage.layer setCornerRadius:40.0f];
    if([self.user.userImages objectForKey:self.user.feebackInfo.ratee] != nil){
        
        self.swappedWithImage.image = [self.user.userImages objectForKey:self.user.feebackInfo.ratee];
        
    } else {
        
        self.updateRaterImg = [[NSThread alloc] initWithTarget:self selector:@selector(updateRaterImage) object:nil];
        [self.updateRaterImg start];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    if(self.user.code == RATE_NOW || self.user.code == RATE_LATER){
        
        self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.bounds withMessage:[NSString stringWithFormat:@"%@ has canceled their deal with you. Would you like to leave feedback?", self.user.feebackInfo.ratee]];
        [self.customAlert setTag:2];
        [self.customAlert.leftButton setBackgroundColor:OP_LIGHT_GRAY_COLOR];
        [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
        [self.customAlert.rightButton setBackgroundColor:OP_BLUE_COLOR];
        [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
        
        self.customAlert.customAlertDelegate = self;
        
        [self.view addSubview:self.customAlert];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
        
    }
    
}

- (void)didTapStarView:(UIGestureRecognizer*)recognizer {
    
    //if user tapped view, get the location of tap and calculate the appropriate star value
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)recognizer;
    
    if(tap.state == UIGestureRecognizerStateEnded){
        
        CGPoint tapPoint = [tap locationInView:self.starView];
        
        [self setStarRating:tapPoint.x];
        
        [self validSubmission];
        
    }
    
}

- (void)didPanStarView:(UIGestureRecognizer*)recognizer {
    
    //if user panned view, get changes in pan and calculate the appropriate star value
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
    
    if(pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint panPoint = [pan locationInView:self.starView];
        
        [self setStarRating:panPoint.x];
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self validSubmission];
        
    }
    
}

- (void)setStarRating:(float)x {
    
    //based on the gesture position, set the correct rating
    if(x < 40.0f) {
        
        [self.starImageOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        
        self.rating = 1;
        
    } else if(x < 80.0f && x >= 40.0f) {
        
        [self.starImageOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        
        self.rating = 2;
        
    } else if(x < 120.0f && x >= 80.0f) {
        
        [self.starImageOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starImageFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        
        self.rating = 3;
        
    } else if(x < 160.0f && x >= 120.0f) {
        
        [self.starImageOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        
        self.rating = 4;
        
    } else if(x >= 160.0f) {
        
        [self.starImageOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starImageFive setImage:[UIImage imageNamed:@"Star Blue"]];
        
        self.rating = 5;
        
    }
    
}

- (void)updateRaterImage {
    
    //fetch rater image
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", self.user.img_uri, self.user.feebackInfo.ratee]]]];
    
    //set swapped image to fetched image and add to cached images
    if(img){
        
        self.swappedWithImage.image = img;
        [self.user.userImages setObject:img forKey:self.user.feebackInfo.ratee];
        
    } else {
        
        NSLog(@"Failed to get rater image");
        //might want to set image to placeholder
        
    }
    
    [NSThread exit];
    
}

- (void)dismissView {
    
    //clear rating info and dismiss
    self.user.feebackInfo = [[Feedback alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)cancelView:(id)sender {
    
    if(self.user.code == RATE_NOW){
        
        [self noFeedback];
        
    } else {
        
        [self dismissView];
        
    }
    
}

- (void)noFeedback {
    
    //create HUD
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i", self.user.feebackInfo.postID], @"post_id",
                            self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@noFeedback", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //dismiss view
              [self dismissView];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:0];
                  
              } else {
                  
                  [self customAlert:@"Unable to leave feedback" withDone:@"OK" withTag:0];
                  
              }
              
          }];
    
}

- (IBAction)reccomendNo:(id)sender {
    
    //make NO active if selected and YES not active
    [self.recommendNoBtn setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.recommendNoBtn setBackgroundImage:[UIImage imageNamed:@"Clear"] forState:UIControlStateNormal];
    [self.recommendNoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.recommendYesBtn setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0]];
    [self.recommendYesBtn setBackgroundImage:[UIImage imageNamed:@"Recommend Outline"] forState:UIControlStateNormal];
    [self.recommendYesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    self.recommended = 0;
    [self validSubmission];
    
}

- (IBAction)recommendYes:(id)sender {
    
    //make YES active if selected and NO not active
    [self.recommendYesBtn setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.recommendYesBtn setBackgroundImage:[UIImage imageNamed:@"Clear"] forState:UIControlStateNormal];
    [self.recommendYesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.recommendNoBtn setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0]];
    [self.recommendNoBtn setBackgroundImage:[UIImage imageNamed:@"Recommend Outline"] forState:UIControlStateNormal];
    [self.recommendNoBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    self.recommended = 1;
    [self validSubmission];
    
}

- (void)validSubmission {
    
    //check if user can submit rating - must have stars and recommendation completed to submit - comments is optional
    if(self.recommended > -1 && self.rating > 0){
        
        [self.submitBtn setEnabled:YES];
        [self.submitBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
    }
    
}

- (BOOL)validateRating {
    
    //check again that rating submission is valid
    if(self.rating == 0){
        
        [self customAlert:@"You still need to set a star rating" withDone:@"OK" withTag:0];
        return false;
        
    } else if(self.recommended == -1){
        
        [self customAlert:[NSString stringWithFormat:@"You still need indicate whether or not you recommend %@", self.user.feebackInfo.ratee] withDone:@"OK" withTag:0];
        return false;
        
    } else {
        
        return true;
        
    }
    
}

- (IBAction)sendFeedback:(id)sender {
    
    //check if rating can be submitted
    if([self validateRating]){
        
        //create HUD
        [UserInfo createHUD:self.view withOffset:0.0f];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", self.user.feebackInfo.postID], @"post_id",
                                [NSString stringWithFormat:@"%i", self.user.feebackInfo.status], @"status",
                                self.user.username, @"rater", self.user.feebackInfo.ratee, @"ratee",
                                [NSString stringWithFormat:@"%i", self.rating], @"rating",
                                [NSString stringWithFormat:@"%i", self.recommended], @"recommended",
                                @"", @"optional_comment", self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@leaveFeedback", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSLog(@"%@", responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  //alert user their account has been created
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:1];
                      
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  NSLog(@"%@", operation.responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:0];
                      
                  } else {
                      
                      [self customAlert:@"Unable to leave feedback" withDone:@"OK" withTag:0];
                      
                  }
                  
              }];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

//method for creacustomAlertting and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done withTag:(int)tag {
    
    //if alert already showing, hide it
    if(self.customAlert)[UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.bounds withMessage:alert];
    self.customAlert.tag = tag;
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    self.customAlert.customAlertDelegate = self;
    
    //add as subview and make alpha 1.0
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//custom alert object left button delegate method
- (void)leftActionMethod:(int)method {
    
    [self hideCustomAlert];
    
    switch (self.customAlert.tag) {
        case 1:
            //indicate to refresh map pins
            self.user.shouldRefreshMapPins = YES;
            
            //dismiss view
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        
        case 2:
            [self noFeedback];
            break;
            
        default:
            break;
    }
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    switch (self.customAlert.tag) {
        case 2:
            [self hideCustomAlert];
            break;
            
        default:
            break;
    }
    
}

- (void)hideCustomAlert {
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

@end
