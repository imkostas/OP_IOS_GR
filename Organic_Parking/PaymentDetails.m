//
//  PaymentDetails.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "PaymentDetails.h"

@interface PaymentDetails ()

@end

@implementation PaymentDetails

#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, 0, self.topBar.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    [self.editBtn setFrame:CGRectMake(self.view.frame.size.width - self.editBtn.frame.size.width, self.topBar.frame.size.height - self.editBtn.frame.size.height, self.editBtn.frame.size.width, self.editBtn.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //set scroll view delegate and content size
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    //set card details using index of selected card
    [self.lastFour setText:self.card.lastFour];
    [self.exp setText:self.card.expiration];
    
    //initialze delete button and delete label to be disabled and hidden
    [self.deleteBtn setEnabled:NO];
    [self.deleteBtn setAlpha:0.0f];
    [self.deleteLabel setEnabled:NO];
    [self.deleteLabel setAlpha:0.0f];
    
    [self.type setImage:[UIImage imageNamed:@"Clear"]];
    self.imageTypeThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchPaymentImage:) object:self.card.type];
    [self.imageTypeThread start];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)fetchPaymentImage:(NSString *)url {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *img = [UIImage imageWithData:data];
    
    if(!img){
        
        [self.type setImage:[UIImage imageNamed:@"Clear"]];
        
    } else {
        
        [self.type setImage:img];
        
    }
    
    [NSThread exit];
    
}

- (IBAction)back:(id)sender {
    
    //if not in edit mode, pop view controller - otherwise, exit edit mode
    if([self.backBtn.titleLabel.text isEqualToString:@"Back"]){
     
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        
        [self.backBtn setTitle:@"Back" forState:UIControlStateNormal];
        [self.editBtn setTitle:@"Edit" forState:UIControlStateNormal];
        [self.editBtn setEnabled:YES];
        [self.editBtn setHidden:NO];
        
        [self.deleteBtn setEnabled:NO];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [self.deleteBtn setAlpha:0.0f];
            [self.deleteLabel setAlpha:0.0f];
            
        }];
        
    }
    
}

- (IBAction)editCard:(id)sender {
    
    //if not in edit mode, start edit mode - otherwise, update card info (update info has not been built out yet, which is why
    //Save below has been commented out)
    if([self.editBtn.titleLabel.text isEqualToString:@"Edit"]){
        
        [self.backBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        //[self.editBtn setTitle:@"Save" forState:UIControlStateNormal];
        [self.editBtn setEnabled:NO];
        [self.editBtn setHidden:YES];
        
        //if user has more than 1 card saved, allow them to delete - otherwise, notify them they must have at least one card
        if(self.user.braintree.paymentMethods.count > 1){
            
            [self.deleteBtn setEnabled:YES];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [self.deleteBtn setAlpha:1.0f];
                
            }];
            
        } else {
            
            [self.deleteLabel setEnabled:YES];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [self.deleteLabel setAlpha:1.0f];
                
            }];
            
        }
        
    } else {
        
        NSLog(@"Will save card info here");
        
    }
    
}

- (IBAction)deleteCard:(id)sender {
    
    //disable deleteBtn to prevent multiple delete requests
    [self.deleteBtn setEnabled:NO];
    
    //cerate HUD
    [UserInfo createHUD:self.view withOffset:100.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.username, @"username",
                            self.card.token, @"token", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@braintreeDeletePaymentMethod", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              NSMutableArray *cards = [[NSMutableArray alloc] init];
              NSArray *methods = [responseObject valueForKey:@"payment_methods"];
              
              for(NSDictionary *method in methods){
                  
                  PaymentMethod *card = [[PaymentMethod alloc] init];
                  [card setType:[[method valueForKeyPath:@"_attributes"] valueForKey:@"imageUrl"]];
                  [card setLastFour:[[method valueForKeyPath:@"_attributes"] valueForKey:@"last4"]];
                  [card setExpiration:[[method valueForKeyPath:@"_attributes"] valueForKey:@"expirationDate"]];
                  [card setToken:[[method valueForKeyPath:@"_attributes"] valueForKey:@"token"]];
                  
                  [cards addObject:card];
                  
              }
              
              self.user.braintree.paymentMethods = [NSArray arrayWithArray:cards];
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //pop view controller since card no longer exists
              [self.navigationController popViewControllerAnimated:YES];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              [self.deleteBtn setEnabled:YES];
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                  
              } else {
                  
                  [self customAlert:@"We were unable to remove your payment method" withDone:@"OK"];
                  
              }
              
          }];
    
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
