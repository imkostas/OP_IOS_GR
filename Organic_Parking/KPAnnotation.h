//
// Copyright 2012 Bryan Bonczek
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKAnnotation.h>

@interface KPAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *subtitle;
@property (nonatomic, readwrite, assign) unsigned int type;
@property (nonatomic, readwrite, assign) unsigned int post_id;
@property (nonatomic, readwrite, copy) NSString *p_username;
@property (nonatomic, readwrite, copy) NSString *r_username;
@property (nonatomic, readwrite, assign) unsigned int status;
@property (nonatomic, readwrite, copy) NSString *address;
@property (nonatomic, readwrite, copy) NSString *city_region;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSDate *swap_time;
@property (nonatomic, readwrite, copy) NSString *date;
@property (nonatomic, readwrite, copy) NSString *time;
@property (nonatomic, readwrite, copy) NSString *AMPM;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) unsigned int paid;
@property (nonatomic, readwrite, assign) unsigned int details;
@property (nonatomic, readwrite, copy) NSString *car_make;
@property (nonatomic, readwrite, copy) NSString *car_model;
@property (nonatomic, readwrite, copy) NSString *car_color;
@property (nonatomic, readwrite, assign) unsigned int car_size;
@property (nonatomic, readwrite, copy) NSString *profile_image;
@property (nonatomic, readwrite, assign) unsigned int total_stars;
@property (nonatomic, readwrite, assign) unsigned int total_deals;

@property (nonatomic, readonly) float radius;
@property (nonatomic, readonly) NSSet *annotations;

- (id)initWithAnnotations:(NSArray *)annotations;
- (id)initWithAnnotationSet:(NSSet *)set;

// Helpers

// returns NO if the KPAnnotation only contains one annotation
- (BOOL)isCluster;


// Private (used by the internal clustering algorithm)
@property (nonatomic) NSValue *_annotationPointInMapView;

@end
