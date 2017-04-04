//
//  PaymentMethod.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "PaymentMethod.h"

@implementation PaymentMethod

- (id)init {
    
    self = [super init];
    
    if(self){
        
        self.type = @"";
        self.lastFour = @"";
        self.expiration = @"";
        self.token = @"";
        
    }
    
    return self;
    
}

@end
