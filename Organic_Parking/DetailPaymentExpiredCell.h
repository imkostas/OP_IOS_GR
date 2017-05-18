//
//  DetailPaymentExpiredCell.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@interface DetailPaymentExpiredCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *type;
@property (strong, nonatomic) IBOutlet UILabel *lastFour;
@property (strong, nonatomic) IBOutlet UILabel *expiration;
@property (strong, nonatomic) IBOutlet UIImageView *issue;

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIView *divider;

@end
