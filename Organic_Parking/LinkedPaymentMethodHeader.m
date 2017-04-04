//
//  LinkedPaymentMethodHeader.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "LinkedPaymentMethodHeader.h"

@implementation LinkedPaymentMethodHeader

- (void)awakeFromNib
{
    
    [super awakeFromNib];
    // Enable autoresizing width for this cell and its contentView (not allowed to be set in the storyboard...
    // maybe because the project was created a while ago or something, I don't know -- also, there's nothing
    // stopping you from editing the storyboard's XML to add autoresizing, but this is easier)
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Set up autoresizing and content modes for the UI elements //
    
    // Header label (keep centered)
    [[self header] setContentMode:UIViewContentModeCenter];
    [[self header] setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    // Divider (change width to match parent)
    [[self divider] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView's size matches the cell's bounds--
    // This seems to be necessary for a reason I'm not sure of. In the simulators, the divider at the bottom
    // of this cell is always cut off (but on real devices it's ok), because the contentView's height is
    // always 1pt smaller in height than the cell's given height. This same thing occurs for the
    // NoFundingSourceHeader cell also. My theory is that since these cells are not added to the TableView
    // in a 'usual' way, i.e. returned from -cellForRowAtIndexPath, but just added as subviews, there is some
    // code in UITableView that doesn't get run to resize these cells' contentViews to the correct size.
    [[self contentView] setFrame:[self bounds]];
    
//    NSLog(@"Cell frame: %@", [NSValue valueWithCGRect:[self frame]]);
//    NSLog(@"contentView frame: %@", [NSValue valueWithCGRect:[[self contentView] frame]]);
//    NSLog(@"divider frame: %@", [NSValue valueWithCGRect:[[self divider] frame]]);
}

@end
