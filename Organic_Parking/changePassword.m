//
//  ChangePassword.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "ChangePassword.h"
#import "MBProgressHUD.h"
//#import "AFNetworking.h"

@interface ChangePassword () {
    
    //stores currently active textfield
    UITextField *activeTextField;
    
}

@end

@implementation ChangePassword

#define TOP_BAR_HEIGHT 65.0

//- (void)viewWillLayoutSubviews {
//    
//    [super viewWillLayoutSubviews];
//    
//    //position view objects
//    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
//                                     self.view.frame.size.width, TOP_BAR_HEIGHT)];
//    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
//    [self.cancelBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelBtn.frame.size.height, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
//    [self.saveBtn setFrame:CGRectMake(self.view.frame.size.width - self.saveBtn.frame.size.width, self.topBar.frame.size.height - self.saveBtn.frame.size.height, self.saveBtn.frame.size.width, self.saveBtn.frame.size.height)];
//    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
//    [self.container setFrame:CGRectMake(self.scrollView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, 220)];
//    
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initialize keyboard controls
    self.keyboardControls = [[KeyboardControls alloc] init];
    
    //set delegates
    self.currentPassword.delegate = self;
    self.profilePasswordNew.delegate = self;
    self.confirmProfilePassword.delegate = self;
    self.keyboardControls.delegate = self;
    
    [self.scrollView setDelegate:self];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.container.frame.size.height)];
    
    //add keyboard action methods to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
//    [[self scrollView] setBackgroundColor:[UIColor purpleColor]];
//    [[self container] setBackgroundColor:[UIColor blueColor]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    [self.currentPassword becomeFirstResponder];
    
}

- (void)liftViewWhenKeybordAppears:(NSNotification*)notification {
    
    //keyboard will appear
    [self scrollViewForKeyboard:notification up:YES];
    
}

- (void)returnViewToInitialPosition:(NSNotification*)notification {
    
    //keyboard will hide
    [self scrollViewForKeyboard:notification up:NO];
    
}

- (void)scrollViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    
    NSDictionary* userInfo = [notification userInfo];
    
    //get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
//    //begin animations
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    [UIView setAnimationCurve:animationCurve];
//    
//    [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, ((keyboardFrame.size.height + 15) * (up?1:0)), 0)];
//    
//    [UIView commitAnimations];
    
    // When the iPad is rotated, the keyboard's frame is still given as if it were in portrait mode,
    // so the "height" given is actually the keyboard's width, etc.etc...
    // We use -convertRect: here to find out really where the keyboard is, from the perspective
    // of this ViewController's view
    CGRect correctKeyboardFrame = [[self view] convertRect:keyboardFrame fromView:nil];
    
    // Create some content insets to add padding on the bottom of the ScrollView
    UIEdgeInsets scrollInsets = UIEdgeInsetsZero;
    
    if(up) // Opening up the keyboard
    {
        // We apply a positive inset if the keyboard overlaps the ScrollView
        CGRect scrollViewFrame = [[self scrollView] frame];
        CGFloat bottomOfScrollView = scrollViewFrame.origin.y + scrollViewFrame.size.height;
        CGFloat topOfKeyboard = correctKeyboardFrame.origin.y;
        
        if(topOfKeyboard < bottomOfScrollView) // If there is actually any covering of the scrollview
            scrollInsets.bottom = bottomOfScrollView - topOfKeyboard;
    }
    
    // Animate the insets change
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [[self scrollView] setContentInset:scrollInsets];
    [UIView commitAnimations];
    
}

- (IBAction)cancelView:(id)sender {
    
    [self dismissKeyboards];
    
    //dismiss view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)resetPassword:(id)sender {
    
    //dismiss keyboards if active
    [self dismissKeyboards];
    
    //if all information provided and valid, continue - otherwise, do nothing
    if([self validateRecoveryValues]){
        
        //create HUD
        [UserInfo createHUD:self.view withOffset:100.0f];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.user.username,             @"username",
                                self.profilePasswordNew.text,   @"password_new",
                                self.currentPassword.text,      @"password_current",
                                self.user.apiKey,            @"api_key",
                                nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@changePassword", self.user.uri] parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //hide HUD
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //save returned hash into keychain
            [self.user.keychain setObject:[responseObject valueForKey:@"hash"] forKey:(__bridge id)(kSecValueData)];
            
            //notify user their password has been changed
            [self customAlert:@"Your password has been changed" withDone:@"OK"];
            [self.customAlert setTag:1];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            //stop log in animation
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //notify user why crentials weren't accepted
            if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
               [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                
                [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                         withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                
            } else {
                
                [self customAlert:@"Unable to change your password" withDone:@"OK"];
                
            }
            
        }];
        
    }
    
}

- (BOOL)validateRecoveryValues {
    
    //check that current password not empty, both new passwords not empty, and that new passwords match
    if([[self.currentPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length]==0) {
        
        [self customAlert:@"Please enter your current password before continuing" withDone:@"OK"];
        return false;
        
    } else if ([[self.profilePasswordNew.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length]==0) {
        
        [self customAlert:@"Please enter your new password before continuing" withDone:@"OK"];
        return false;
        
    } else if ([[self.confirmProfilePassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length]==0) {
        
        [self customAlert:@"Please confirm your new password before continuing" withDone:@"OK"];
        return false;
        
    } else if(![self.profilePasswordNew.text isEqualToString:self.confirmProfilePassword.text]){
        
        [self customAlert:@"New Password fields don't match" withDone:@"OK"];
        return false;
        
    }
    
    return true;
    
}

- (void)dismissKeyboards {
    
    //dimiss keyboards if active
    [self.currentPassword resignFirstResponder];
    [self.profilePasswordNew resignFirstResponder];
    [self.confirmProfilePassword resignFirstResponder];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //add keyboard controls to keyboard input accessory view
	activeTextField = textField;
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:YES]];
    
}

- (void)previousPressed {
    
    //calculate previous tag
    NSInteger prevTag = activeTextField.tag - 1;
    
    //attempt to find view with prevTag
    UIResponder* prevResponder = [activeTextField.superview viewWithTag:prevTag];
    
    //if prevResponder and has tag equal to 1 or 2, make it first responder
    if (prevResponder && (prevTag == 1 || prevTag == 2)) {
        
        [prevResponder becomeFirstResponder];
        
    }
    
}

- (void)nextPressed {
    
    //calculate next tag
    NSInteger nextTag = activeTextField.tag + 1;
    
    //attempt to find view with nextTag
    UIResponder* nextResponder = [activeTextField.superview viewWithTag:nextTag];
    
    //if nextResponder and has tag equal to 2 or 3, make it first responder - otherwise, dismiss keyboards
    if (nextResponder && (nextTag == 2 || nextTag == 3)) {
        
        [nextResponder becomeFirstResponder];
        
    } else {
        
        [self dismissKeyboards];
        
    }
    
}

- (void)donePressed {
    
    //dismiss keyboards if active
    [self dismissKeyboards];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    // 10/15/15: Changed `withframe:self.view.frame` to `withframe:self.view.bounds` -- `bounds` responds
    // to rotation changes of the device while `frame` gets stuck in portrait mode, usually
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.bounds withMessage:alert];
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
    
    //dismisses view if custom alert tag == 1
    switch (self.customAlert.tag) {
        case 1:
            [self dismissViewControllerAnimated:YES completion:nil];
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
