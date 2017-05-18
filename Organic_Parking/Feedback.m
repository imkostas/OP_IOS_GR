//
//  Feedback.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Feedback.h"

@implementation Feedback

@synthesize ratee;
@synthesize swapTime;
@synthesize status;
@synthesize postID;

- (id)init {
    
    self = [super init];
    
    if(self){
        
        ratee = @"";
        swapTime = nil;
        status = 0;
        postID = 0;
        
    }
    
    return self;
    
}

- (id)initWithRatee:(NSString *)RATEE swapTime:(NSDate *)SWAPTIME status:(unsigned int)STATUS postID:(unsigned int)POSTID {
    
    self = [super init];
    
    if(self){
        
        ratee = RATEE;
        swapTime = SWAPTIME;
        status = STATUS;
        postID = POSTID;
        
    }
    
    return self;
    
}

@end
