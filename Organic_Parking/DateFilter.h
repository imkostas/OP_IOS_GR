//
//  DateFilter.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@interface DateFilter : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *dateInfo;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *ampm;
@property (nonatomic) int window;
@property (nonatomic) BOOL isActive;

@end
