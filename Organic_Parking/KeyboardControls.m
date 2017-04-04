//
//  KeyboardControls.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "KeyboardControls.h"

@implementation KeyboardControls

- (id)init {
    
    //return self
    return self;
    
}

- (UIToolbar *)createControls:(BOOL)prev withNext:(BOOL)next withDone:(BOOL)done showNextPrev:(BOOL)showNextPrev {
    
    //create toolbar for adding tool bar items
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    //create array of tool bar items
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
    
    //if next/prev desired, add to tool bar array
    if(showNextPrev){
        
        //next/prev appears as segmented control
        UISegmentedControl *nextPrevControls = [[UISegmentedControl alloc]
                                                initWithItems:[NSArray arrayWithObjects:@"Previous", @"Next", nil]];
        [nextPrevControls setEnabled:prev forSegmentAtIndex:0];
        [nextPrevControls setEnabled:next forSegmentAtIndex:1];
        nextPrevControls.momentary = YES; // do not preserve button's state
        nextPrevControls.tintColor = [UIColor colorWithRed:130/255.0f green:130/255.0f blue:130/255.0f alpha:1.0f];
        [nextPrevControls addTarget:self action:@selector(nextPrevPressed:) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *nextPrevControlItem = [[UIBarButtonItem alloc] initWithCustomView:nextPrevControls];
        [toolbarItems addObject:nextPrevControlItem];
        
    }
    
    //add flex space to push done to right side of tool bar
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolbarItems addObject:flexSpace];
    
    //add done button to tool bar items array
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)];
    NSDictionary *attributes =
    [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:130/255.0f green:130/255.0f blue:130/255.0f alpha:1.0f], NSForegroundColorAttributeName, nil];
    [doneButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [doneButton setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [toolbarItems addObject:doneButton];
    
    //add items to tool bar
    toolbar.items = toolbarItems;
    
    //return tool bar
    return toolbar;
    
}

- (void)nextPrevPressed:(id)sender {
    
    //if delegate
    if (!self.delegate) return;
    
    //call delegate method based on seelcted segment index
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
            
        case 0:
            [self.delegate previousPressed];
            break;
            
        case 1:
            [self.delegate nextPressed];
            break;
            
        default:
            break;
            
    }
    
}

- (void)dismissKeyboard:(id)sender {
    
    //if delegate
    if (!self.delegate) return;
    
    //call done delegate method
    [self.delegate donePressed];
    
}

@end
