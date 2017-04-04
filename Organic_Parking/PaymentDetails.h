//
//  PaymentDetails.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "PaymentMethod.h"

@interface PaymentDetails : UIViewController <UIScrollViewDelegate, CustomAlertDelegate>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *backBtn; //dismisses view
@property (strong, nonatomic) IBOutlet UIButton *editBtn; //enters edit mode for user to delete payment info

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold contents of view
@property (strong, nonatomic) IBOutlet UIImageView *type; //image of payment type
@property (strong, nonatomic) IBOutlet UILabel *lastFour; //displays last four of card number
@property (strong, nonatomic) IBOutlet UILabel *exp; //dsiplays expiration date
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn; //deletes card from Stripe
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel; //notifies user they can't delete card if they only have 1

//view variables
@property (nonatomic,strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert
@property (nonatomic, strong) PaymentMethod *card;
@property (nonatomic, strong) NSThread *imageTypeThread;

@end
