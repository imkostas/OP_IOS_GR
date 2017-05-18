//
//  DateFilter.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "DateFilter.h"

@implementation DateFilter

@synthesize date;
@synthesize dateInfo;
@synthesize time;
@synthesize ampm;
@synthesize window;
@synthesize isActive;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        date = nil;
        dateInfo = @"";
        time = @"";
        ampm = @"";
        window = 0;
        isActive = NO;
        
    }
    
    return self;
    
}

@end
