//
//  UserInfo.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

//synthesize user variables
@synthesize pushDelegate;

@synthesize appID;

@synthesize uri;
@synthesize img_uri;
@synthesize apiKey;
@synthesize geocoding_uri;

@synthesize keychain;

@synthesize showTutorial;

@synthesize username;
@synthesize email;
@synthesize profileImage;
@synthesize userLocation;
@synthesize userSpeed;
@synthesize device;
@synthesize deviceType;
@synthesize braintree;

@synthesize hasPost;
@synthesize post;
@synthesize postAddress;
@synthesize postCityRegion;
@synthesize postCoordinate;
@synthesize requesterInfo;

@synthesize hasRequest;
@synthesize request;

@synthesize feebackInfo;

@synthesize vehicle;

@synthesize code;

@synthesize chatCanSendMessage;
@synthesize chatType;
@synthesize chatID;
@synthesize chatUsername;

@synthesize userImages;

@synthesize filter;

@synthesize shouldRefreshMapPins;
@synthesize shouldPauseRefreshMapPins;

@synthesize dealResponseViewActive;

@synthesize showTerms;

@synthesize shouldCenterMap;
@synthesize searchCoordinate;
@synthesize searches;

//initializes user singleton
+ (UserInfo *)user {
    
    static UserInfo *user = nil;
    
    @synchronized(self){
        
        if(!user){
            
            user = [[UserInfo alloc] init];
            
        }
        
    }
    
    return user;
    
}

//created HUD view for any view to use
+ (void)createHUD:(UIView *)view withOffset:(float)offset {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setYOffset:offset];
    [hud setOpacity:0.0];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
    [customView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    
    UIImageView *loader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Loader"]];
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    rotateAnimation.duration = 0.5;
    rotateAnimation.autoreverses = NO;
    rotateAnimation.repeatCount = HUGE_VALF;
    
    [loader.layer addAnimation:rotateAnimation forKey:@"transform.rotation"];
    [customView addSubview:loader];
    hud.customView = customView;
    hud.labelText = nil;
    
}

//delegate will send remote push notification here for the push delegate to run on its active view controller
- (void)receivedNotification:(NSDictionary *)notification withType:(NSString *)type {
    
    //if delegate
    if(self.pushDelegate){
        
        //send notification to active view
        [self.pushDelegate handlePushNotification:notification withType:type];
        
    }
    
}

//initialize user
- (id)init {
    
    self = [super init];
    
    if(self){
        
        //Apple App ID
        appID = @"957856476";
        
        keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"OP_Keychain" accessGroup:nil];
        [keychain setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id)(kSecAttrAccessible)];
        
        showTutorial = false;
        showTerms = true;
        
        //Server request paths
        uri = @"https://api.organicparking.com/v1/Greece/";
        img_uri = @"https://api.organicparking.com/user_profile_images_gr/";
        apiKey = @"OPyINqtiXfEMP5qYVEJ0Cj.61XHplL0gb6eQB6TWp9JsLndxmdMDLW";
        geocoding_uri = @"https://maps.googleapis.com/maps/api/geocode/json?address=";
        
        //initialize user profile info
        username = @"0";  //FREE
        email = @"";
        profileImage = nil;
        userSpeed = 0.0f;
        device = @"";
        deviceType = 1;
        braintree = [[BraintreeUser alloc] init];
        
        userImages = [[NSCache alloc] init];
        
        //initialize posts array
        hasPost = NO;
        post = [[KPAnnotation alloc] init];
        postAddress = @"";
        postCityRegion = @"";
        postCoordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
        requesterInfo = [[KPAnnotation alloc] init];
        
        //initialize user request info
        hasRequest = NO;
        request = [[KPAnnotation alloc] init];
        
        feebackInfo = [[Feedback alloc] init];
        
        //initialize car info
        vehicle = [[Vehicle alloc] init];
        
        //initialize code
        code = NO_MESSAGE;
        
        //initialize filter
        filter = [[DateFilter alloc] init];
        
        //indicates if map should be refreshed
        shouldRefreshMapPins = false;
        shouldPauseRefreshMapPins = NO;
        
        //indicates deal response view is not active
        dealResponseViewActive = NO;
        
        //indicates if map should center on searched location - initialize search arrays
        shouldCenterMap = false;
        searches = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

@end
