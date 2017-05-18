//
//  RequesterInfo.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface RequesterInfo : UIViewController <CustomAlertDelegate>

//view and contents
@property (strong, nonatomic) IBOutlet UIView *requestView; //view to hold contents of deal response
@property (strong, nonatomic) IBOutlet UIImageView *requesterImageView; //displays requester profile image
@property (strong, nonatomic) IBOutlet UILabel *requesterUsername; //displays requester username
@property (strong, nonatomic) IBOutlet UIView *starView; //view for containing requester star rating
@property (strong, nonatomic) IBOutlet UIImageView *starOne; //indicates requester has at least a one star rating
@property (strong, nonatomic) IBOutlet UIImageView *starTwo; //indicates requester has at least a two star rating
@property (strong, nonatomic) IBOutlet UIImageView *starThree; //indicates requester has at least a three star rating
@property (strong, nonatomic) IBOutlet UIImageView *starFour; //indicates requester has at least a four star rating
@property (strong, nonatomic) IBOutlet UIImageView *starFive; //indicates requester has at least a five star rating
@property (strong, nonatomic) IBOutlet UILabel *numDealsLabel; //display number of ratings user has
@property (strong, nonatomic) IBOutlet UIButton *denyBtn; //denies request made by requester
@property (strong, nonatomic) IBOutlet UIButton *acceptBtn; //accepts request made by requester

//view variables
@property (nonatomic, strong) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

@end
