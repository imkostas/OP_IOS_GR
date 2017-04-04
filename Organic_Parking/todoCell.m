//
//  todoCell.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "todoCell.h"

@implementation todoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code
        
    }
    
    return self;
    
}

- (void)awakeFromNib {
    
    // Initialization code
    
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
