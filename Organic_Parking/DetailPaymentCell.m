//
//  DetailPaymentCell.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "detailPaymentCell.h"

@implementation DetailPaymentCell

- (void)awakeFromNib
{
    
    [super awakeFromNib];
    // Enable autoresizing width for this cell and its contentView (not allowed to be set in the storyboard...
    // maybe because the project was created a while ago or something, I don't know -- also, there's nothing
    // stopping you from editing the storyboard's XML to add autoresizing, but this is easier)
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Set up autoresizing and content modes for the UI elements //
    
    // Container (keep centered)
    [[self container] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Divider (change width)
    [[self divider] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

@end
