//
//  LinkedFundingSourceHeader.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "LinkedFundingSourceHeader.h"

@implementation LinkedFundingSourceHeader

- (IBAction)updateFundingSource:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAccount" object:nil];
    
}

- (void)awakeFromNib
{
    
    [super awakeFromNib];
    // Enable autoresizing width for this cell and its contentView (not allowed to be set in the storyboard...
    // maybe because the project was created a while ago or something, I don't know -- also, there's nothing
    // stopping you from editing the storyboard's XML to add autoresizing, but this is easier)
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Set up autoresizing and content modes for the UI elements //
    
    // Header label (centered)
    [[self header] setContentMode:UIViewContentModeCenter]; // Used for centered UILabels
    [[self header] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Upper divider
    [[self upperDivider] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Container (keep it centered, no width change)
    [[self container] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Lower divider
    [[self lowerDivider] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Change account button (keep it centered, no width change)
    [[self changeAccountBtn] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
}

@end
