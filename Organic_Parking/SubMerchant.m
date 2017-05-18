//
//  FundingSource.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "SubMerchant.h"

@implementation SubMerchant

@synthesize ID;
@synthesize status;
@synthesize dateOfBirth;
@synthesize firstName;
@synthesize lastName;
@synthesize address;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize destination;
@synthesize venmoEmail;
@synthesize venmoPhone;
@synthesize accountNumber;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        self.ID = @"";
        self.status = @"";
        self.dateOfBirth = @"";
        self.firstName = @"";
        self.lastName = @"";
        self.address = @"";
        self.city = @"";
        self.state = @"";
        self.zip = @"";
        self.destination = @"";
        self.venmoEmail = @"";
        self.venmoPhone = @"";
        self.accountNumber = @"";
        
    }
    
    return self;
    
}

@end
