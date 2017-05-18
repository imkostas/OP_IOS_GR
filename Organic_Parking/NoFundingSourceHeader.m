//
//  NoFundingSource.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "NoFundingSourceHeader.h"

@implementation NoFundingSourceHeader

- (IBAction)addAccount:(id)sender {
    
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
    
    // Header label
    [[self header] setContentMode:UIViewContentModeCenter];
    [[self header] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Sub-header label
    [[self subHeader] setContentMode:UIViewContentModeCenter];
    [[self subHeader] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Add Account button (keep it centered)
    [[self addAccountBtn] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
}

@end
