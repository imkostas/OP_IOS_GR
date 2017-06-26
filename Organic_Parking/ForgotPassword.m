//
//  ForgotPassword.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "ForgotPassword.h"

@interface ForgotPassword ()

@end

@implementation ForgotPassword

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelBtn.frame.size.height, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
    [self.recoverBtn setFrame:CGRectMake(self.view.frame.size.width - self.recoverBtn.frame.size.width, self.topBar.frame.size.height - self.recoverBtn.frame.size.height, self.recoverBtn.frame.size.width, self.recoverBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    [self.container setFrame:CGRectMake(self.view.frame.size.width/2 - self.container.frame.size.width/2, 0, self.container.frame.size.width, self.container.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initialize keyboard controls
    self.keyboardControls = [[KeyboardControls alloc] init];
    
    //set delegates
    self.recoverText.delegate = self;
    self.scrollView.delegate = self;
    self.keyboardControls.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    [self.recoverText becomeFirstResponder];
    
}

- (IBAction)cancel:(id)sender {
    
    //dismiss keyboard if active
    [self dismissKeyboards];
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)validateRecoveryValues {
    
    //check that the username entered isn't empty
    if([[self.recoverText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0){
        
        [self customAlert:@"Το όνομα σου χρειάζεται γιά να αλλάξουμε το συνθηματικό σου" withDone:@"OK" withTag:0];
        return false;
        
    }
    
    return true;
    
}

- (IBAction)recoverPassword:(id)sender {
    
    //create HUD
    [UserInfo createHUD:self.view withOffset:100.0f];
    
    //dismiss keyboard if active
    [self donePressed];
    
    [self.recoverBtn setEnabled:NO];
    
    //if not valid, return - otherwise, continue
    if([self validateRecoveryValues]){
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.recoverText.text, @"recover_text", self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"%@forgotPassword", self.user.uri] parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 //hide HUD
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 
                 //alert user a temporary password has been sent to via email
                 [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                          withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:1];
                 NSLog(@"%@", [operation.responseObject objectForKey:@"error"]);
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 NSLog(@"%@", operation.responseObject);
                 
                 [self.recoverBtn setEnabled:YES];
                 
                 //stop log in animation
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 
                 if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                    [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                     
                     [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                              withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:0];
                     
                 } else {
                     
                     [self customAlert:@"Δεν μπορέσαμε να ανακτήσουμε το συνθηματικό σου" withDone:@"Ξανά" withTag:0];
                     
                 }
                 
             }];
        
    } else {
        
        //hide HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }
    
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
    
    [self dismissKeyboards];
    
}

- (void)dismissKeyboards {
    
    [self.recoverText resignFirstResponder];
    
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
