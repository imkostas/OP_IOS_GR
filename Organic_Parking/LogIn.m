//
//  LogIn.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.

#import "LogIn.h"

// Enumerates the two different layout states that this LogIn view controller can be presenting:
// the first is when the logo and ORGANIC PARKING are centered, and the second is when the logo and
// ORGANIC PARKING are shifted up to make room for the username, password, and Log In elements
typedef NS_ENUM(NSUInteger, LogInLayoutState) {
    LogInLayoutStateLogoCentered,
    LogInLayoutStateLogoShiftedUp
};
//
// Enumeration of keyboard states, either visible or hidden. This is used to position the UI elements according
// to the keyboard's position
typedef NS_ENUM(NSUInteger, KeyboardState) {
    KeyboardStateVisible,
    KeyboardStateHidden
};

@interface LogIn () {
    
    BOOL shouldReposition;
    
    // Keeps track of the current layout state -- this is used in conjunction with
    // -viewWillLayoutSubviews
    LogInLayoutState layoutState;
    
    // Keeps track of the current state of the keyboard
    KeyboardState keyboardState;
    
    // Set to the height of the keyboard right after a KeyboardWillShow notification is sent
    CGFloat keyboardHeight;
    
    // Set to true when the device is currently rotating and false when it is not-- this is to prevent the
    // keyboard slide-up animations from happening while the iPad is rotating
    BOOL isRotating;
}

@end

@implementation LogIn

#define LOGO_SPACING 15.0

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //set delegates
    self.usernameTextField.delegate = self;
    self.pass1TextField.delegate = self;
    
    //disable login button
    [self.loginButton setEnabled:NO];
    
    shouldReposition = true;
    
    // Initial state is the logo in the center
    layoutState = LogInLayoutStateLogoCentered;
    keyboardState = KeyboardStateHidden;
    keyboardHeight = 0;
    
    //initialize rotation animation
    self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    self.rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    self.rotateAnimation.duration = 0.4;
    self.rotateAnimation.autoreverses = NO;
    self.rotateAnimation.repeatCount = HUGE_VALF;
    
    //initialize and add tap gesture recognizer to background view for dismissing keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //add functions to control foreground animation and positioning on keyboard show and dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set up autoresizing for the foreground
    [[self foreground] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin)];
    
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Set a certain layout based on the layoutState variable
    switch(layoutState)
    {
        case LogInLayoutStateLogoCentered:
        {
            //position logo image, animator, and text
            [self.logoOuter setFrame:CGRectMake(self.view.frame.size.width/2 - self.logoOuter.frame.size.width/2,
                                                self.view.frame.size.height/2.5 - self.logoOuter.frame.size.height/2.5,
                                                self.logoOuter.frame.size.width, self.logoOuter.frame.size.height)];
            [self.logoInnerSolid setFrame:self.logoOuter.frame];
            [self.logoInnerLoader setFrame:self.logoInnerSolid.frame];
            [self.textImage setFrame:CGRectMake(self.view.frame.size.width/2 - self.textImage.frame.size.width/2,
                                                self.logoOuter.frame.origin.y + self.logoOuter.frame.size.height + LOGO_SPACING,
                                                self.textImage.frame.size.width, self.textImage.frame.size.height)];
            
            break;
        }
        case LogInLayoutStateLogoShiftedUp:
        {
            // Shifted upward
            switch(keyboardState)
            {
                case KeyboardStateHidden:
                {
                    [self.logoOuter setFrame:CGRectMake(self.view.frame.size.width/2 - self.logoOuter.frame.size.width/2,
                                                        self.view.frame.size.height/3 - self.logoOuter.frame.size.height,
                                                        self.logoOuter.frame.size.width, self.logoOuter.frame.size.height)];
                    break;
                }
                    
                case KeyboardStateVisible:
                {
                    // Slide the logo up to account for the keyboard
                    CGFloat keyboardOrigin = [[self view] bounds].size.height - keyboardHeight;
                    
                    [self.logoOuter setFrame:CGRectMake(self.view.frame.size.width/2 - self.logoOuter.frame.size.width/2,
                                                        keyboardOrigin/2 + 5 - (self.textImage.frame.size.height + self.foreground.frame.size.height)/2 - self.logoOuter.frame.size.height - LOGO_SPACING,
                                                        self.logoOuter.frame.size.width, self.logoOuter.frame.size.height)];
                    break;
                }
                default:
                    break;
            }
            
            // Everything else depends on logoOuter
            [self.logoInnerSolid setFrame:self.logoOuter.frame];
            [self.logoInnerLoader setFrame:self.logoInnerSolid.frame];
            [self.textImage setFrame:CGRectMake(self.view.frame.size.width/2 - self.textImage.frame.size.width/2,
                                                self.logoOuter.frame.origin.y + self.logoOuter.frame.size.height + LOGO_SPACING,
                                                self.textImage.frame.size.width, self.textImage.frame.size.height)];
            
            break;
        }
        default:
            break;
    }
    
    //position the rest of the view objects to their proper locations
    [self.foreground setFrame:CGRectMake(self.view.frame.size.width/2 - self.foreground.frame.size.width/2,
                                         self.textImage.frame.origin.y + self.textImage.frame.size.height + LOGO_SPACING + ((self.view.frame.size.height > 600)?LOGO_SPACING:0),
                                         self.foreground.frame.size.width, self.foreground.frame.size.height)];
    
    [self.bullet setFrame:CGRectMake(self.view.frame.size.width/2 - self.bullet.frame.size.width/2,
                                     self.view.frame.size.height - self.bullet.frame.size.height,
                                     self.bullet.frame.size.width, self.bullet.frame.size.height)];
    [self.createAccount setFrame:CGRectMake(self.bullet.frame.origin.x - self.createAccount.frame.size.width,
                                            self.view.frame.size.height - self.createAccount.frame.size.height,
                                            self.createAccount.frame.size.width, self.createAccount.frame.size.height)];
    [self.forgotPassword setFrame:CGRectMake(self.bullet.frame.origin.x + self.bullet.frame.size.width,
                                             self.view.frame.size.height - self.forgotPassword.frame.size.height,
                                             self.forgotPassword.frame.size.width, self.forgotPassword.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //set username textfield to username if exists and not empty
    if(![[self.user.keychain objectForKey:(__bridge id)(kSecAttrAccount)] isEqualToString:@""]){
        self.usernameTextField.text = [self.user.keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    }
    
    if(shouldReposition)[self positionLogoViews];
    shouldReposition = true;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //if username, password, and device stored in defaults use to autologin, otherwise, show the normal log in view
    if(![[self.user.keychain objectForKey:(__bridge id)(kSecAttrAccount)] isEqualToString:@""] &&
       ![[self.user.keychain objectForKey:(__bridge id)(kSecValueData)] isEqualToString:@""]) {
        
        [self validateCredentials:[self.user.keychain objectForKey:(__bridge id)(kSecAttrAccount)]
                     withPassword:[self.user.keychain objectForKey:(__bridge id)(kSecValueData)]
                        loginType:@"yes"];
        
    }  else if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        self.user.showTutorial = true;
        LogIn *mainView = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
        [self.navigationController pushViewController:mainView animated:YES];
        
    }
    
    
    else {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setupLogInView) userInfo:nil repeats:NO];
    }
    
}

- (void)positionLogoViews {
    
    //setup view for auto log in
    self.foreground.alpha = 0.0f;
    self.bullet.alpha = 0.0f;
    self.createAccount.alpha = 0.0f;
    self.forgotPassword.alpha = 0.0f;
    
}

- (void)setupLogInView {
    
    //animate logo objects up - on completion, position other view objects in showLogIn and set alphas to 1.0
    [[self view] setNeedsLayout];
    [UIView animateWithDuration:0.5 animations:^{
        
        // Set new layout state and apply it
        layoutState = LogInLayoutStateLogoShiftedUp;
        [[self view] layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.foreground.alpha = 1.0f;
            self.bullet.alpha = 1.0f;
            self.createAccount.alpha = 1.0f;
            self.forgotPassword.alpha = 1.0f;
        }];
        
    }];
}

// Handling rotation for iOS 8+
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        isRotating = TRUE;
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        isRotating = FALSE;
        
    }];
}

// Handling rotation for iOS 7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    isRotating = TRUE;
}
// Handling rotation for iOS 7
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    isRotating = FALSE;
}

- (void)liftMainViewWhenKeybordAppears:(NSNotification*)notification {
    
    //Invalidate timer - if user selects textfield quickly, foreground will animate before setupLogInView is called
    [self.timer invalidate];
    
    // Set keyboard state
    keyboardState = KeyboardStateVisible;
    
    //indicate keyboard will appear
    if(shouldReposition)[self scrollViewForKeyboard:notification up:YES];
}

- (void)returnMainViewToInitialposition:(NSNotification*)notification {
    
    //Invalidate timer - if user selects textfield quickly, foreground will animate before setupLogInView is called
    [self.timer invalidate];
    
    // Set keyboard state
    keyboardState = KeyboardStateHidden;
    
    //indicate keyboard will dismiss
    if(shouldReposition)[self scrollViewForKeyboard:notification up:NO];
}

- (void)scrollViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    
    //collect notification info
    NSDictionary* notificationInfo = [notification userInfo];
    
    //variables to store notification info
    UIViewAnimationCurve animationCurve;
    NSTimeInterval animationDuration;
    CGRect keyboardFrame;
    
    //store type of animation curve, the duration of the animation, and the keyboard's frame
    animationCurve = [[notificationInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[notificationInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    keyboardFrame = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    NSLog(@"Keyboard going %@, duration: %.4f, is rotating: %@, curve: %i",
//          up ? @"up":@"down", animationDuration, isRotating ? @"YES":@"NO", animationCurve);
    
    // Use -convertRect: on the keyboard's frame to account for rotation
    keyboardFrame = [[self view] convertRect:keyboardFrame fromView:nil];
    
    // Save the keyboard's height to use with -viewWillLayoutSubviews
    keyboardHeight = CGRectGetHeight(keyboardFrame);

    if(!isRotating)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
    }
    
    //hide logo when keyboard active, otherwise show
    [self.logoOuter setAlpha:1.0 * (up?0:1)];
    [self.logoInnerSolid setAlpha:1.0 * (up?0:1)];
    [self.logoInnerLoader setAlpha:1.0 * (up?0:1)];
    
    [[self view] setNeedsLayout];
    [[self view] layoutIfNeeded];
    
    if(!isRotating)
        [UIView commitAnimations];
    
//    if(up){
//        
//        [self.textImage setFrame:CGRectMake(self.view.frame.size.width/2 - self.textImage.frame.size.width/2,
//                                            (keyboardFrame.origin.y + 10)/2 - (self.textImage.frame.size.height + self.foreground.frame.size.height)/2,
//                                            self.textImage.frame.size.width, self.textImage.frame.size.height)];
//        [self.logoOuter setFrame:CGRectMake(self.view.frame.size.width/2 - self.logoOuter.frame.size.width/2,
//                                            self.textImage.frame.origin.y - self.logoOuter.frame.size.height - LOGO_SPACING,
//                                            self.logoOuter.frame.size.width, self.logoOuter.frame.size.height)];
//        [self.logoInnerSolid setFrame:self.logoOuter.frame];
//        [self.logoInnerLoader setFrame:self.logoInnerSolid.frame];
//        [self.foreground setFrame:CGRectMake(self.view.frame.size.width/2 - self.foreground.frame.size.width/2,
//                                             self.textImage.frame.origin.y + self.textImage.frame.size.height + LOGO_SPACING + ((SCREEN_HEIGHT > 600)?LOGO_SPACING:0),
//                                             self.foreground.frame.size.width, self.foreground.frame.size.height)];
//        
//    } else {
//        
//        [self.logoOuter setFrame:CGRectMake(self.view.frame.size.width/2 - self.logoOuter.frame.size.width/2,
//                                            self.view.frame.size.height/3 - self.logoOuter.frame.size.height,
//                                            self.logoOuter.frame.size.width, self.logoOuter.frame.size.height)];
//        [self.logoInnerSolid setFrame:self.logoOuter.frame];
//        [self.logoInnerLoader setFrame:self.logoInnerSolid.frame];
//        [self.textImage setFrame:CGRectMake(self.view.frame.size.width/2 - self.textImage.frame.size.width/2,
//                                            self.logoOuter.frame.origin.y + self.logoOuter.frame.size.height + LOGO_SPACING,
//                                            self.textImage.frame.size.width, self.textImage.frame.size.height)];
//        [self.foreground setFrame:CGRectMake(self.view.frame.size.width/2 - self.foreground.frame.size.width/2,
//                                             self.textImage.frame.origin.y + self.textImage.frame.size.height + LOGO_SPACING + ((SCREEN_HEIGHT > 600)?LOGO_SPACING:0),
//                                             self.foreground.frame.size.width, self.foreground.frame.size.height)];
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //calculate next tag
    NSInteger nextTag = textField.tag + 1;
    
    //attempt to get next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    //if a next responder exists, make it the first responder - otherwise, start log in process
    if (nextResponder) {
        
        [nextResponder becomeFirstResponder];
        
    } else {
        
        [self loginAction:nextResponder];
    }
    
    return NO;
}

- (void)dismissKeyboard {
    
    //dismiss keyboards if active
    [self.usernameTextField resignFirstResponder];
    [self.pass1TextField resignFirstResponder];
}

- (IBAction)validUsername:(id)sender {
    
    //pre validate log in credentials
    [self credentialStatus];
}

- (IBAction)validPassword:(id)sender {
    
    //pre validate log in credentials
    [self credentialStatus];
}

- (void)credentialStatus {
    
    //if username and password both have length > 0, enable log in button - otherwise, disable it
    if(self.usernameTextField.text.length > 0 && self.pass1TextField.text.length > 0){
        
        [self.loginButton setEnabled:YES];
        
    } else {
        
        [self.loginButton setEnabled:NO];
    }
}

//begin validating user login credentials
- (IBAction)loginAction:(id)sender {
    
    [self.loginButton setEnabled:NO];
    [self dismissKeyboard];
    [self validateCredentials:self.usernameTextField.text withPassword:self.pass1TextField.text loginType:@"no"];
    
}

- (void)validateCredentials:(NSString *)username withPassword:(NSString *)password loginType:(NSString *)type {
    
    //start animation
    [self.logoInnerLoader.layer addAnimation:self.rotateAnimation forKey:@"transform.rotation"];
    [UIView animateWithDuration:0.7 animations:^{[self.logoInnerSolid setAlpha:0.0f];}];
    
    //validate user credentials
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username,                                                   @"username",
                            password,                                                   @"password",
                            type,                                                       @"isAuto",
                            self.user.device,                                           @"device",
                            [NSString stringWithFormat:@"%i", self.user.deviceType],    @"device_type",
                            self.user.apiKey,                                           @"api_key",
                            nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@login", self.user.uri] parameters:params
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"%@", operation.responseObject);
        
        //save username and password in keychain
        [self.user.keychain setObject:[responseObject valueForKey:@"username"] forKey:(__bridge id)(kSecAttrAccount)];
        [self.user.keychain setObject:[responseObject valueForKey:@"hash"] forKey:(__bridge id)(kSecValueData)];
        
        //save user info - username, email, funds
        self.user.username = [responseObject valueForKey:@"username"];
        self.user.email = [responseObject valueForKey:@"email"];
        self.user.braintree.customerID = [responseObject valueForKey:@"customer_id"];
        self.user.braintree.subMerchant.ID = [responseObject valueForKey:@"sub_merchant_id"];
        
        //if user has search history, store for use
        if([[responseObject valueForKey:@"searches"] count]){
            
            for(NSDictionary *item in [responseObject valueForKey:@"searches"]){
                
                [self.user.searches addObject:[[SearchedLocation alloc] initWithSearchedLocation:[item valueForKey:@"address"] withCoordinate:CLLocationCoordinate2DMake([[item valueForKey:@"latitude"] floatValue], [[item valueForKey:@"longitude"] floatValue])]];
                
            }
        }
        
        if([[[responseObject valueForKey:@"vehicle"] valueForKey:@"vehicle_id"] integerValue] != 0){
            
            self.user.vehicle = [[Vehicle alloc] initWithVehicle:[[[responseObject valueForKey:@"vehicle"] valueForKey:@"vehicle_id"] intValue] make:[[responseObject valueForKey:@"vehicle"] valueForKey:@"make"] model:[[responseObject valueForKey:@"vehicle"] valueForKey:@"model"] color:[[responseObject valueForKey:@"vehicle"] valueForKey:@"color"]size:[[[responseObject valueForKey:@"vehicle"] valueForKey:@"size"] intValue]];
            
        }
        
        [UIView animateWithDuration:0.7 animations:^{
            
            [self.logoInnerSolid setAlpha:1.0f];
            
        } completion:^(BOOL finished) {
            
            //stop animating
            [self.logoInnerLoader.layer removeAllAnimations];
            
        }];
        
        //clear username and password textfields
        self.usernameTextField.text = @"";
        self.pass1TextField.text = @"";
        
        //localytics logged in event
        //[[LocalyticsSession shared] tagEvent:@"Logged In"];
        
        shouldReposition = true;
        
        // Since we're leaving the login area, we set the layout to its initial state for next time
        layoutState = LogInLayoutStateLogoCentered;
        
        //segue to main view
        LogIn *mainView = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];
        [self.navigationController pushViewController:mainView animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.loginButton setEnabled:YES];
        [self.user.keychain setObject:@"" forKey:(__bridge id)(kSecValueData)];
        
        [UIView animateWithDuration:0.7 animations:^{
            
            [self.logoInnerSolid setAlpha:1.0f];
            
        } completion:^(BOOL finished) {
            
            //stop animating
            [self.logoInnerLoader.layer removeAllAnimations];
            
        }];
        
        if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
           [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
            
            [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                     withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
            
        } else {
            
            [self customAlert:@"We were unable to log you in" withDone:@"OK"];
            
        }
        
        NSLog(@"%@", operation.responseObject);
        
        //make sure all view objects have been positioned correctly - this needs to be done in the event that auto log in fails
        [self setupLogInView];
    }];
    
}

- (IBAction)createAccount:(id)sender {
    
    shouldReposition = false;
    
}

- (IBAction)forgotPassword:(id)sender {
    
    shouldReposition = false;
    
    //segue to forgot password view
    LogIn *view = [self.storyboard instantiateViewControllerWithIdentifier:@"forgotPassword"];
    [self presentViewController:view animated:YES completion:nil];
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
    
    //nothing for now
}

@end
