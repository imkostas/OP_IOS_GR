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

#import "KPAnnotation.h"

@interface KPAnnotation ()

@property (nonatomic, readwrite) NSSet *annotations;
@property (nonatomic, readwrite) float radius;

@end

@implementation KPAnnotation


- (id)initWithAnnotations:(NSArray *)annotations {
    return [self initWithAnnotationSet:[NSSet setWithArray:annotations]];
}

- (id)initWithAnnotationSet:(NSSet *)set {
    self = [super init];
    
    if(self){
        self.annotations = set;
        if([self.annotations count]){
            KPAnnotation *ano = [[self.annotations allObjects] objectAtIndex:0];
            
            self.title = nil;
            self.subtitle = ano.subtitle;
            self.type = ano.type;
            self.post_id = ano.post_id;
            self.p_username = ano.p_username;
            self.r_username = ano.r_username;
            self.status = ano.status;
            self.address = ano.address;
            self.city_region = ano.city_region;
            self.coordinate = ano.coordinate;
            self.swap_time = ano.swap_time;
            self.date = ano.date;
            self.time = ano.time;
            self.AMPM = ano.AMPM;
            self.price = ano.price;
            self.paid = ano.paid;
            self.details = ano.details;
            self.car_make = ano.car_make;
            self.car_model = ano.car_model;
            self.car_color = ano.car_color;
            self.car_size = ano.car_size;
            self.profile_image = ano.profile_image;
            self.total_stars = ano.total_stars;
            self.total_deals = ano.total_deals;
            
        }
        
        [self calculateValues];
    }
    
    return self;
}

- (BOOL)isCluster {
    return (self.annotations.count > 1);
}

#pragma mark - Private

- (void)calculateValues {
    NSUInteger count = self.annotations.count;

    if (count == 0) {
        return;
    }

    if (count == 1) {
        self.radius = 0;
        self.coordinate = [[[self annotations] anyObject] coordinate];

        return;
    }

    CLLocationDegrees minLat = NSIntegerMax;
    CLLocationDegrees minLng = NSIntegerMax;
    CLLocationDegrees maxLat = NSIntegerMin;
    CLLocationDegrees maxLng = NSIntegerMin;

    CLLocationDegrees totalLat = 0;
    CLLocationDegrees totalLng = 0;

    NSUInteger idx = 0;
    CLLocationCoordinate2D coords[2];

    /* 
     This algorithm is approx. 1.2-2x faster than naive one.
     It is described here: https://github.com/EvgenyKarkan/EKAlgorithms/issues/30
     */
    for (id <MKAnnotation> ithAnnotation in self.annotations) {
        // Machine way of doing odd/even check is better than mathematical count % 2
        if (((idx++) & 1) == 0) {
            coords[0] = ithAnnotation.coordinate;

            continue;
        } else {
            coords[1] = ithAnnotation.coordinate;
        }

        CLLocationDegrees ithLatitude      = coords[0].latitude;
        CLLocationDegrees iplus1thLatitude = coords[1].latitude;

        CLLocationDegrees ithLongitude      = coords[0].longitude;
        CLLocationDegrees iplus1thLongitude = coords[1].longitude;

        if (ithLatitude < iplus1thLatitude) {
            minLat = MIN(minLat, ithLatitude);
            maxLat = MAX(maxLat, iplus1thLatitude);
        }
        else if (ithLatitude > iplus1thLatitude) {
            minLat = MIN(minLat, iplus1thLatitude);
            maxLat = MAX(maxLat, ithLatitude);
        }
        else {
            minLat = MIN(minLat, ithLatitude);
            maxLat = MAX(maxLat, ithLatitude);
        }

        if (ithLongitude < iplus1thLongitude) {
            minLng = MIN(minLng, ithLongitude);
            maxLng = MAX(maxLng, iplus1thLongitude);
        }
        else if (ithLongitude > iplus1thLongitude) {
            minLng = MIN(minLng, iplus1thLongitude);
            maxLng = MAX(maxLng, ithLongitude);
        }
        else {
            minLng = MIN(minLng, ithLongitude);
            maxLng = MAX(maxLng, ithLongitude);
        }

        totalLat += (ithLatitude + iplus1thLatitude);
        totalLng += (ithLongitude + iplus1thLongitude);
    }

    // If self.annotations has odd number elements we have unpaired last annotation coordinate values in coords[0]
    BOOL isOdd = count & 1;

    if (isOdd == 1) {
        CLLocationDegrees lastElementLatitude  = coords[0].latitude;
        CLLocationDegrees lastElementLongitude = coords[1].longitude;

        minLat = MIN(minLat, lastElementLatitude);
        minLng = MIN(minLng, lastElementLongitude);
        maxLat = MAX(maxLat, lastElementLatitude);
        maxLng = MAX(maxLng, lastElementLongitude);

        totalLat += lastElementLatitude;
        totalLng += lastElementLongitude;
    }

    self.coordinate = CLLocationCoordinate2DMake(totalLat / self.annotations.count,
                                                 totalLng / self.annotations.count);
    
    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                              longitude:minLng]
                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                   longitude:maxLng]] / 2.f;
}



@end
