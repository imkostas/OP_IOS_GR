//
//  PaymentMethod.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface PaymentMethod : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *lastFour;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *token;
@property (nonatomic) BOOL isExpired;


@end
