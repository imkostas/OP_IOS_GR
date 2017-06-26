//
//  RequesterInfo.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "RequesterInfo.h"

@interface RequesterInfo ()

@end

@implementation RequesterInfo

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.requestView setFrame:CGRectMake(self.view.frame.size.width/2 - self.requestView.frame.size.width/2, self.view.frame.size.height/2 - self.requestView.frame.size.height/2, self.requestView.frame.size.width, self.requestView.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user ingo
    self.user = [UserInfo user];
    
    //hide view until all requester info has been loaded
    [self.view setAlpha:0.0f];
    
    //make requester image a circle
    [self.requesterImageView.layer setCornerRadius:55.0f];
    
    //set view objects with requester info
    self.requesterUsername.text = [self.user.requesterInfo.r_username uppercaseString];
    self.numDealsLabel.text = [NSString stringWithFormat:@"(%i)", self.user.requesterInfo.total_deals];
    
    CGFloat textWidth = [[[NSAttributedString alloc] initWithString:self.numDealsLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:15.0f]}] boundingRectWithSize:CGSizeMake(230.0f, 21.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    //properly center stars and numDeals
    [self.starView setFrame:CGRectMake(self.requestView.frame.size.width/2 - self.starView.frame.size.width/2 - textWidth/2, self.starView.frame.origin.y, self.starView.frame.size.width, self.starView.frame.size.height)];
    [self.numDealsLabel setFrame:CGRectMake(self.starView.frame.origin.x + self.starView.frame.size.width, self.numDealsLabel.frame.origin.y, textWidth, self.numDealsLabel.frame.size.height)];
    
    float average = (self.user.requesterInfo.total_deals != 0) ? (float)self.user.requesterInfo.total_stars/(float)self.user.requesterInfo.total_deals : 0.0f;
    if(average >= 5.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFive setImage:[UIImage imageNamed:@"Star Blue"]];
    } else if(average >= 4.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFive setImage:[UIImage imageNamed:@"Star Blue Half"]];
    } else if(average >= 4.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else {
        [self.starOne setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    }
    
    //fetch requester image
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", self.user.img_uri, self.user.requesterInfo.r_username]]]];
    
    //save and set requester image
    if(!img){
        
        [self.requesterImageView setImage:[UIImage imageNamed:@"No Profile Image"]];
        
    } else{
        
        [self.user.userImages setObject:img forKey:self.user.requesterInfo.r_username];
        [self.requesterImageView setImage:img];
        
    }
    
    CGFloat leftRightMin = -15.0f;
    CGFloat leftRightMax = 15.0f;
    CGFloat upDownMin = -15.0f;
    CGFloat upDownMax = 15.0f;
    
    UIInterpolatingMotionEffect *leftRight = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    UIInterpolatingMotionEffect *upDown = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    leftRight.minimumRelativeValue = @(leftRightMin);
    leftRight.maximumRelativeValue = @(leftRightMax);
    upDown.minimumRelativeValue = @(upDownMin);
    upDown.maximumRelativeValue = @(upDownMax);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = [NSArray arrayWithObjects:leftRight, upDown, nil];
    
    [self.requestView addMotionEffect:motionEffectGroup];
    
    //display requester info for poster to make decision
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.view setAlpha:1.0f];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)denyRequest:(id)sender {
    
    //disable response buttons to prevent multiple sends
    [self.denyBtn setEnabled:NO];
    [self.acceptBtn setEnabled:NO];
    
    //send denial response
    [self requestResponse:6];
    
}

- (IBAction)acceptRequest:(id)sender {
    
    //disable response buttons to prevent multiple sends
    [self.denyBtn setEnabled:NO];
    [self.acceptBtn setEnabled:NO];
    
    //send acceeptance response
    [self requestResponse:1];
    
}

//processes responses to requests made
- (void)requestResponse:(int)status {
    
    //create HUD
    [UserInfo createHUD:self.view withOffset:-55.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i", self.user.requesterInfo.post_id], @"post_id",
                            [NSString stringWithFormat:@"%i", status], @"status",
                            self.user.requesterInfo.r_username, @"requester", self.user.apiKey, @"api_key", nil];
    
    NSLog(@"%@", params);
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@requestResponse", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //alert user their response has been sent
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]
                            withTag:0];
                  
              }
              
              [self dismissView];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //enable response buttons so response can be attempted again
              [self.denyBtn setEnabled:YES];
              [self.acceptBtn setEnabled:YES];
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  if([[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] isEqualToString:@""]){
                      
                      [self customAlert:@"Αυτή η αίτηση μόλις ακυρώθηκε"
                               withDone:@"OK"
                                withTag:1];
                      
                  } else {
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]
                                withTag:0];
                      
                  }
                  
              } else {
                  
                  [self customAlert:@"Δεν μπορέσαμε να στείλουμε την αίτηση σου" withDone:@"OK" withTag:0];
                  
              }
              
          }];
    
}

- (void)dismissView {
    
    //hide view then remove it from parent view
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.view setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        //indicate map should refresh
        self.user.shouldRefreshMapPins = YES;
        
        //indicate deal response view is no longer active
        self.user.dealResponseViewActive = NO;
        self.user.requesterInfo = [[KPAnnotation alloc] init];
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done withTag:(int)tag {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.frame withMessage:alert];
    self.customAlert.tag = tag;
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
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
    
    //dismiss view if custom alert tag == 1
    switch (self.customAlert.tag) {
        case 1:
            [self dismissView];
            break;
            
        default:
            break;
    }
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    //nothing for now
    
}

@end
