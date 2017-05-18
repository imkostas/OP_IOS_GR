//
//  FundingSource.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@interface SubMerchant : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *dateOfBirth;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;

@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSString *venmoEmail;
@property (nonatomic, strong) NSString *venmoPhone;
@property (nonatomic, strong) NSString *accountNumber;

@end
