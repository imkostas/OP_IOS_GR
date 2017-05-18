//
//  Feedback.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feedback : NSObject

@property (nonatomic, strong) NSString *ratee;
@property (nonatomic, strong) NSDate *swapTime;
@property (nonatomic, readwrite, assign) unsigned int status;
@property (nonatomic, readwrite, assign) unsigned int postID;

- (id)initWithRatee:(NSString *)RATEE swapTime:(NSDate *)SWAPTIME status:(unsigned int)STATUS postID:(unsigned int)POSTID;

@end
