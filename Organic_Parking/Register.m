//
//  Register.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Register.h"

@interface Register (){
    
    UITextField *activeTextField; //keyboard controls - indicates active textfield
    
}

@end

@implementation Register

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelBtn.frame.size.height, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
    [self.createBtn setFrame:CGRectMake(self.view.frame.size.width - self.createBtn.frame.size.width, self.topBar.frame.size.height - self.createBtn.frame.size.height, self.createBtn.frame.size.width, self.createBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    [self.container setFrame:CGRectMake(self.view.frame.size.width/2 - self.container.frame.size.width/2, 0, self.container.frame.size.width, self.container.frame.size.height)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initialize keyboard controls
    self.keyboardControls = [[KeyboardControls alloc] init];
    
    //set delegates
    self.scrollView.delegate = self;
    self.username.delegate = self;
    self.password.delegate = self;
    self.email.delegate = self;
    self.keyboardControls.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    [self.username becomeFirstResponder];
    
}

- (IBAction)cancelView:(id)sender {
    
    //dismiss current view
    [self dismissKeyboards];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)validateRegistrationValues {
    
    //check that all input fields aren't empty
    if([[self.username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        [self customAlert:@"Please enter a username before continuing" withDone:@"Ok" withTag:0];
        return false;
        
    } else if ([[self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        [self customAlert:@"Please enter an email before continuing" withDone:@"Ok" withTag:0];
        return false;
        
    } else if ([[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        
        [self customAlert:@"Please enter a password before continuing" withDone:@"Ok" withTag:0];
        return false;
        
    }
    else if([self.username.text isEqualToString:@"0"] ){
        [self customAlert:@"Please use another username.  \n0 is a reserved name" withDone:@"Ok" withTag:0];
        return false;
    }
    
    return true;
    
}

- (IBAction)continueRegistration:(id)sender {
    
    //dismiss keyboards
    [self dismissKeyboards];
    
    //create HUD
    [UserInfo createHUD:self.view withOffset:120.0f];
    
    //if invalid registration values, return - otherwise, continue
    if([self validateRegistrationValues]){
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.username.text, @"username", self.email.text, @"email",
                                self.password.text, @"password", self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@register", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSLog(@"%@", responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  //save username and indicate tutorial should be shown
                  [self.user.keychain setObject:self.username.text forKey:(__bridge id)(kSecAttrAccount)];
                  self.user.showTutorial = true;
                  
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
                      
                      [self customAlert:@"We were unable to create your account" withDone:@"Ok" withTag:0];
                      
                  }
                  
                  [self.createBtn setEnabled:YES];
                  
              }];
        
    } else {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //add keyboard controls to keyboard input accessory view
	activeTextField = textField;
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:YES]];
    
}

- (void)previousPressed {
    
    //calculate previous tag
    NSInteger prevTag = activeTextField.tag - 1;
    
    //attempt to get previous responder
    UIResponder* prevResponder = [activeTextField.superview viewWithTag:prevTag];
    
    //previous responder exists with a tag of 1 or 2, make it the first responder
    if (prevResponder && (prevTag == 1 || prevTag == 2)) {
        
        [prevResponder becomeFirstResponder];
        
    }
    
}

- (void)nextPressed {
    
    //calculate next tag
    NSInteger nextTag = activeTextField.tag + 1;
    
    //attempt to get next responder
    UIResponder* nextResponder = [activeTextField.superview viewWithTag:nextTag];
    
    //if next responder exists, make it the first responder - otherwise, dismiss keyboard
    if (nextResponder && (nextTag == 2 || nextTag == 3)) {
        
        [nextResponder becomeFirstResponder];
        
    } else {
        
        [self dismissKeyboards];
        
    }
    
}

- (void)donePressed {
    
    //dismiss keyboards
    [self dismissKeyboards];
    
}

- (void)dismissKeyboards {
    
    //dismiss keyboards
    [self.username resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
}

- (IBAction)showTerms:(id)sender {
    
    //segue to terms
    self.user.showTerms = true;
    Register *view = [self.storyboard instantiateViewControllerWithIdentifier:@"termsandprivacy"];
    [self presentViewController:view animated:YES completion:nil];
    
}

- (IBAction)showPrivacy:(id)sender {
    
    //segue to privacy
    self.user.showTerms = false;
    Register *view = [self.storyboard instantiateViewControllerWithIdentifier:@"termsandprivacy"];
    [self presentViewController:view animated:YES completion:nil];
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done withTag:(NSInteger)tag {
    
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
