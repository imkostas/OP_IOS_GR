//
//  DetailPaymentCell.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface DetailPaymentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *type;
@property (strong, nonatomic) IBOutlet UILabel *lastFour;
@property (strong, nonatomic) IBOutlet UILabel *expiration;

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIView *divider;

@end
