//
//  LinkedFundingSourceHeader.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface LinkedFundingSourceHeader : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *fundingImage;
@property (strong, nonatomic) IBOutlet UILabel *fundingDetails;
@property (strong, nonatomic) IBOutlet UILabel *fundingStatus;

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIView *upperDivider;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UIView *lowerDivider;
@property (strong, nonatomic) IBOutlet UIButton *changeAccountBtn;

@end
