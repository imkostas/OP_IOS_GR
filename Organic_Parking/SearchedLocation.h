//
//  SearchedLocation.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface SearchedLocation : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithSearchedLocation:(NSString *)ADDRESS withCoordinate:(CLLocationCoordinate2D)COORDINATE;

@end
