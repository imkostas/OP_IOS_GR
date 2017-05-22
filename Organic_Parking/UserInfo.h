//
//  UserInfo.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Braintree/Braintree.h>
#import "MBProgressHUD.h"
#import "KeychainItemWrapper.h"
#import "KPAnnotation.h"
#import "CustomAlert.h"
#import "PaymentMethod.h"
#import "SubMerchant.h"
#import "Vehicle.h"
#import "SearchedLocation.h"
#import "Feedback.h"
#import "BraintreeUser.h"
#import "DateFilter.h"
#import "Definitions.h"

@protocol PushControlDelegate

//delegate method
- (void)handlePushNotification:(NSDictionary *)notification withType:(NSString *)type;

@end

@interface UserInfo : NSObject <UIAlertViewDelegate>

//delegate to handle incoming push notifications
@property (nonatomic, strong) id <PushControlDelegate> pushDelegate;

//app keys/IDs
@property (nonatomic, strong) NSString *appID;

//global back-end paths
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *img_uri;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *geocoding_uri;

//Keychain
@property (nonatomic, strong) KeychainItemWrapper *keychain;

//Log in variables
@property (nonatomic) BOOL showTutorial;

//user account info
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (nonatomic) float userSpeed;
@property (nonatomic, strong) NSString *device;
@property (nonatomic) unsigned int deviceType;
@property (nonatomic, strong) BraintreeUser *braintree;

//post details
@property (nonatomic) BOOL hasPost;
@property (nonatomic, strong) KPAnnotation *post;
@property (nonatomic, strong) NSString *postAddress;
@property (nonatomic, strong) NSString *postCityRegion;
@property (nonatomic) CLLocationCoordinate2D postCoordinate;
@property (nonatomic, strong) KPAnnotation *requesterInfo;

//request details
@property (nonatomic) BOOL hasRequest;
@property (nonatomic, strong) KPAnnotation *request;

//details on spot for feedback view
@property (nonatomic, strong) Feedback *feebackInfo;

//user car info
@property (nonatomic, strong) Vehicle *vehicle;

//Codes
@property (nonatomic) Codes code;

//user chat info
@property (nonatomic) BOOL chatCanSendMessage;
@property (nonatomic) unsigned int chatType;
@property (nonatomic) unsigned int chatID;
@property (nonatomic, strong) NSString *chatUsername;

//user images
@property (nonatomic, strong) NSCache *userImages;

//filter
@property (nonatomic, strong) DateFilter *filter;
@property (nonatomic) unsigned int postDetails;
@property (nonatomic) unsigned int filterCategories;

//boolean to update map pins
@property (nonatomic) BOOL shouldRefreshMapPins;
@property (nonatomic) BOOL shouldPauseRefreshMapPins;

//boolean to display deal response view
@property (nonatomic) BOOL dealResponseViewActive;

//boolean to center map after search
@property (nonatomic) BOOL shouldCenterMap;
@property (nonatomic) CLLocationCoordinate2D searchCoordinate;
@property (nonatomic, strong) NSMutableArray *searches;

@property (nonatomic) BOOL showTerms;

//class and instance methods
+ (UserInfo *)user;
+ (void)createHUD:(UIView *)view withOffset:(float)offset;
- (void)receivedNotification:(NSDictionary *)notification withType:(NSString *)type;

@end
