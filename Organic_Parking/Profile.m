//
//  Profile.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Profile.h"

@interface Profile () {
    
    BOOL setCarColor; //indicates if car color was set/changed
    
    int carSize; //indicates selected car size
    int colorIndex; //indicates selected car color
    int activeTag; //used to get next/prev textfield via kayboard controls
    
}

@end

@implementation Profile

#define topBarHeight 65
#define CONTAINER_HEIGHT 485.0
#define profile_image_width 130

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //postition view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, topBarHeight)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelBtn.frame.size.height, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
    [self.saveBtn setFrame:CGRectMake(self.view.frame.size.width - self.saveBtn.frame.size.width, self.topBar.frame.size.height - self.saveBtn.frame.size.height, self.saveBtn.frame.size.width, self.saveBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    [self.container setFrame:CGRectMake(self.scrollView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, CONTAINER_HEIGHT)];
    [self.pickerView setFrame:self.view.frame];
    [self.pickerContainer setFrame:CGRectMake(self.pickerView.frame.size.width/2 - self.pickerContainer.frame.size.width/2, self.pickerView.frame.size.height/2 - self.pickerContainer.frame.size.height/2, self.pickerContainer.frame.size.width, self.pickerContainer.frame.size.height)];
    [self.profileImageLarge setFrame:self.scrollView.frame];
    [self.whiteShadow setFrame:self.scrollView.frame];
    
    [self.profileImage setFrame:CGRectMake(self.container.frame.size.width/2 - profile_image_width/2, 25,
                                           profile_image_width, profile_image_width)];
    [self.profileImage.layer setCornerRadius:profile_image_width/2];
    
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //user info
    self.user = [UserInfo user];
    
    //initialize keyboard controls
    self.keyboardControls = [[KeyboardControls alloc] init];
    
    //set delegates
    self.make.delegate = self;
    self.model.delegate = self;
    self.keyboardControls.delegate = self;
    self.scrollView.delegate = self;
    self.colorPicker.delegate = self;
    self.imagePicker.delegate = self;
    
    //initialize instance variables
    setCarColor = false;
    carSize = self.user.vehicle.size;
    colorIndex = 0;
    activeTag = 0;
    
    //set scroll view content size
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 485);
    
    //set username and email text
    self.username.text = [self.user.username uppercaseString];
    self.email.text = self.user.email;
    [self.pickerView setAlpha:0.0f];
    [self.saveBtn setEnabled:NO];
    [self.saveBtn setAlpha:0.5f];
    
    //set list of car colors
    self.arrayOfColors = [[NSArray alloc] initWithObjects:@"White", @"Black", @"Silver", @"Gold", @"Gray", @"Red", @"Blue", @"Brown", @"Yellow", @"Green", @"Pink", @"Orange", @"Purple", nil];
    
    //add keyboard action methods to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileImage) name:@"UpdateProfileImage" object:nil];
    
    [self.view bringSubviewToFront:self.pickerView];
    
    [self updateProfileImage];
    
    //setup car info
    if(self.user.vehicle.hasVehicle){
        
        [self.make setText:self.user.vehicle.make];
        [self.model setText:self.user.vehicle.model];
        [self.color setText:self.user.vehicle.color];
        
        //set proper icon for car size
        switch (self.user.vehicle.size) {
                
            case 1:
                [self.compact setImage:[UIImage imageNamed:@"Compact Dark"] forState:UIControlStateNormal];
                [self.midsize setImage:[UIImage imageNamed:@"Sedan Light"] forState:UIControlStateNormal];
                [self.large setImage:[UIImage imageNamed:@"SUV Light"] forState:UIControlStateNormal];
                break;
                
            case 2:
                [self.compact setImage:[UIImage imageNamed:@"Compact Light"] forState:UIControlStateNormal];
                [self.midsize setImage:[UIImage imageNamed:@"Sedan Dark"] forState:UIControlStateNormal];
                [self.large setImage:[UIImage imageNamed:@"SUV Light"] forState:UIControlStateNormal];
                break;
                
            case 3:
                [self.compact setImage:[UIImage imageNamed:@"Compact Light"] forState:UIControlStateNormal];
                [self.midsize setImage:[UIImage imageNamed:@"Sedan Light"] forState:UIControlStateNormal];
                [self.large setImage:[UIImage imageNamed:@"SUV Dark"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
                
        }
        
    } else {
        
        [self.color setText:self.user.vehicle.color];
        [self.color setTextColor:[UIColor colorWithWhite:0.75f alpha:1.0f]];
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
   
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidLoad];
    
    //if coming from todo, notify user why this view has appeared
    if(self.user.code == MISSING_VEHICLE){
        
        [self customAlert:@"You must add vehicle information to your profile before posting or requesting" withDone:@"Ok" withTag:0];
        self.user.code = NO_MESSAGE;
        
    }
    
    //initialize image picker
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    
    //initialze tap gesture and add to profile image view
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPickerSource)];
    [self.profileImage addGestureRecognizer:self.tap];
    [self.profileImage setUserInteractionEnabled:YES];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)updateProfileImage {
    
    if(self.user.profileImage){
        
        self.profileImage.image = self.user.profileImage;
        self.profileImageLarge.image = self.user.profileImage;
        
    } else {
        
        self.profileImage.image = [UIImage imageNamed:@"No Profile Image"];
        self.profileImageLarge.image = [UIImage imageNamed:@"Clear"];
        
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //get active textfield and add keyboard controls to keyboard input accessory view
    activeTag = (int)textField.tag;
    [textField setInputAccessoryView:[self.keyboardControls createControls:YES withNext:YES withDone:YES showNextPrev:YES]];
    
}

- (IBAction)makeChanged:(id)sender {
    
    [self changedVehicleInfo];
    
}

- (IBAction)modelChanged:(id)sender {
    
    [self changedVehicleInfo];
    
}

- (void)changedVehicleInfo {
    
    if([self.make.text isEqualToString:self.user.vehicle.make] && [self.model.text isEqualToString:self.user.vehicle.model] &&
       [self.color.text isEqualToString:self.user.vehicle.color] && carSize == self.user.vehicle.size){
        
        [self.saveBtn setEnabled:NO];
        [self.saveBtn setAlpha:0.5f];
        
    } else {
        
        [self.saveBtn setEnabled:YES];
        [self.saveBtn setAlpha:1.0f];
        
    }
    
}

- (void)dismissKeyboards {
    
    //dismiss keyboards
    [self.make resignFirstResponder];
    [self.model resignFirstResponder];
    
}

- (void)previousPressed {
    
    //calculate previous tag
    activeTag--;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 1:
            [self.make becomeFirstResponder];
            break;
            
        default:
            activeTag = 1;
            break;
    }
    
}

- (void)nextPressed {
    
    //calculate next tag
    activeTag++;
    
    //set proper textfield as first responder
    switch (activeTag) {
        case 2:
            [self.model becomeFirstResponder];
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

- (BOOL)validVehicleInfo {
    
    //save only if all car info is empty or all car info is set
    if(([self.make.text isEqualToString:@""] || [self.model.text isEqualToString:@""] || [self.color.text isEqualToString:@"color"] || carSize == 0)) {
        
        [self customAlert:@"You're missing some vehicle information" withDone:@"Ok" withTag:0];
        return NO;
        
    }
    
    return YES;
    
}

- (IBAction)cancelView:(id)sender {
    
    [self dismissKeyboards];
    
    if([self.saveBtn isEnabled]){
        
        //if alert already showing, hide it
        if(self.customAlert){
            
            //set custom alert alpha to 0
            [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
            
        }
        
        //setup alert and ask user to confirm log out action
        self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:@"Leave without saving?"];
        
        [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
        [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
        
        [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
        [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
        
        self.customAlert.customAlertDelegate = self;
        self.customAlert.tag = 1;
        
        [self.parentViewController.view addSubview:self.customAlert];
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
        
    } else {
        
        [self cancelViewConfirmed];
        
    }
    
}

- (void)cancelViewConfirmed {
    
    //dismiss view
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)updateVehicle:(id)sender {
    
    //dismiss keyboard if active
    [self dismissKeyboards];
    
    if([self validVehicleInfo]){
        
        //create HUD
        [UserInfo createHUD:self.view withOffset:0.0f];
        
        //disable save button to prevent rapid selection
        [self.saveBtn setEnabled:NO];
        [self.saveBtn setAlpha:0.5f];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%i", self.user.vehicle.ID], @"vehicle_id", self.user.username, @"username", self.make.text, @"car_make", self.model.text, @"car_model", self.color.text, @"car_color", [NSString stringWithFormat:@"%i", carSize], @"car_size", self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@updateVehicle", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSLog(@"%@", operation.responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  self.user.vehicle = [[Vehicle alloc] initWithVehicle:[[[responseObject valueForKeyPath:@"vehicle"] valueForKey:@"id"] intValue] make:[[responseObject valueForKeyPath:@"vehicle"] valueForKey:@"make"] model:[[responseObject valueForKeyPath:@"vehicle"] valueForKey:@"model"] color:[[responseObject valueForKeyPath:@"vehicle"] valueForKey:@"color"] size:[[[responseObject valueForKeyPath:@"vehicle"] valueForKey:@"size"] intValue]];
                  
                  [self customAlert:@"Your vehicle information has been updated" withDone:@"Ok" withTag:0];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  [self.saveBtn setEnabled:YES];
                  [self.saveBtn setAlpha:1.0f];
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withTag:0];
                      
                  } else {
                      
                      [self customAlert:@"Unable to update your vehicle information" withDone:@"Ok" withTag:0];
                      
                  }
                  
                  NSLog(@"%@", operation.responseObject);
                  
              }];
        
    }
    
}

- (IBAction)changePassword:(id)sender {
    
    //segue to change password view
    Profile *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"changePassword"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)getPickerSource {
    
    //create actionsheet prompting user how they want to add their profile photo
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // The action sheet needs to be presented differently between iPad and iPhone
    switch([[UIDevice currentDevice] userInterfaceIdiom])
    {
        case UIUserInterfaceIdiomPhone:
        {
            // Show the action sheet normally
            [actionSheet showInView:[self view]];
            break;
        }
            
        case UIUserInterfaceIdiomPad:
        {
            // On iPad, "this method displays the action sheet in a popover whose arrow points to the
            // specified rectangle of the view. The popover does not overlap the specified rectangle."
            // But, I think it would look a bit better if the arrow was moved upward to be slightly on top
            // of the image
            CGRect profImageFrame = [[self profileImage] frame];
            CGRect profImageFrameSmaller = CGRectInset(profImageFrame,
                                                       profImageFrame.size.width / 5,
                                                       profImageFrame.size.height / 5);
            
            // Show the sheet (giving it [self container] ensures that the (x,y) position is correct)
            [actionSheet showFromRect:profImageFrameSmaller inView:[self container] animated:YES];
            break;
        }
            
        case UIUserInterfaceIdiomTV:
        case UIUserInterfaceIdiomUnspecified:
        default:
            break;
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //if they want to take photo, set source type to camera - otherwise, set to photo library
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        
        [self takeCarImage:UIImagePickerControllerSourceTypeCamera];
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Existing"]) {
        
        [self takeCarImage:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
}

- (void)takeCarImage:(UIImagePickerControllerSourceType)sourceType {
    
    //set image picker source type to indicated source type
    if(sourceType == UIImagePickerControllerSourceTypeCamera){
        
        //check that camera is available
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.allowsEditing = YES;
            
        }
        else {
            
            [self customAlert:@"Your device is not capable of taking photos. Try choosing an existing image from your photo library." withDone:@"Ok" withTag:0];
            
        }
        
    } else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        //check that photo library is available
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.imagePicker setAllowsEditing:YES];
            
        }
        else {
            
            [self customAlert:@"We couldn't access your photo library" withDone:@"Ok" withTag:0];
            
        }
        
    } else {
        
        NSLog(@"Don't know what happened");
        
    }
    
    //present image picker based on source type
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    //dismiss imagepicker when finished selecting/taking photo
    //[picker dismissModalViewControllerAnimated:NO];  //deprecated
    [picker dismissViewControllerAnimated:NO completion:nil];
    [MBProgressHUD showHUDAddedTo:self.profileImage animated:YES];
    [self.cancelBtn setEnabled:NO];
    [self performSelector:@selector(uploadImage:) withObject:image afterDelay:0];
    
}

- (UIImage*)resizeImage:(UIImage*)image {
    
    //resize image to 400x400
    UIImage *tempImage = nil;
    CGSize targetSize = CGSizeMake(400, 400);
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size = targetSize;
    [image drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tempImage;
    
}

- (void)uploadImage:(UIImage *)image {
    
    UIImage *newProfileImage = [[UIImage alloc] init];
    newProfileImage = [self resizeImage:image];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.user.username, @"username",
                            self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@updateProfileImage", self.user.uri] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {[formData appendPartWithFileData: UIImagePNGRepresentation(newProfileImage) name:@"image" fileName:@"profile_image.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success: %@", responseObject);
        [self.profileImage setImage:newProfileImage];
        [self.profileImageLarge setImage:newProfileImage];
        self.user.profileImage = newProfileImage;
        [MBProgressHUD hideAllHUDsForView:self.profileImage animated:YES];
        [self.cancelBtn setEnabled:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", operation.responseObject);
        NSLog(@"Error: %@", error.description);
        [MBProgressHUD hideAllHUDsForView:self.profileImage animated:YES];
        [self.cancelBtn setEnabled:YES];
        
    }];
    
}

- (IBAction)setCarColor:(id)sender {
    
    //dismiss keyboard if active
    [self dismissKeyboards];
    
    //show view for selecting car color
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:1.0f];
        
    }];
    
}

- (IBAction)cancelCarColor:(id)sender {
    
    //dismiss view without saving selected color
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:0.0f];
        
    }];
    
}

- (IBAction)updateCarColor:(id)sender {
    
    //save selected color and set color object text to selected color
    self.color.text = [self.arrayOfColors objectAtIndex:colorIndex];
    [self.color setTextColor:[UIColor darkGrayColor]];
    [self changedVehicleInfo];
    
    //dismiss view
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.pickerView setAlpha:0.0f];
        
    }];
    
}

- (IBAction)setCarCompact:(id)sender {
    
    //set selected car to compact
    carSize = 1;
    [self.compact setImage:[UIImage imageNamed:@"Compact Dark"] forState:UIControlStateNormal];
    [self.midsize setImage:[UIImage imageNamed:@"Sedan Light"] forState:UIControlStateNormal];
    [self.large setImage:[UIImage imageNamed:@"SUV Light"] forState:UIControlStateNormal];
    [self changedVehicleInfo];
    
}

- (IBAction)setCarMidsize:(id)sender {
    
    //set selected car to midsize
    carSize = 2;
    [self.compact setImage:[UIImage imageNamed:@"Compact Light"] forState:UIControlStateNormal];
    [self.midsize setImage:[UIImage imageNamed:@"Sedan Dark"] forState:UIControlStateNormal];
    [self.large setImage:[UIImage imageNamed:@"SUV Light"] forState:UIControlStateNormal];
    [self changedVehicleInfo];
    
}

- (IBAction)setCarLarge:(id)sender {
    
    //set selected car to large
    carSize = 3;
    [self.compact setImage:[UIImage imageNamed:@"Compact Light"] forState:UIControlStateNormal];
    [self.midsize setImage:[UIImage imageNamed:@"Sedan Light"] forState:UIControlStateNormal];
    [self.large setImage:[UIImage imageNamed:@"SUV Dark"] forState:UIControlStateNormal];
    [self changedVehicleInfo];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    //set number of picker components
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    //shoud be number of colors in array
    return self.arrayOfColors.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    //return color at the index of row
    return [self.arrayOfColors objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //save selected car color
    colorIndex = (int)row;
    setCarColor = true;
    
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
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
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

@end
