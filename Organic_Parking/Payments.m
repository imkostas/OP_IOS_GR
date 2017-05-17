//
//  Payments.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Payments.h"

@interface Payments ()

@end

@implementation Payments

#define NUM_SECTIONS 1
#define ROW_HEIGHT 75.0
#define TOP_BAR_HEIGHT 65.0
#define NO_FUNDING_SOURCE_HEADER 187.0
#define NO_PAYMENT_METHOD_HEADER 102.0
#define LINKED_PAYMENT_METHOD_HEADER 70.0
#define LINKED_FUNDING_SOURCE_HEADER 240.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelViewBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.cancelViewBtn.frame.size.height, self.cancelViewBtn.frame.size.width, self.cancelViewBtn.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.topBar.frame.size.height)];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    self.rowToDelete = -1;
    
    //set delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPaymentInfo) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushFundingSourceView) name:@"AddAccount" object:nil];

}

- (void)userDidCancelPayment {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    static NSString *cellIdentifierNFS = @"nofundingsource";
    self.noFundingSourceHeader = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifierNFS];
    static NSString *cellIdentifierLFS = @"linkedfundingsource";
    self.linkedFundingSourceHeader = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifierLFS];
    static NSString *cellIdentifierLPM = @"linkedpaymentmethod";
    self.linkedPaymentMethodHeader = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifierLPM];
    static NSString *cellIdentifierNPM = @"nopaymentmethod";
    self.noPaymentMethodHeader = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifierNPM];
    
    if(self.user.braintree.shouldRefreshSubMerchant){
        
        self.user.braintree.shouldRefreshSubMerchant = NO;
        [self fetchSubMerchant];
        
    }
    
    //check if client token, payment methods, and sub merchant account info available
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    switch (self.user.code) {
        case MISSING_PAYMENT_METHOD:
            [self customAlert:@"You must add a payment method before requesting. \n\nIf you request a spot for $0 you don't have to." withDone:@"OK"];
            break;
        
        case MISSING_FUNDING_SOURCE:
            [self customAlert:@"You must add an account before posting \n\nIf you post a spot for $0 you don't have to." withDone:@"OK"];
            break;
        
        case EXPIRED_PAYMENT_METHOD:
            [self customAlert:@"The card associated with your account has expired. Change card to request spot."
                     withDone:@"OK"];
            break;
            
        default:
            NSLog(@"No code thrown");
            break;
    }
    
    self.user.code = NO_MESSAGE;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)cancelView:(id)sender {
    
    //dismisses view
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)pushFundingSourceView{
    
    self.user.code = ([self.user.braintree.subMerchant.ID isEqualToString:@""]) ? ADD_ACCOUNT : CHANGE_ACCOUNT;
    
    //segue to funding1
    Payments *funding1 = [self.storyboard instantiateViewControllerWithIdentifier:@"funding1"];
    [self.navigationController pushViewController:funding1 animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if([self.user.braintree.subMerchant.ID isEqualToString:@""]){
        
        if(self.user.braintree.paymentMethods.count){
            
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, NO_FUNDING_SOURCE_HEADER + LINKED_PAYMENT_METHOD_HEADER)];
            [header setBackgroundColor:[UIColor whiteColor]];
            
            [self setupNoFundingSourceHeader];
            [self setupLinkedPaymentMethodHeader:NO_FUNDING_SOURCE_HEADER];
            
            [header addSubview:self.noFundingSourceHeader];
            [header addSubview:self.linkedPaymentMethodHeader];
            
            return header;
            
        } else {
            
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, NO_FUNDING_SOURCE_HEADER + NO_PAYMENT_METHOD_HEADER)];
            [header setBackgroundColor:[UIColor whiteColor]];
            
            [self setupNoFundingSourceHeader];
            [self setupNoPaymentMethodHeader:NO_FUNDING_SOURCE_HEADER];
            
            [header addSubview:self.noFundingSourceHeader];
            [header addSubview:self.noPaymentMethodHeader];
            
            return header;
            
        }
        
    } else {
        
        if(self.user.braintree.paymentMethods.count){
            
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, LINKED_FUNDING_SOURCE_HEADER + LINKED_PAYMENT_METHOD_HEADER)];
            [header setBackgroundColor:[UIColor whiteColor]];
            
            [self setupLinkedFundingSourceHeader];
            [self setupLinkedPaymentMethodHeader:LINKED_FUNDING_SOURCE_HEADER];
            
            [header addSubview:self.linkedFundingSourceHeader];
            [header addSubview:self.linkedPaymentMethodHeader];
            
            return header;
            
        } else {
            
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, LINKED_FUNDING_SOURCE_HEADER + NO_PAYMENT_METHOD_HEADER)];
            [header setBackgroundColor:[UIColor whiteColor]];
            
            [self setupLinkedFundingSourceHeader];
            [self setupNoPaymentMethodHeader:LINKED_FUNDING_SOURCE_HEADER];
            
            [header addSubview:self.linkedFundingSourceHeader];
            [header addSubview:self.noPaymentMethodHeader];
            
            return header;
            
        }
        
    }
    
}

- (void)setupNoPaymentMethodHeader:(float)offset {
    
    [self.noPaymentMethodHeader setFrame:CGRectMake(0, offset, self.tableView.frame.size.width, NO_PAYMENT_METHOD_HEADER)];
    [self.noPaymentMethodHeader.header setFrame:CGRectMake(0, 5, self.tableView.frame.size.width, 65)];
    [self.noPaymentMethodHeader.subHeader setFrame:CGRectMake(self.tableView.frame.size.width/2 - 124, 48, 248, 60)];
    
}

- (void)setupLinkedPaymentMethodHeader:(float)offset {
    
    [self.linkedPaymentMethodHeader setFrame:CGRectMake(0, offset, self.tableView.frame.size.width, LINKED_PAYMENT_METHOD_HEADER)];
    [self.linkedPaymentMethodHeader.header setFrame:CGRectMake(0, 5, self.tableView.frame.size.width, 65)];
    [self.linkedPaymentMethodHeader.divider setFrame:CGRectMake(0, 69, self.tableView.frame.size.width, 1)];
    
}

- (void)setupNoFundingSourceHeader {
    
    [self.noFundingSourceHeader setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, NO_FUNDING_SOURCE_HEADER)];
    [self.noFundingSourceHeader.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
    [self.noFundingSourceHeader.subHeader setFrame:CGRectMake(self.tableView.frame.size.width/2 - 124, 48, 248, 60)];
    [self.noFundingSourceHeader.addAccountBtn setFrame:CGRectMake(self.tableView.frame.size.width/2 - 140, 118, self.noFundingSourceHeader.addAccountBtn.frame.size.width, 55)];
    
}

- (void)setupLinkedFundingSourceHeader {
    
    [self.linkedFundingSourceHeader setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, LINKED_FUNDING_SOURCE_HEADER)];
    [self.linkedFundingSourceHeader.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70.0)];
    [self.linkedFundingSourceHeader.upperDivider setFrame:CGRectMake(0, self.linkedFundingSourceHeader.header.frame.size.height, self.tableView.frame.size.width, 1)];
    [self.linkedFundingSourceHeader.container setFrame:CGRectMake(self.linkedFundingSourceHeader.frame.size.width/2 - MAX_WIDTH/2, self.linkedFundingSourceHeader.header.frame.size.height + 1, MAX_WIDTH, self.linkedFundingSourceHeader.container.frame.size.height)];
    [self.linkedFundingSourceHeader.lowerDivider setFrame:CGRectMake(0, 145, self.tableView.frame.size.width, 1)];
    [self.linkedFundingSourceHeader.changeAccountBtn setFrame:CGRectMake(self.tableView.frame.size.width/2 - 140, 166, self.linkedFundingSourceHeader.changeAccountBtn.frame.size.width, 55)];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if([self.user.braintree.subMerchant.ID isEqualToString:@""]){
        
        if(self.user.braintree.paymentMethods.count){
            
            return NO_FUNDING_SOURCE_HEADER + LINKED_PAYMENT_METHOD_HEADER;
            
        } else {
            
            return NO_FUNDING_SOURCE_HEADER + NO_PAYMENT_METHOD_HEADER;
            
        }
        
    } else {
        
        [self.linkedFundingSourceHeader.fundingStatus setText:[NSString stringWithFormat:@"Status: %@", self.user.braintree.subMerchant.status]];
        
        if([self.user.braintree.subMerchant.status isEqualToString:@"active"]){
            
            if([self.user.braintree.subMerchant.destination isEqualToString:@"email"]){
                
                [self.linkedFundingSourceHeader.fundingImage setImage:[UIImage imageNamed:@"Venmo"]];
                [self.linkedFundingSourceHeader.fundingDetails setText:[NSString stringWithFormat:@"Email: %@", self.user.braintree.subMerchant.venmoEmail]];
                
            } else if([self.user.braintree.subMerchant.destination isEqualToString:@"mobile_phone"]) {
                
                [self.linkedFundingSourceHeader.fundingImage setImage:[UIImage imageNamed:@"Venmo"]];
                [self.linkedFundingSourceHeader.fundingDetails setText:[NSString stringWithFormat:@"Mobile Phone: %@", self.user.braintree.subMerchant.venmoPhone]];
                
            } else {
                
                [self.linkedFundingSourceHeader.fundingImage setImage:[UIImage imageNamed:@"Bank Account"]];
                [self.linkedFundingSourceHeader.fundingDetails setText:[NSString stringWithFormat:@"Bank Account: ...%@", self.user.braintree.subMerchant.accountNumber]];
                
            }
            
        } else if([self.user.braintree.subMerchant.status isEqualToString:@"pending"]) {
            
            [self.linkedFundingSourceHeader.fundingImage setImage:[UIImage imageNamed:@"Clear"]];
            [self.linkedFundingSourceHeader.fundingStatus setText:@""];
            [self.linkedFundingSourceHeader.fundingDetails setText:@"Pending account approval"];
            
        } else {
            
            [self.linkedFundingSourceHeader.fundingImage setImage:[UIImage imageNamed:@"Clear"]];
            [self.linkedFundingSourceHeader.fundingStatus setText:@""];
            [self.linkedFundingSourceHeader.fundingDetails setText:@"Account was declined. Try again."];
            
        }
        
        if(self.user.braintree.paymentMethods.count){
            
            return LINKED_FUNDING_SOURCE_HEADER + LINKED_PAYMENT_METHOD_HEADER;
            
        } else {
            
            return LINKED_FUNDING_SOURCE_HEADER + NO_PAYMENT_METHOD_HEADER;
            
        }
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return NUM_SECTIONS;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ROW_HEIGHT;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.user.braintree.paymentMethods.count + 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //initialize cell
    static NSString *cellIdentifier;
    
    if(indexPath.row < self.user.braintree.paymentMethods.count){
        
        PaymentMethod *card = [self.user.braintree.paymentMethods objectAtIndex:indexPath.row];
        if(card.isExpired){
            
            cellIdentifier = @"detailpaymentexpiredcell";
            
            DetailPaymentExpiredCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(!cell)cell = [[DetailPaymentExpiredCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.type setImage:[UIImage imageNamed:card.type]];
            [cell.lastFour setText:card.lastFour];
            [cell.expiration setText:card.expiration];
            [cell.issue setImage:[UIImage imageNamed:@"Issue"]];
            
            // 10/16/15: using autoresizing now
//            [cell.container setFrame:CGRectMake(self.tableView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, cell.container.frame.size.height)];
//            [cell.divider setFrame:CGRectMake(0, 69, self.tableView.frame.size.width, 1)];
            
            return cell;
            
        } else {
            
            cellIdentifier = @"detailpaymentcell";
            
            DetailPaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(!cell)cell = [[DetailPaymentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [cell.type setImage:[UIImage imageNamed:card.type]];
            [cell.lastFour setText:card.lastFour];
            [cell.expiration setText:card.expiration];

            // 10/16/15: using autoresizing now
//            [cell.container setFrame:CGRectMake(self.tableView.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, cell.container.frame.size.height)];
//            [cell.divider setFrame:CGRectMake(0, 69, self.tableView.frame.size.width, 1)];
            
            return cell;
            
        }
        
    } else {
        
        cellIdentifier = @"addpaymentcell";
        AddPaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            
            cell = [[AddPaymentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        
        if(self.user.braintree.paymentMethods.count){
            
            [cell.cardLabel setText:@"Change Card"];
            
        } else {
            
            [cell.cardLabel setText:@"Add Card"];
            
        }
        
        // 10/16/15: using autoresizing now
//        [cell.cardLabel setFrame:CGRectMake(self.tableView.frame.size.width/2 - 140, 20, 280, 55)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    }
    
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if(self.user.braintree.paymentMethods.count > 1 && indexPath.row != self.user.braintree.paymentMethods.count){
//        
//        return YES;
//        
//    } else {
//        
//        return NO;
//        
//    }
//    
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if(editingStyle == UITableViewCellEditingStyleDelete){
//        
//        self.rowToDelete = (int)indexPath.row;
//        
//        self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame withMessage:@"Are you sure you want to delete this payment method?"];
//        [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
//        [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
//        [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
//        [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
//        [self.customAlert.rightButton setTag:1];
//        
//        self.customAlert.customAlertDelegate = self;
//        
//        [self.parentViewController.view addSubview:self.customAlert];
//        [UIView animateWithDuration:0.2 animations:^{[self.customAlert setAlpha:1.0f];}];
//        
//    }
//    
//}
//
//- (void)deletePaymentMethod:(PaymentMethod *)card {
//    
//    //cerate HUD
//    [UserInfo createHUD:self.view withOffset:100.0f];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.braintree.customerID, @"customer_id",
//                            card.token, @"token", self.user.apiKey, @"api_key", nil];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@deletePaymentMethod", self.user.uri] parameters:params
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              
//              NSLog(@"%@", responseObject);
//              
//              [MBProgressHUD hideHUDForView:self.view animated:YES];
//              
//              NSMutableArray *cards = [[NSMutableArray alloc] init];
//              NSArray *methods = [responseObject valueForKey:@"payment_methods"];
//              
//              for(NSDictionary *method in methods){
//                  
//                  PaymentMethod *card = [[PaymentMethod alloc] init];
//                  [card setType:[[method valueForKeyPath:@"_attributes"] valueForKey:@"imageUrl"]];
//                  [card setLastFour:[[method valueForKeyPath:@"_attributes"] valueForKey:@"last4"]];
//                  [card setExpiration:[[method valueForKeyPath:@"_attributes"] valueForKey:@"expirationDate"]];
//                  [card setToken:[[method valueForKeyPath:@"_attributes"] valueForKey:@"token"]];
//                  
//                  [cards addObject:card];
//                  
//              }
//              
//              self.user.braintree.paymentMethods = [NSArray arrayWithArray:cards];
//              
//              [self.tableView reloadData];
//              self.rowToDelete = -1;
//              
//          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              
//              NSLog(@"%@", operation.responseObject);
//              
//              [MBProgressHUD hideHUDForView:self.view animated:YES];
//              
//              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
//                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
//                  
//                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
//                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
//                  
//              } else {
//                  
//                  [self customAlert:@"We were unable to remove your payment method" withDone:@"OK"];
//                  
//              }
//              
//          }];
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.user.braintree.paymentMethods.count){
        
        Braintree *braintree = [Braintree braintreeWithClientToken:self.user.braintree.clientToken];
        
        BTDropInViewController *braintreeDropInViewController = [braintree dropInViewControllerWithDelegate:self];
        
        braintreeDropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelPayment)];
        [braintreeDropInViewController.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Avenir-Light" size:15.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
        
        UILabel *title = [[UILabel alloc] init];
        [title setText:@"Payment"];
        [title setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:24]];
        [title setTextColor:[UIColor darkGrayColor]];
        [title setFrame:CGRectMake(0, 0, 100, 45)];
        [title setTextAlignment:NSTextAlignmentCenter];
        [braintreeDropInViewController.navigationItem setTitleView:title];
        
        [braintreeDropInViewController setShouldHideCallToAction:YES];
        [braintreeDropInViewController.view setTintColor:OP_BLUE_COLOR];
        
        UINavigationController *braintreeNavigationController = [[UINavigationController alloc] initWithRootViewController:braintreeDropInViewController];
        
        [self presentViewController:braintreeNavigationController animated:YES completion:nil];
        
    } else if(indexPath.row == self.user.braintree.paymentMethods.count - 1) {
        
        PaymentMethod *payment = (PaymentMethod *)[self.user.braintree.paymentMethods objectAtIndex:0];
        if(payment.isExpired)[self customAlert:@"This card has expired. You will need to provide a valid card to request parking." withDone:@"OK"];
        
    }
    
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if([segue.identifier isEqualToString:@"detailSegue"]){
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        PaymentDetails *detailVeiw = segue.destinationViewController;
//        detailVeiw.card = [self.user.braintree.paymentMethods objectAtIndex:indexPath.row];
//        
//    } else if([segue.identifier isEqualToString:@"FundingSource"]){
//        
//        NSLog(@"I can pass variables here");
//        
//    }
//    
//}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    
    [UserInfo createHUD:self.parentViewController.view withOffset:130.0f];
    
    if(self.user.braintree.paymentMethods.count){
        
        PaymentMethod *method = [self.user.braintree.paymentMethods objectAtIndex:0];
        
        self.params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.braintree.customerID, @"customer_id",
                       paymentMethod.nonce, @"nonce", method.token, @"token", self.user.apiKey, @"api_key", nil];
        
    } else {
        
        self.params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.braintree.customerID, @"customer_id",
                  paymentMethod.nonce, @"nonce", self.user.apiKey, @"api_key", nil];
        
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@addPaymentMethod", self.user.uri] parameters:self.params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
             
             if([[responseObject valueForKey:@"payment_methods"] isKindOfClass:[NSArray class]]){
                 
                 self.user.braintree.paymentMethods = [self.user.braintree parsePaymentMethods:[responseObject valueForKey:@"payment_methods"]];
                 
             }
             
             if([responseObject valueForKey:@"client_token"]){
                 
                 [self.user.braintree setClientToken:[responseObject valueForKey:@"client_token"]];
                 
             } else {
                 
                 NSLog(@"Braintree generation of client token failed - drop in");
                 
             }
             
             [self.tableView reloadData];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
             
             NSLog(@"%@", operation.responseObject);
             
             if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                 
                 [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                          withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                 
             } else {
                 
                 [self customAlert:@"We were unable to add your payment method" withDone:@"OK"];
                 
             }
             
         }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)fetchSubMerchant {
    
    //cerate HUD
    [UserInfo createHUD:self.view withOffset:-110.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.user.braintree.subMerchant.ID, @"sub_merchant_id",
                            self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchSubMerchant", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              self.user.braintree.subMerchant.status = [responseObject valueForKey:@"status"];
              if([self.user.braintree.subMerchant.status isEqualToString:@"active"]){
                  
                  self.user.braintree.subMerchant.firstName = [responseObject valueForKey:@"first_name"];
                  self.user.braintree.subMerchant.lastName = [responseObject valueForKey:@"last_name"];
                  self.user.braintree.subMerchant.dateOfBirth = [responseObject valueForKey:@"date_of_birth"];
                  self.user.braintree.subMerchant.address = [responseObject valueForKey:@"street_address"];
                  self.user.braintree.subMerchant.city = [responseObject valueForKey:@"locality"];
                  self.user.braintree.subMerchant.state = [responseObject valueForKey:@"region"];
                  self.user.braintree.subMerchant.zip = [responseObject valueForKey:@"postal_code"];
                  
                  self.user.braintree.subMerchant.destination = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"destination"];
                  if([self.user.braintree.subMerchant.destination isEqualToString:@"email"]){
                      
                      self.user.braintree.subMerchant.venmoEmail = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"email"];
                      
                  } else if([self.user.braintree.subMerchant.destination isEqualToString:@"mobile_phone"]) {
                      
                      self.user.braintree.subMerchant.venmoPhone = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"mobile_phone"];
                      
                  } else {
                      
                      self.user.braintree.subMerchant.accountNumber = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"account_last_four"];
                      
                  }
                  
              }
              
              [self.tableView reloadData];
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
          }];
    
}

- (void)fetchPayemntMethods {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.user.braintree.customerID, @"customer_id", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchPaymentMethods", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              if([[responseObject valueForKey:@"payment_methods"] isKindOfClass:[NSArray class]]){
                  
                  self.user.braintree.paymentMethods = [self.user.braintree parsePaymentMethods:[responseObject valueForKey:@"payment_methods"]];
                  
              }
              
              [self.refreshControl endRefreshing];
              [self.tableView reloadData];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              [self.refreshControl endRefreshing];
              
          }];
    
}

- (void)fetchPaymentInfo {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.user.braintree.customerID, @"customer_id",
                            self.user.braintree.subMerchant.ID, @"sub_merchant_id",
                            self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchPaymentInfo", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              if([[responseObject valueForKey:@"payment_methods"] isKindOfClass:[NSArray class]]){
                  
                  self.user.braintree.paymentMethods = [self.user.braintree parsePaymentMethods:[responseObject valueForKey:@"payment_methods"]];
                  
              }
              
              if([[responseObject valueForKey:@"sub_merchant"] isKindOfClass:[NSDictionary class]]){
                  
                  self.user.braintree.subMerchant.status = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"status"];
                  if([self.user.braintree.subMerchant.status isEqualToString:@"active"]){
                      
                      self.user.braintree.subMerchant.firstName = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"first_name"];
                      self.user.braintree.subMerchant.lastName = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"last_name"];
                      self.user.braintree.subMerchant.dateOfBirth = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"date_of_birth"];
                      self.user.braintree.subMerchant.address = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"street_address"];
                      self.user.braintree.subMerchant.city = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"locality"];
                      self.user.braintree.subMerchant.state = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"region"];
                      self.user.braintree.subMerchant.zip = [[responseObject valueForKey:@"sub_merchant"] valueForKey:@"postal_code"];
                      
                      self.user.braintree.subMerchant.destination = [[[responseObject valueForKey:@"sub_merchant"] valueForKey:@"funding_source"] valueForKeyPath:@"destination"];
                      if([self.user.braintree.subMerchant.destination isEqualToString:@"email"]){
                          
                          self.user.braintree.subMerchant.venmoEmail = [[[responseObject valueForKey:@"sub_merchant"] valueForKey:@"funding_source"] valueForKeyPath:@"email"];
                          
                      } else if([self.user.braintree.subMerchant.destination isEqualToString:@"mobile_phone"]) {
                          
                          self.user.braintree.subMerchant.venmoPhone = [[[responseObject valueForKey:@"sub_merchant"] valueForKey:@"funding_source"] valueForKeyPath:@"mobile_phone"];
                          
                      } else {
                          
                          self.user.braintree.subMerchant.accountNumber = [[[responseObject valueForKey:@"sub_merchant"] valueForKey:@"funding_source"] valueForKeyPath:@"account_last_four"];
                          
                      }
                      
                  }
                  
              } else {
                  NSLog(@"sub_merchant not of type NSArray");
              }
              
              [self.refreshControl endRefreshing];
              [self.tableView reloadData];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              [self.refreshControl endRefreshing];
              
          }];
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert)[UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
    
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
    
//    switch (method) {
//        case 1:
//            if(self.rowToDelete != -1){
//                
//                [self deletePaymentMethod:[self.user.braintree.paymentMethods objectAtIndex:self.rowToDelete]];
//                
//            }
//            break;
//            
//        default:
//            break;
//    }
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

@end
