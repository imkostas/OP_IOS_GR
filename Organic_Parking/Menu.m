//
//  Menu.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Menu.h"

@interface Menu () {
    
    //min and max position of settings view
    float settings_min;
    float settings_max;
    
    //min and max position of help view
    float help_min;
    float help_max;
    
}

@end

@implementation Menu

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.scrollView setFrame:self.view.frame];
    [self.settingsView setFrame:CGRectMake(self.settingsView.frame.origin.x, self.settingsView.frame.origin.y, self.view.frame.size.width, settings_min)];
    [self.helpView setFrame:CGRectMake(self.helpView.frame.origin.x, self.helpView.frame.origin.y, self.view.frame.size.width, help_min)];
    [self.logoutView setFrame:CGRectMake(self.logoutView.frame.origin.x, self.helpView.frame.origin.y + self.helpView.frame.size.height, self.view.frame.size.width, self.logoutView.frame.size.height)];
    
    [self.statusPlaceholder setFrame:CGRectMake(self.statusPlaceholder.frame.origin.x, self.statusPlaceholder.frame.origin.y, self.view.frame.size.width, self.statusPlaceholder.frame.size.height)];
    [self.statusDivider setFrame:CGRectMake(self.statusDivider.frame.origin.x, self.statusDivider.frame.origin.y, self.view.frame.size.width, self.statusDivider.frame.size.height)];
    
    [self.logo setFrame:CGRectMake(ACCORDION_WIDH/2 - self.logo.frame.size.width/2, self.logo.frame.origin.y, self.logo.frame.size.width, self.logo.frame.size.height)];
    [self.logoText setFrame:CGRectMake(ACCORDION_WIDH/2 - self.logoText.frame.size.width/2, self.logoText.frame.origin.y, self.logoText.frame.size.width, self.logoText.frame.size.height)];
    
    [self.settingsBtn setFrame:CGRectMake(self.settingsBtn.frame.origin.x, self.settingsBtn.frame.origin.y,
                                          self.view.frame.size.width, self.settingsBtn.frame.size.height)];
    [self.profileBtn setFrame:CGRectMake(self.profileBtn.frame.origin.x, self.profileBtn.frame.origin.y,
                                         self.view.frame.size.width, self.profileBtn.frame.size.height)];

    [self.paymentBtn setFrame:CGRectMake(self.paymentBtn.frame.origin.x, self.paymentBtn.frame.origin.y,
                                         self.view.frame.size.width, self.paymentBtn.frame.size.height)];

    [self.changePasswordBtn setFrame:CGRectMake(self.changePasswordBtn.frame.origin.x, self.changePasswordBtn.frame.origin.y,
                                                self.view.frame.size.width, self.changePasswordBtn.frame.size.height)];
    [self.helpBtn setFrame:CGRectMake(self.helpBtn.frame.origin.x, self.helpBtn.frame.origin.y, self.view.frame.size.width,
                                      self.helpBtn.frame.size.height)];
    [self.tutorialBtn setFrame:CGRectMake(self.tutorialBtn.frame.origin.x, self.tutorialBtn.frame.origin.y,
                                          self.view.frame.size.width, self.tutorialBtn.frame.size.height)];
    [self.faqsBtn setFrame:CGRectMake(self.faqsBtn.frame.origin.x, self.faqsBtn.frame.origin.y,
                                      self.view.frame.size.width, self.faqsBtn.frame.size.height)];
    [self.contactBtn setFrame:CGRectMake(self.contactBtn.frame.origin.x, self.contactBtn.frame.origin.y,
                                         self.view.frame.size.width, self.contactBtn.frame.size.height)];
    [self.rateBtn setFrame:CGRectMake(self.rateBtn.frame.origin.x, self.rateBtn.frame.origin.y,
                                      self.view.frame.size.width, self.rateBtn.frame.size.height)];
    [self.termsPrivacyBtn setFrame:CGRectMake(self.termsPrivacyBtn.frame.origin.x, self.termsPrivacyBtn.frame.origin.y,
                                              self.view.frame.size.width, self.termsPrivacyBtn.frame.size.height)];
    [self.logOutBtn setFrame:CGRectMake(self.logOutBtn.frame.origin.x, self.logOutBtn.frame.origin.y,
                                        self.view.frame.size.width, self.logOutBtn.frame.size.height)];
    
    [self.divider0 setFrame:CGRectMake(self.divider0.frame.origin.x, self.divider0.frame.origin.y,
                                       self.view.frame.size.width, self.divider0.frame.size.height)];
    [self.divider1 setFrame:CGRectMake(self.divider1.frame.origin.x, self.divider1.frame.origin.y,
                                       self.view.frame.size.width, self.divider1.frame.size.height)];
    [self.divider2 setFrame:CGRectMake(self.divider2.frame.origin.x, self.divider2.frame.origin.y,
                                       self.view.frame.size.width, self.divider2.frame.size.height)];
    [self.divider2 setFrame:CGRectMake(self.divider2.frame.origin.x, self.divider2.frame.origin.y,
                                       self.view.frame.size.width, 0)];

    [self.divider3 setFrame:CGRectMake(self.divider3.frame.origin.x, self.divider3.frame.origin.y,
                                       self.view.frame.size.width, self.divider3.frame.size.height)];
    [self.divider4 setFrame:CGRectMake(self.divider4.frame.origin.x, self.divider4.frame.origin.y,
                                       self.view.frame.size.width, self.divider4.frame.size.height)];
    [self.divider5 setFrame:CGRectMake(self.divider5.frame.origin.x, self.divider5.frame.origin.y,
                                       self.view.frame.size.width, self.divider5.frame.size.height)];
    [self.divider6 setFrame:CGRectMake(self.divider6.frame.origin.x, self.divider6.frame.origin.y,
                                       self.view.frame.size.width, self.divider6.frame.size.height)];
    [self.divider7 setFrame:CGRectMake(self.divider7.frame.origin.x, self.divider7.frame.origin.y,
                                       self.view.frame.size.width, self.divider7.frame.size.height)];
    [self.divider8 setFrame:CGRectMake(self.divider8.frame.origin.x, self.divider8.frame.origin.y,
                                       self.view.frame.size.width, self.divider8.frame.size.height)];
    [self.divider9 setFrame:CGRectMake(self.divider9.frame.origin.x, self.divider9.frame.origin.y,
                                       self.view.frame.size.width, self.divider9.frame.size.height)];
    [self.divider10 setFrame:CGRectMake(self.divider10.frame.origin.x, self.divider10.frame.origin.y,
                                        self.view.frame.size.width, self.divider10.frame.size.height)];
    [self.divider11 setFrame:CGRectMake(self.divider11.frame.origin.x, self.divider11.frame.origin.y,
                                        self.view.frame.size.width, self.divider11.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialze user info
    self.user = [UserInfo user];
    
    //initialize min and max for settings and help
    settings_min = 65.0f;
    settings_max = 157.0f;  //157.0f   203.0f
    help_min = 65.0f;
    help_max = 292.0f;
    
    //show menu top bar
    [self.menuTopView setHidden:NO];
    
    //set scroll view delegate and content size
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.logoutView.frame.origin.y + self.logoutView.frame.size.height)];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)settings:(id)sender {
    
    //animate settings view open or closed
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.settingsView setFrame:CGRectMake(self.settingsView.frame.origin.x, self.settingsView.frame.origin.y, self.settingsView.frame.size.width, (self.settingsView.frame.size.height == settings_min) ? settings_max : settings_min)];
        [self.helpView setFrame:CGRectMake(self.helpView.frame.origin.x, self.settingsView.frame.origin.y + self.settingsView.frame.size.height, self.helpView.frame.size.width, self.helpView.frame.size.height)];
        [self.logoutView setFrame:CGRectMake(self.logoutView.frame.origin.x, self.helpView.frame.origin.y + self.helpView.frame.size.height, self.view.frame.size.width, self.logoutView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        //set new content size of scroll view
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.logoutView.frame.origin.y + self.logoutView.frame.size.height)];
        
    }];
    
}

- (IBAction)help:(id)sender {
    
    //animate help view open or closed
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.helpView setFrame:CGRectMake(self.helpView.frame.origin.x, self.helpView.frame.origin.y, self.helpView.frame.size.width, (self.helpView.frame.size.height == help_min) ? help_max : help_min)];
        [self.logoutView setFrame:CGRectMake(self.logoutView.frame.origin.x, self.helpView.frame.origin.y + self.helpView.frame.size.height, self.view.frame.size.width, self.logoutView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        //set new content size of scroll view
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.logoutView.frame.origin.y + self.logoutView.frame.size.height)];
        
    }];
    
}

- (void)noAccount {
    
    //setup alert and ask user to confirm log out action
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame withMessage:@"Πρέπει να συνδεθείς η να φτιάξεις νέο λογαριασμό"];
    
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"Αργότερα" forState:UIControlStateNormal];
    
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Τώρα" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:1];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (IBAction)logout:(id)sender {
    
    //setup alert and ask user to confirm log out action
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame withMessage:@"Σίγουρα θές να αποσυνδεθείς;"];
    
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"ΟΧΙ" forState:UIControlStateNormal];
    
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"ΝΑΙ" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:0];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
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
- (void) rightActionMethod:(int)method {
    
    switch (method) {
        case 0:
            self.user.username = @"1";  //FREE
            //post log out notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
            break;
        case 1:
            //post log out notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
            break;
    }
    

    
}

- (IBAction)profile:(id)sender {
    
    if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        //no account? stay or logout/create a new account
        [self noAccount];        
    }
    else{
        //segue to profile view
        Menu *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
        [self.navigationController presentViewController:viewController animated:YES completion:nil];
    }
    
}

- (IBAction)payment:(id)sender {
    
    if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        //no account? stay or logout/create a new account
        [self noAccount];
    }
    else{
        //segue to payment view
        Menu *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
        [self.navigationController presentViewController:viewController animated:YES completion:nil];
    }
    
}

- (IBAction)changePassword:(id)sender {
    
    if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        //no account? stay or logout/create a new account
        [self noAccount];
    }
    else{
        //segue to payment view
        Menu *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"changePassword"];
        [self.navigationController presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)tutorial:(id)sender {
    
    //segue to tutorial view
    [(MainViewController *)self.parentViewController showTutorial];
    
}

- (IBAction)faqs:(id)sender {
    
    //segue to FAQs view
    Menu *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQs"];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)contact:(id)sender {
    
    //if device can send mail, begin composing message - otherwise, alert user they can send emails from their device
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"OPA Feedback"];
        [mailView setMessageBody:@"" isHTML:NO];
        [mailView setToRecipients:[NSArray arrayWithObject:@"support@organicparking.com"]];
        
        [self presentViewController:mailView animated:YES completion:NULL];
        
    } else {
        
        self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.parentViewController.view.frame withMessage:@"Δυστυχώς η συσκευή σου δεν υποστηρίζει ηλεκτρονική διεύθυνση. Μπορείς αν επικοινωνήσεις μαζί μας στο support@opaopaopa.com"];
        [self.customAlert.leftButton setTitle:@"OK" forState:UIControlStateNormal];
        self.customAlert.customAlertDelegate = self;
        [self.parentViewController.view addSubview:self.customAlert];
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
        
    }
    
}

//prints email resulting status and dismisses MFMailComposeViewController
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Mail canceled");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
            
        default:
            break;
            
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)rate:(id)sender {
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    
//    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.alertBody = NSLocalizedString(@"Hello", nil);
//    notification.alertAction = NSLocalizedString(@"Take Action", nil);
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber = 1;
//    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"Local Notification" forKey:@"type"];
//    notification.userInfo = infoDict;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    //send user to app store to rate...will want to confirm this action before
    NSString *url = @"itms-apps://itunes.apple.com/app/id";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAppendingString:self.user.appID]]];
    
}

- (IBAction)termsandprivacy:(id)sender {
    
    //segue to terms and privacy view
    Menu *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"termsandprivacy"];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
    
}

@end
