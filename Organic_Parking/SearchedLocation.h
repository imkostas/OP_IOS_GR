//
//  SearchedLocation.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@interface SearchedLocation : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithSearchedLocation:(NSString *)ADDRESS withCoordinate:(CLLocationCoordinate2D)COORDINATE;

@end
