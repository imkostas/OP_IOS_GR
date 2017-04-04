//
//  vehicle.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface Vehicle : NSObject

@property (nonatomic) int ID;
@property (nonatomic) BOOL hasVehicle;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *color;
@property (nonatomic) unsigned int size;

- (id)initWithVehicle:(int)ID make:(NSString *)make model:(NSString *)model color:(NSString *)color size:(int)size;

@end
