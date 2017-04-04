//
//  BraintreeUser.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "PaymentMethod.h"
#import "SubMerchant.h"

@interface BraintreeUser : NSObject

@property (nonatomic, strong) NSString *customerID;
@property (nonatomic, strong) NSString *clientToken;
@property (nonatomic, strong) NSArray *paymentMethods;
@property (nonatomic, strong) SubMerchant *subMerchant;

@property (nonatomic) BOOL shouldRefreshSubMerchant;

- (NSArray *)parsePaymentMethods:(NSArray *)methods;

@end
