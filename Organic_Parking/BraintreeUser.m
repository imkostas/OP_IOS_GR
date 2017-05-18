//
//  BraintreeUser.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "BraintreeUser.h"

@implementation BraintreeUser

@synthesize customerID;
@synthesize clientToken;
@synthesize paymentMethods;
@synthesize subMerchant;
@synthesize shouldRefreshSubMerchant;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        self.customerID = @"";
        self.clientToken = @"";
        self.paymentMethods = [[NSArray alloc] init];
        self.subMerchant = [[SubMerchant alloc] init];
        self.shouldRefreshSubMerchant = NO;
        
    }
    
    return self;
    
}

- (NSArray *)parsePaymentMethods:(NSArray *)methods {
    
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    
    for(NSDictionary *method in methods){
        
        PaymentMethod *card = [[PaymentMethod alloc] init];
        [card setType:[[method valueForKeyPath:@"_attributes"] valueForKey:@"cardType"]];
        [card setLastFour:[[method valueForKeyPath:@"_attributes"] valueForKey:@"last4"]];
        [card setExpiration:[[method valueForKeyPath:@"_attributes"] valueForKey:@"expirationDate"]];
        [card setToken:[[method valueForKeyPath:@"_attributes"] valueForKey:@"token"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        /*  Deprecation fix
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[dateFormatter dateFromString:[NSString stringWithFormat:@"01/%@", card.expiration]]];
        */
        NSDateComponents* comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday fromDate:[dateFormatter dateFromString:[NSString stringWithFormat:@"01/%@", card.expiration]]];
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        
        if([NSDate date] == [[NSDate date] laterDate:[calendar dateFromComponents:comps]]){
            [card setIsExpired:YES];
        } else {
            [card setIsExpired:NO];
        }
        
        [cards addObject:card];
        
    }
    
    return [NSArray arrayWithArray:cards];
    
}

@end
