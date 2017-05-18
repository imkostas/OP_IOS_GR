//
//  PaymentMethod.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
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
