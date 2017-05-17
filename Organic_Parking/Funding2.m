//
//  Funding2.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Funding2.h"

@interface Funding2 (){
    
    int activeTag;
    
}

@end

@implementation Funding2

#define SCROLL_VIEW_CONTENT_HEIGHT 425

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT)];
    [self.container setFrame:CGRectMake(self.scrollView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, SCROLL_VIEW_CONTENT_HEIGHT)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.user = [UserInfo user];
    
    activeTag = 0;
    
    self.keyboardControls = [[KeyboardControls alloc] init];
    [self.keyboardControls setDelegate:self];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, SCROLL_VIEW_CONTENT_HEIGHT)];
    
    [self.venmo setDelegate:self];
    [self.routingNumber setDelegate:self];
    [self.accountNumber setDelegate:self];
    
    if(self.user.code == ADD_ACCOUNT){
        
        [self.accountBtn setTitle:@"Add Account" forState:UIControlStateNormal];
        
    } else if(self.user.code == CHANGE_ACCOUNT) {
        
        [self.accountBtn setTitle:@"Change Account" forState:UIControlStateNormal];
        
    }
    
    //add keyboard action methods to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (IBAction)back:(id)sender {
    
    [self dismissKeyboards];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dismissKeyboards {
    
    //dismiss keyboards
    [self.venmo resignFirstResponder];
    [self.routingNumber resignFirstResponder];
    [self.accountNumber resignFirstResponder];
    
}

- (void)previousPressed {
    
    //calculate previous tag
    activeTag--;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 1:
            [self.venmo becomeFirstResponder];
            break;
            
        case 2:
            [self.routingNumber becomeFirstResponder];
            break;
            
        default:
            activeTag = 0;
            [self dismissKeyboards];
            break;
    }
    
}

- (void)nextPressed {
    
    //calculate next tag
    activeTag++;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 2:
            [self.routingNumber becomeFirstResponder];
            break;
            
        case 3:
            [self.accountNumber becomeFirstResponder];
            break;
            
        default:
            [self dismissKeyboards];
            activeTag = 0;
            break;
    }
    
}

- (void)donePressed {
    
    //dismiss keyboards
    [self dismissKeyboards];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //get active textfield and add keyboard controls to keyboard input accessory view
    activeTag = (int)textField.tag;
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:YES]];
    
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

- (IBAction)venmoInfo:(id)sender {
    
    [self dismissKeyboards];
    [self customAlert:@"Venmo is a third party app which allows posters to send money easily and securely to you by entering an email or phone number. None of your account information is stored on our system when using venmo." withDone:@"OK" withTag:0];
    
}

- (IBAction)addAccount:(id)sender {
    
    // Dismiss keyboard first (it might cover an alert)
    [self dismissKeyboards];
    
    if(![self.venmo.text isEqualToString:@""]){
        
        self.params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.username, @"username", self.user.email, @"email", self.subMerchant.firstName, @"first_name", self.subMerchant.lastName, @"last_name", self.subMerchant.dateOfBirth, @"date_of_birth", self.subMerchant.address, @"street_address", self.subMerchant.city, @"locality", self.subMerchant.state, @"region", self.subMerchant.zip, @"postal_code", self.venmo.text, @"venmo", self.user.apiKey, @"api_key", nil];
        
    } else if(![self.routingNumber.text isEqualToString:@""] && ![self.accountNumber.text isEqualToString:@""]) {
        
        if(self.routingNumber.text.length != 9){
            
            [self customAlert:@"Your routing number must be 9 digits" withDone:@"OK" withTag:0];
            return;
            
        } else if(self.accountNumber.text.length > 17 && self.accountNumber.text.length < 3) {
            
            [self customAlert:@"Account numbers are 3 - 17 digit numbers" withDone:@"OK" withTag:0];
            return;
            
        } else {
            
            self.params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.username, @"username", self.user.email, @"email", self.subMerchant.firstName, @"first_name", self.subMerchant.lastName, @"last_name", self.subMerchant.dateOfBirth, @"date_of_birth", self.subMerchant.address, @"street_address", self.subMerchant.city, @"locality", self.subMerchant.state, @"region", self.subMerchant.zip, @"postal_code", self.accountNumber.text, @"account_number", self.routingNumber.text, @"routing_number", self.user.apiKey, @"api_key", nil];
            
        }
        
    } else {
        
        [self customAlert:@"You must first add either Venmo or bank account details before adding account"
                 withDone:@"OK" withTag:0];
        return;
        
    }
    
    [self dismissKeyboards];
    [UserInfo createHUD:self.view withOffset:100.0f];
    [self submitSubMerchantAccount];
    
}

- (void)submitSubMerchantAccount {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@createSubMerchant", self.user.uri] parameters:self.params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              if([responseObject objectForKey:@"status"] && [responseObject objectForKey:@"id"]){
                  
                  self.user.braintree.subMerchant.ID = [responseObject objectForKey:@"id"];
                  self.user.braintree.subMerchant.status = [responseObject objectForKey:@"status"];
                  
              }
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              self.user.braintree.shouldRefreshSubMerchant = YES;
              [self.navigationController popToRootViewControllerAnimated:YES];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //Don't need backup since no server message is returned
              [self customAlert:@"We were unable to process your funding source information" withDone:@"OK" withTag:0];
              
          }];
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done withTag:(NSInteger)tag {
    
    //if alert already showing, hide it
    if(self.customAlert)[UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
    
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
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    
}

@end
