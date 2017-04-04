//
//  SPGooglePlacesAutocompleteUtilities.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteUtilities.h"

@implementation NSArray(SPFoundationAdditions)
- (id)onlyObject {
    return [self count] == 1 ? [self objectAtIndex:0] : nil;
}
@end

SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary) {
    return [[placeDictionary objectForKey:@"types"] containsObject:@"establishment"] ? SPPlaceTypeEstablishment : SPPlaceTypeGeocode;
}

NSString *SPBooleanStringForBool(BOOL boolean) {
    return boolean ? @"true" : @"false";
}

NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type) {
    return (type == SPPlaceTypeGeocode) ? @"geocode" : @"establishment";
}

BOOL SPEnsureGoogleAPIKey() {
    
    BOOL userHasProvidedAPIKey = YES;
    if ([kGoogleAPIKey isEqualToString:@"YOUR_API_KEY"]) {
        
        userHasProvidedAPIKey = NO;
        NSLog(@"Google API Key Needed");
        
    }
    return userHasProvidedAPIKey;
    
}

void SPPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title) {
    
    NSLog(@"Error title: %@, Error message: %@", title, error);
    
}

extern BOOL SPIsEmptyString(NSString *string) {
    return !string || ![string length];
}
