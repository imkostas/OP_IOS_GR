//
//  FundingSource.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Funding1.h"

@interface Funding1 (){
    
    int activeTag;
    
}

@end

@implementation Funding1

#define SCROLL_VIEW_CONTENT_HEIGHT 428

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelBtn.frame.size.height, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
    [self.nextBtn setFrame:CGRectMake(self.view.frame.size.width - self.nextBtn.frame.size.width, self.topBar.frame.size.height - self.nextBtn.frame.size.height, self.nextBtn.frame.size.width, self.nextBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOP_BAR_HEIGHT)];
    [self.container setFrame:CGRectMake(self.scrollView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, SCROLL_VIEW_CONTENT_HEIGHT)];
//    [self.pickerView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.pickerView setFrame:self.view.frame];
    [self.pickerContainerView setFrame:CGRectMake(self.pickerView.frame.size.width/2 - self.pickerContainerView.frame.size.width/2, self.pickerView.frame.size.height/2 - self.pickerContainerView.frame.size.height/2, self.pickerContainerView.frame.size.width, self.pickerContainerView.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.user = [UserInfo user];
    
    activeTag = 0;
    self.braintreeFormattedDate = @"";
    
    [self.pickerView setAlpha:0.0f];
    [self.pickerView setHidden:YES];
    [self.view bringSubviewToFront:self.pickerView];
    
    self.keyboardControls = [[KeyboardControls alloc] init];
    [self.keyboardControls setDelegate:self];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, SCROLL_VIEW_CONTENT_HEIGHT)];
    
    [self.statePicker setDelegate:self];
    [self.statePicker setDataSource:self];
    
    [self.firstName setDelegate:self];
    [self.lastName setDelegate:self];
    [self.streetAddress setDelegate:self];
    [self.city setDelegate:self];
    [self.zipCode setDelegate:self];
    
    [self.firstName addTarget:self action:@selector(changedFundingSourceInfo) forControlEvents:UIControlEventEditingChanged];
    [self.lastName addTarget:self action:@selector(changedFundingSourceInfo) forControlEvents:UIControlEventEditingChanged];
    [self.streetAddress addTarget:self action:@selector(changedFundingSourceInfo) forControlEvents:UIControlEventEditingChanged];
    [self.city addTarget:self action:@selector(changedFundingSourceInfo) forControlEvents:UIControlEventEditingChanged];
    [self.zipCode addTarget:self action:@selector(changedZipCode) forControlEvents:UIControlEventEditingChanged];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    if(self.user.code == ADD_ACCOUNT){
        
        [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
        self.defaultDate = [self.dateFormatter stringFromDate:[NSDate date]];
        [self.datePicker setDate:[self.dateFormatter dateFromString:self.defaultDate]];
        [self.dateOfBirth setText:self.defaultDate];
        [self.dateOfBirth setTextColor:[UIColor colorWithWhite:0.75f alpha:1.0f]];
        [self.state setText:@"state"];
        [self.state setTextColor:[UIColor colorWithWhite:0.75f alpha:1.0f]];
        
        [self.nextBtn setEnabled:NO];
        [self.nextBtn setAlpha:0.5f];
        
    } else if(self.user.code == CHANGE_ACCOUNT) {
        
        [self.firstName setText:self.user.braintree.subMerchant.firstName];
        [self.lastName setText:self.user.braintree.subMerchant.lastName];
        [self.streetAddress setText:self.user.braintree.subMerchant.address];
        [self.city setText:self.user.braintree.subMerchant.city];
        [self.state setText:self.user.braintree.subMerchant.state];
        [self.zipCode setText:self.user.braintree.subMerchant.zip];
        
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *temp = [self.dateFormatter dateFromString:self.user.braintree.subMerchant.dateOfBirth];
        [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [self.dateOfBirth setText:[self.dateFormatter stringFromDate:temp]];
        [self.datePicker setDate:[self.dateFormatter dateFromString:self.dateOfBirth.text]];
        
    }
    
    //Add motion effects
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
    
    [self.pickerContainerView addMotionEffect:motionEffectGroup];
    
    //add keyboard action methods to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.states = [[NSArray alloc] initWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)dismissKeyboards {
    
    //dismiss keyboards
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.streetAddress resignFirstResponder];
    [self.city resignFirstResponder];
    [self.zipCode resignFirstResponder];
    
}

- (void)previousPressed {
    
    //calculate previous tag
    activeTag--;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 1:
            [self.firstName becomeFirstResponder];
            break;
            
        case 2:
            [self.lastName becomeFirstResponder];
            break;
            
        case 3:
            [self.streetAddress becomeFirstResponder];
            break;
            
        case 4:
            [self.zipCode becomeFirstResponder];
            break;
            
        default:
            activeTag = 0;
            [self dismissKeyboards];
            break;
    }
    
    [self changedFundingSourceInfo];
    
}

- (void)nextPressed {
    
    //calculate next tag
    activeTag++;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 2:
            [self.lastName becomeFirstResponder];
            break;
            
        case 3:
            [self.streetAddress becomeFirstResponder];
            break;
            
        case 4:
            [self.zipCode becomeFirstResponder];
            break;
            
        case 5:
            [self.city becomeFirstResponder];
            break;
            
        default:
            [self dismissKeyboards];
            activeTag = 0;
            break;
    }
    
    [self changedFundingSourceInfo];
    
}

- (void)donePressed {
    
    [self changedFundingSourceInfo];
    
    //dismiss keyboards
    [self dismissKeyboards];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //get active textfield and add keyboard controls to keyboard input accessory view
    activeTag = (int)textField.tag;
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:YES]];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(range.length + range.location > textField.text.length){
        return NO;
    }
    
    if(textField.tag == 4){
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
        
    }
    
    return YES;
    
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
    
    [self cancelViewConfirmed];
    
}

- (void)cancelViewConfirmed {
    
    self.user.code = NO_MESSAGE;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)next:(id)sender {
    
    [self dismissKeyboards];
    [self performSegueWithIdentifier:@"pushfunding2" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    Funding2 *destinationController = segue.destinationViewController;
    destinationController.subMerchant = [[SubMerchant alloc] init];
    destinationController.subMerchant.firstName = self.firstName.text;
    destinationController.subMerchant.lastName = self.lastName.text;
    destinationController.subMerchant.address = self.streetAddress.text;
    destinationController.subMerchant.city = self.city.text;
    destinationController.subMerchant.state = self.state.text;
    destinationController.subMerchant.zip = self.zipCode.text;
    
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *temp = [self.dateFormatter dateFromString:self.dateOfBirth.text];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    destinationController.subMerchant.dateOfBirth = [self.dateFormatter stringFromDate:temp];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.states.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.states objectAtIndex:row];
    
}

- (IBAction)showPickerView:(id)sender {
    
    [self dismissKeyboards];
    [self.pickerView setFrame:self.view.frame];
    [self.pickerView setHidden:NO]; // Can't see it yet, still at alpha 0.0
    
    UIButton *button = (UIButton *)sender;
    if(button.tag == 1){
        
        [self.pickerViewTitle setText:@"Date of Birth"];
        [self.statePicker setAlpha:0.0f];
        [self.datePicker setAlpha:1.0f];
        
    } else {
        
        [self.pickerViewTitle setText:@"State"];
        [self.statePicker setAlpha:1.0f];
        [self.datePicker setAlpha:0.0f];
        
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:1.0f];
        
    }];
    
}

- (IBAction)cancelPickerView:(id)sender {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
//        [self.pickerView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [self.pickerView setHidden:YES];
        
    }];
    
}

- (IBAction)donePickerView:(id)sender {
    
    if([self.pickerViewTitle.text isEqualToString:@"Date of Birth"]){
        
        [self.dateOfBirth setText:[self.dateFormatter stringFromDate:[self.datePicker date]]];
        [self.dateOfBirth setTextColor:[UIColor darkGrayColor]];
        
        self.braintreeFormattedDate = [NSString stringWithFormat:@"%@-%@-%@",
                                       [self.dateOfBirth.text substringWithRange:NSMakeRange(6, 4)],
                                       [self.dateOfBirth.text substringWithRange:NSMakeRange(0, 2)],
                                       [self.dateOfBirth.text substringWithRange:NSMakeRange(3, 2)]];
        
    } else {
        
        [self.state setText:[self.states objectAtIndex:[self.statePicker selectedRowInComponent:0]]];
        [self.state setTextColor:[UIColor darkGrayColor]];
        
    }
    
    [self changedFundingSourceInfo];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.pickerView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        
    }];
    
}

- (void)changedZipCode {
    
    if(self.zipCode.text.length == 5){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"%@%@&sensor=false", self.user.geocoding_uri, self.zipCode.text] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            NSArray *results = [responseObject valueForKeyPath:@"results"];
            NSDictionary *firstAddress = [results objectAtIndex:0];
            NSArray *addressComponents = [firstAddress objectForKey:@"address_components"];
            NSDictionary *city = [addressComponents objectAtIndex:1];
            NSDictionary *state = [addressComponents objectAtIndex:2];
            
            self.city.text = [city objectForKey:@"short_name"];
            [self.state setTextColor:[UIColor darkGrayColor]];
            self.state.text = [state objectForKey:@"short_name"];
            
            [self changedFundingSourceInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
            
        }];
        
    }
    
}

- (void)changedFundingSourceInfo {
    
    NSLog(@"Checking if funding details are valid");
    
    if([self.dateOfBirth.text isEqualToString:self.defaultDate] || [self.firstName.text isEqualToString:@""] ||
       [self.lastName.text isEqualToString:@""] || [self.streetAddress.text isEqualToString:@""] ||
       [self.city.text isEqualToString:@""] || [self.state.text isEqualToString:@""] ||
       [self.zipCode.text isEqualToString:@""] || self.zipCode.text.length < 5){
        
        [self.nextBtn setEnabled:NO];
        [self.nextBtn setAlpha:0.5f];
        
    } else {
        
        [self.nextBtn setEnabled:YES];
        [self.nextBtn setAlpha:1.0f];
        
    }
    
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
            [self cancelViewConfirmed];
            break;
            
        default:
            break;
    }
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

@end
