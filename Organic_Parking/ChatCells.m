//
//  ChatCells.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "ChatCells.h"

@implementation ChatCells

@synthesize imageView;

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(20, 15, 50, 50)];
    
}

@end
