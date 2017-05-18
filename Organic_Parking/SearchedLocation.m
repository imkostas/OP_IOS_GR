//
//  SearchedLocation.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "SearchedLocation.h"

@implementation SearchedLocation

@synthesize address;
@synthesize coordinate;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        address = @"";
        coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
        
    }
    
    return self;
    
}

- (id)initWithSearchedLocation:(NSString *)ADDRESS withCoordinate:(CLLocationCoordinate2D)COORDINATE {
    
    self = [super init];
    
    if(self){
        
        self.address = ADDRESS;
        self.coordinate = COORDINATE;
        
    }
    
    return self;
    
}

@end
