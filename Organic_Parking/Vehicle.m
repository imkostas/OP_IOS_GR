//
//  vehicle.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle

@synthesize ID;
@synthesize hasVehicle;
@synthesize make;
@synthesize model;
@synthesize color;
@synthesize size;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        self.ID = 0;
        self.hasVehicle = NO;
        self.make = @"";
        self.model = @"";
        self.color = @"color";
        self.size = 0;
        
    }
    
    return self;
    
}

- (id)initWithVehicle:(int)IDENTIFIER make:(NSString *)MAKE model:(NSString *)MODEL color:(NSString *)COLOR size:(int)SIZE {
    
    self = [super init];
    
    if(self){
        
        self.hasVehicle = YES;
        self.ID = IDENTIFIER;
        self.make = MAKE;
        self.model = MODEL;
        self.color = COLOR;
        self.size = SIZE;
        
    }
    
    return self;
    
}

@end
