//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () {
    
    BOOL updatedLocation;               //used in didUpdateToLocation as switch - might be a better way to do this
    BOOL menuActive;                    //indicates when menu is active
    BOOL dropPinActive;
    BOOL dropPinInPostState;
    BOOL locationAlertShowing;
    
    int currentView;
    int deviceType;
    
    float dropPpostShiftAmount;
    float maxLatitude;
    float minLatitude;
    float maxLongitude;
    float minLongitude;
    float topBarBottom;
    
}

@end

@implementation MainViewController

#define SEND_PAYMENT_TAG 9

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Main View Setup
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //set view and container/topBar structure
    [self.view setFrame:CGRectMake([[UIScreen mainScreen]bounds].origin.x, [[UIScreen mainScreen]bounds].origin.y,
                                   self.view.frame.size.width, self.view.frame.size.height)];
    [self.container setFrame:self.view.frame];
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarLogo setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, self.view.frame.origin.y, MAX_WIDTH, TOP_BAR_HEIGHT)];
    
    //main
    [self.main setFrame:CGRectMake(self.mainPosition.x, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height)];
    [self.searchBar setFrame:CGRectMake(self.view.frame.origin.x, TOP_BAR_HEIGHT,
                                        self.searchBar.frame.size.width, self.searchBar.frame.size.height)];
    [self.searchBarClear setFrame:self.searchBar.frame];
    
    [self.main.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.main.layer setShadowOpacity:0.4f];
    [self.main.layer setShadowPath:[UIBezierPath bezierPathWithRect:self.mapView.bounds].CGPath];
    
    topBarBottom = self.topBar.frame.origin.y + self.topBar.frame.size.height;
    [self.menuButton setFrame:CGRectMake(0, topBarBottom - self.menuButton.frame.size.height,
                                         self.menuButton.frame.size.width, self.menuButton.frame.size.height)];
    [self.chatroomBtn setFrame:CGRectMake(self.main.frame.size.width - self.chatroomBtn.frame.size.width, topBarBottom - self.chatroomBtn.frame.size.height, self.chatroomBtn.frame.size.width, self.chatroomBtn.frame.size.height)];
    
    [self.mapView setFrame:CGRectMake(self.view.frame.origin.x, self.main.frame.origin.y, self.main.frame.size.width, self.main.frame.size.height)];
    [self.locationButton setFrame:CGRectMake(self.view.frame.origin.x + 6, topBarBottom + 50, self.locationButton.frame.size.width, self.locationButton.frame.size.height)];
    [self.dealButton setFrame:CGRectMake(self.view.frame.size.width - self.dealButton.frame.size.width - 6, topBarBottom + 50, self.dealButton.frame.size.width, self.dealButton.frame.size.height)];
    
    [self.filtersBtn setFrame:CGRectMake(self.view.frame.size.width/2 - self.filtersBtn.frame.size.width/2, self.view.frame.size.height - self.filtersBtn.frame.size.height - 8, self.filtersBtn.frame.size.width, self.filtersBtn.frame.size.height)];
    
    //annotation views
    if(!currentView){
#ifdef DEBUG
        NSLog(@"Hiding info views");
#endif
        [self.spotInfo setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.spotInfo.frame.size.height)];
        [self.requestBackground setFrame:CGRectMake(0, self.requestBackground.frame.origin.y, self.view.frame.size.width, self.requestBackground.frame.size.height)];
        [self.requestBackgroundTip setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, self.requestBackgroundTip.frame.origin.y, MAX_WIDTH, self.requestBackgroundTip.frame.size.height)];
        [self.requestScroller setFrame:CGRectMake(0, PADDING, self.view.frame.size.width, self.requestScroller.frame.size.height)];
        [self.requestPageController setFrame:CGRectMake(0, self.requestPageController.frame.origin.y, self.view.frame.size.width, self.requestPageController.frame.size.height)];
        
        [self.myPostView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.myPostView.frame.size.height)];
        [self.mySpotBackground setFrame:CGRectMake(0, self.mySpotBackground.frame.origin.y, self.view.frame.size.width, self.mySpotBackground.frame.size.height)];
        [self.mySpotBackgroundTip setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, self.mySpotBackgroundTip.frame.origin.y, MAX_WIDTH, self.mySpotBackgroundTip.frame.size.height)];
        [self.mySpotScroller setFrame:CGRectMake(0, 20, self.view.frame.size.width, self.mySpotScroller.frame.size.height)];
        [self.mySpotDetailsContainer setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.mySpotDetailsContainer.frame.size.height)];
        [self.mySpotRequesterDetailsContainer setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.mySpotRequesterDetailsContainer.frame.size.height)];
        [self.mySpotPageControl setFrame:CGRectMake(0, self.mySpotPageControl.frame.origin.y, self.view.frame.size.width, self.mySpotPageControl.frame.size.height)];
        [self.mySpotBtn setFrame:CGRectMake(0, self.myPostView.frame.size.height - self.mySpotBtn.frame.size.height, self.view.frame.size.width, self.mySpotBtn.frame.size.height)];
    }
    
    //Drop pin view
    switch (deviceType) {
        case 3:
            dropPpostShiftAmount = -140.0f;
            break;
            
        case 2:
            dropPpostShiftAmount = -110.0f;
            break;
            
        case 1:
            dropPpostShiftAmount = -60.0f;
            break;
            
        case 0:
            dropPpostShiftAmount = -15.0f;
            break;
            
        default:
            NSLog(@"Unknow device type");
            break;
    }
    
    [self.dropPinImageView setFrame:CGRectMake(self.mapView.frame.size.width/2 - self.dropPinImageView.frame.size.width/2 + 8.5, self.mapView.frame.size.height/2 - self.dropPinImageView.frame.size.height/2 + dropPpostShiftAmount, self.dropPinImageView.frame.size.width, self.dropPinImageView.frame.size.height)];
    [self.confirmDropPostBtn setFrame:CGRectMake(self.mapView.frame.size.width/2 - 55, self.dropPinImageView.frame.origin.y + self.dropPinImageView.frame.size.height, 110, 60)];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view layoutIfNeeded];
    
    if(self.view.frame.size.height > 700){
        
        deviceType = 3;
        
    } else if(self.view.frame.size.height > 600) {
        
        deviceType = 2;
        
    } else if (self.view.frame.size.height > 500) {
        
        deviceType = 1;
        
    } else {
        
        deviceType = 0;
        
    }
    
    
    
    [self.user setCode:NO_MESSAGE];
    [self.user setShouldPauseRefreshMapPins:NO];
    
    [self.menu setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.filtersBtn setBackgroundImage:((self.user.filter.isActive)?[UIImage imageNamed:@"Filter Active"]:[UIImage imageNamed:@"Filter Inactive"]) forState:UIControlStateNormal];
    
    if(self.user.shouldRefreshMapPins){
        
        NSLog(@"Hiding current view on viewDidAppear");
        [self.user setShouldRefreshMapPins:NO];
        [self hideCurrentView];
        [self refreshMapPins];
        
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [UserInfo user];
    
    NSLog(@"%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    
    [self.dealButton setAlpha:0.0f];
    
    self.postSpotViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"postSpot"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToSearchedAddress) name:@"Search" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"logout" object:nil];
    
    self.fetchClientTokenThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchClientToken) object:nil];
    self.fetchPaymentMethodsThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchPaymentMethods) object:nil];
    self.fetchSubMerchantThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchSubMerchant) object:nil];
    [self.fetchClientTokenThread start];
    [self.fetchPaymentMethodsThread start];
    [self.fetchSubMerchantThread start];
    
    //Initializing main view position
    _mainPosition.x = self.main.frame.origin.x;
    
    //setting delegates
    self.user.pushDelegate = self;
    self.mapView.delegate = self;
    self.requestScroller.delegate = self;
    self.mySpotScroller.delegate = self;
    
    //initialize location manager to get user location
    if([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Started location services");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.distanceFilter = 0; //meters
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        if([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0f)[self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        
    } else {
        
        NSLog(@"Didn't start location services");
        
    }
    
    //initializing BOOL values
    menuActive = false;
    updatedLocation = false;
    locationAlertShowing = NO;
    
    //set no view displaying: 0 - no view displayed, 1 - Available/Requested View, 2 - My Post View
    currentView = 0;
    
    [self.requestPosterImage.layer setCornerRadius:40.0f];
    [self.requestPosterImage setClipsToBounds:YES];
    [self.mySpotRequesterImage.layer setCornerRadius:40.0f];
    [self.mySpotRequesterImage setClipsToBounds:YES];
    [self.requesterImage.layer setCornerRadius:30.0f];
    [self.requesterImage setClipsToBounds:YES];
    [self.posterImage.layer setCornerRadius:30.0f];
    [self.posterImage setClipsToBounds:YES];
    
    //add pan gesture recognizer to main view container
    self.panned = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [self.panned setCancelsTouchesInView:YES];
    [self.panned setDelegate:self];
    [self.container addGestureRecognizer:self.panned];
    
    dropPinActive = false;
    dropPinInPostState = false;
    
    self.dropPinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Drop Post"]];
    [self.mapView addSubview:self.dropPinImageView];
    [self.dropPinImageView setAlpha:0.0];
    
    self.confirmDropPostBtn = [[UIButton alloc] init];
    [self.confirmDropPostBtn setTitle:@"" forState:UIControlStateNormal];
    [self.confirmDropPostBtn setBackgroundColor:[UIColor clearColor]];
    [self.confirmDropPostBtn setBackgroundImage:[UIImage imageNamed:@"Post Here"] forState:UIControlStateNormal];
    [self.confirmDropPostBtn setAlpha:0.0];
    [self.confirmDropPostBtn setEnabled:NO];
    [self.confirmDropPostBtn addTarget:self action:@selector(confirmDropPost) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.confirmDropPostBtn];
    
    //setting content sizes of scrollviews
    self.mySpotScroller.contentSize = CGSizeMake(self.view.frame.size.width*2, 205);
    
    //    self.chatBadge = [CustomBadge customBadgeWithString:@""
    //                                        withStringColor:[UIColor whiteColor]
    //                                         withInsetColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]
    //                                         withBadgeFrame:YES
    //                                    withBadgeFrameColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]
    //                                              withScale:0.5
    //                                            withShining:NO];
    //    [self.chatroomBtn addSubview:self.chatBadge];
    
    //add callback method to refresh pins on app becoming active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMapPins) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //initializing tree controller
    self.treeController = [[KPTreeController alloc] initWithMapView:self.mapView];
    self.treeController.delegate = self;
    self.treeController.animationOptions = UIViewAnimationOptionCurveLinear;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //if(!updatedLocation)[self.mapView setShowsUserLocation:NO];
    
    self.viewController = nil;
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(refreshMapPins) userInfo:nil repeats:YES];
    
    //    if(self.user.shouldRefreshMapPins){
    //
    //        NSLog(@"Hiding current view on viewDidAppear");
    //        [self.user setShouldRefreshMapPins:NO];
    //        [self hideCurrentView];
    //        [self refreshMapPins];
    //
    //    }
    
    //center map on lacation specified by user
    if(self.user.shouldCenterMap){
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.user.searchCoordinate, METERS_PER_MILE, METERS_PER_MILE);
        [self.mapView setRegion:viewRegion animated:YES];
        
        self.user.shouldCenterMap = false;
    }
    
    if(!self.user.profileImage) {
        
        self.updateProfileImg = [[NSThread alloc] initWithTarget:self selector:@selector(updateProfileImage) object:nil];
        [self.updateProfileImg start];
        
    }
    
    if(self.user.showTutorial){
        
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        [self addChildViewController:viewController];
        [viewController.view setFrame:self.view.frame];
        [viewController.view setAlpha:0.0f];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.mapView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Searching Methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
- (IBAction)search:(id)sender {
    
    [self.panned setEnabled:NO];
    MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self addChildViewController:viewController];
    [viewController.view setFrame:self.view.frame];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
}

- (void)goToSearchedAddress {
    
    [self.panned setEnabled:YES];
    
    if(self.user.shouldCenterMap){
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.user.searchCoordinate, METERS_PER_MILE, METERS_PER_MILE);
        [self.mapView setRegion:viewRegion animated:YES];
        
        self.user.shouldCenterMap = false;
        
    }
    
}

- (IBAction)filters:(id)sender {
    
    MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"filters"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Global Methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//

//method to display custom HUD for all server requests
- (void)handlePushNotification:(NSDictionary *)notification withType:(NSString *)type {
    
    if([type isEqualToString:@"Local Notification"]){
        
        [self customAlert:@"Received local push notification" withDone:@"OK" withColor:NO withTag:0];
        
    } else if([type isEqualToString:@"missedMessage"]){
        
        [self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"OK" withColor:NO withTag:0];
        
    } else if([type isEqualToString:@"canceledDeal"]){
        
        [self hideCurrentView];
        [self refreshMapPins];
        
    } else if([type isEqualToString:@"autoDeletedPost"]){
        
        [self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"OK" withColor:NO withTag:0];
        
        [self hideCurrentView];
        NSLog(@"View should have been hidden");
        [self refreshMapPins];
        
    } else if([type isEqualToString:@"finalizedDeal"]){
        
        [self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"OK" withColor:NO withTag:0];
        
    } else if([type isEqualToString:@"postRequested"] || [type isEqualToString:@"respondedToRequest"]){
        
        [self refreshMapPins];
        
    }
    
}

//refresh map pins
- (void)refreshMapPins {
    
    if(!self.user.shouldPauseRefreshMapPins && [UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        
        //Creating a fake region
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = self.mapView.region.center.latitude;
        coordinate.longitude = self.mapView.region.center.longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
        
        //Setting boundaries based on simulated (possibly real) region
        maxLatitude = viewRegion.center.latitude + (viewRegion.span.latitudeDelta * 6);
        minLatitude = viewRegion.center.latitude - (viewRegion.span.latitudeDelta * 6);
        maxLongitude = viewRegion.center.longitude + (viewRegion.span.longitudeDelta * 6);
        minLongitude = viewRegion.center.longitude - (viewRegion.span.longitudeDelta * 6);
        
        //        NSLog(@"%f %f %f %f", minLatitude, maxLatitude, minLongitude, maxLongitude);
        //        NSLog(@"%f %f", self.mapView.region.span.latitudeDelta, self.mapView.region.span.longitudeDelta);
        //        NSLog(@"%f %f", viewRegion.span.latitudeDelta * 6, viewRegion.span.longitudeDelta * 6);
        
        //remove annotations from mapView that are outside the boundaries
        for(KPAnnotation *ano in self.mapView.annotations){
            if((ano.coordinate.longitude < minLongitude || ano.coordinate.longitude > maxLongitude ||
                ano.coordinate.latitude < minLatitude || ano.coordinate.latitude > maxLatitude) &&
               [ano isKindOfClass:[KPAnnotation class]]){
                [self.mapView removeAnnotation:ano];
            }
        }
        
        [self annotations];
        
        //        //with new region set, get appropriate spots
        //        if(self.mapView.region.span.latitudeDelta <= (viewRegion.span.latitudeDelta * 6) &&
        //           self.mapView.region.span.longitudeDelta <= (viewRegion.span.longitudeDelta * 6)){
        //
        //
        //            NSLog(@"Fetching spots");
        //
        //        }
        
    }
    
}

//dismisses any active info view
- (void)hideCurrentView {
    
    NSLog(@"Clearing currentView %i", currentView);
    switch (currentView) {
        case 1:
            [self animateSpotInfo:self.view.frame.size.height];
            break;
        case 2:
            [self animateMyPostView:self.view.frame.size.height];
            break;
        default:
            break;
    }
    
    [self.mapView deselectAnnotation:self.annotation animated:YES];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Thread Methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//fetches NSData and sets spot image then kills thread
- (void)fetchNSData:(NSString *)url {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *img = [UIImage imageWithData:data];
    
    if(!img){
        
        [self.requestPosterImage setImage:[UIImage imageNamed:@"Clear"]];
        
    } else {
        
        [self.user.userImages setObject:img forKey:self.annotation.p_username];
        
        [self.requestPosterImage setImage:img];
        self.posterImage.image = img;
        
    }
    
    [NSThread exit];
    
}

- (void)fetchRequesterImage:(NSString *)url {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *img = [UIImage imageWithData:data];
    
    if(!img){
        
        [self.mySpotRequesterImage setImage:[UIImage imageNamed:@"Clear"]];
        
    } else{
        
        [self.user.userImages setObject:img forKey:self.annotation.r_username];
        [self.mySpotRequesterImage setAlpha:0.0];
        [self.mySpotRequesterImage setImage:img];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            
            [self.mySpotRequesterImage setAlpha:1.0];
            
        }];
        
    }
    
    [NSThread exit];
    
}

- (void)fetchClientToken {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.apiKey, @"api_key", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchClientToken", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if([responseObject valueForKey:@"client_token"]){
                  
                  [self.user.braintree setClientToken:[responseObject valueForKey:@"client_token"]];
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
          }];
    
    [NSThread exit];
    
}

- (void)fetchPaymentMethods {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.user.braintree.customerID, @"customer_id", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchPaymentMethods", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if([[responseObject valueForKey:@"payment_methods"] isKindOfClass:[NSArray class]]){
                  
                  self.user.braintree.paymentMethods = [self.user.braintree parsePaymentMethods:[responseObject valueForKey:@"payment_methods"]];
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
          }];
    
    [NSThread exit];
    
}

- (void)fetchSubMerchant {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.user.braintree.subMerchant.ID, @"sub_merchant_id", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@fetchSubMerchant", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              self.user.braintree.subMerchant.status = [responseObject valueForKey:@"status"];
              NSLog(@"!!!!! status = %@", self.user.braintree.subMerchant.status);
              
              if (self.user.braintree.subMerchant.status == nil || [self.user.braintree.subMerchant.status isEqual:[NSNull null]])return;
              
              if([self.user.braintree.subMerchant.status isEqualToString:@"active"]){
                  
                  self.user.braintree.subMerchant.firstName = [responseObject valueForKey:@"first_name"];
                  self.user.braintree.subMerchant.lastName = [responseObject valueForKey:@"last_name"];
                  self.user.braintree.subMerchant.dateOfBirth = [responseObject valueForKey:@"date_of_birth"];
                  self.user.braintree.subMerchant.address = [responseObject valueForKey:@"street_address"];
                  self.user.braintree.subMerchant.city = [responseObject valueForKey:@"locality"];
                  self.user.braintree.subMerchant.state = [responseObject valueForKey:@"region"];
                  self.user.braintree.subMerchant.zip = [responseObject valueForKey:@"postal_code"];
                  
                  self.user.braintree.subMerchant.destination = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"destination"];
                  if([self.user.braintree.subMerchant.destination isEqualToString:@"email"]){
                      
                      self.user.braintree.subMerchant.venmoEmail = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"email"];
                      
                  } else if([self.user.braintree.subMerchant.destination isEqualToString:@"mobile_phone"]) {
                      
                      self.user.braintree.subMerchant.venmoPhone = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"mobile_phone"];
                      
                  } else {
                      
                      self.user.braintree.subMerchant.accountNumber = [[responseObject valueForKey:@"funding_source"] valueForKeyPath:@"account_last_four"];
                      
                  }
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              //shouldn't ever get here unless network failure
              NSLog(@"%@", operation.responseObject);
              
          }];
    
    [NSThread exit];
    
}

//Reverse geolocate given GPS location
//- (void)geoLocate:(CLLocation *)loc {
//
//    NSLog(@"%f, %f", loc.coordinate.latitude, loc.coordinate.longitude);
//
//    if(!self.geoCoder)self.geoCoder = [[CLGeocoder alloc] init];
//
//    [self.geoCoder reverseGeocodeLocation:loc completionHandler:
//     ^(NSArray *placemarks, NSError *error) {
//         if (error) {
//             NSLog(@"Geocode failed with error: %@", error);
//             return ;
//         } else if(placemarks && placemarks.count > 0) {
//             CLPlacemark *placemark = placemarks[0];
//             self.user.postAddress = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
//             self.user.postCityRegion = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
//         } else {
//             NSLog(@"Not sure what just happened - geoLocate");
//         }
//     }];
//
//    [NSThread exit];
//
//}

- (void)updateProfileImage {
    
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", self.user.img_uri, self.user.username]]]];
    
    if(img){
        
        self.user.profileImage = img;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProfileImage" object:nil];
        
    }
    
    [NSThread exit];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Sending and Canceling Request or Removing Post or Canceling Deals
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//considers which stage the deal is in and performs proper method
- (IBAction)decideToRequestOrCancel:(id)sender {
    
    if([self.requestPostButton.titleLabel.text isEqualToString:@"REQUEST NOW"]){
        
        [self requestSpot];
        
    } else if ([self.requestPostButton.titleLabel.text isEqualToString:@"CANCEL REQUEST"]) {
        
        [self confirmCancelRequest];
        
    } else if([self.requestPostButton.titleLabel.text isEqualToString:@"PAY NOW"]){
        
        [self sendPayment];
        
    } else if([self.requestPostButton.titleLabel.text isEqualToString:@"LEAVE FEEDBACK"]){
        
        self.user.feebackInfo = [[Feedback alloc] initWithRatee:self.annotation.p_username swapTime:self.annotation.swap_time status:4 postID:self.annotation.post_id];
        [self rateDeal];
        
    } else {
        
        NSLog(@"This shouldn't happen - decideToRequestOrCancel");
        
    }
    
}

- (IBAction)cancelDealRequester:(id)sender {
    
    //cancel deal
    [self cancelDeal:REQUESTER_CANCELED];
    
}

- (void)sendPayment {
    
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:[NSString stringWithFormat:@"Your card will be charged $%.2f. Do you confirm this transaction?", self.annotation.price]];
    [self.customAlert.leftButton setBackgroundColor:OP_LIGHT_GRAY_COLOR];
    [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
    [self.customAlert.rightButton setBackgroundColor: OP_BLUE_COLOR];
    [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:SEND_PAYMENT_TAG];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (void)confirmedSendPayment {
    
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i", self.annotation.post_id], @"post_id",
                            self.user.apiKey, @"api_key", nil];

    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@sendPayment", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              

             NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //alert user of their post status
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                  
              }
              
              [self.requestPostButton setFrame:CGRectMake(self.spotInfo.frame.origin.x, self.requestPostButton.frame.origin.y,
                                                          self.spotInfo.frame.size.width, self.requestPostButton.frame.size.height)];
              [self.requestPostButton setTitle:@"LEAVE FEEDBACK" forState:UIControlStateNormal];
              [self refreshMapPins];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                  
              } else {
                  
                  [self customAlert:@"Unable to send payment" withDone:@"OK" withColor:NO withTag:0];
                  
              }
              
          }];
    
}


//check to see if user can request spot - if they can, begin request process, otherwise, notify them of the actions they need to take to request
- (BOOL) canRequest {
    BOOL canRequest = true;
    
    if([[[UserInfo user] username] isEqualToString: @"0"]){  //FREE
        //no account? stay or logout/create a new account
        [self noAccount];
        canRequest = false;
        return canRequest;
    }
    
    //FREE POST (NO PAYMENT METHOD REQUIRED) IF PRICE IS 0
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
        !self.user.hasRequest &&
       //&&&&&&&&& self.user.vehicle.hasVehicle &&
        self.annotation.price == 0.){
        canRequest = true;
        //NSLog(@"end can request = %d %f", canRequest , self.annotation.price);
        return canRequest;
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self showLocationAlert];
        canRequest = false;
        
    } else if(self.user.hasRequest) {
        
        if(self.annotation.post_id != self.user.request.post_id){
            [self customAlert:@"Currently, you're only allowed to request one spot at a time" withDone:@"OK" withColor:NO withTag:0];
        } else {
            [self.requestPostButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
            [self customAlert:@"You've already requested this spot" withDone:@"OK" withColor:NO withTag:0];
        }
        canRequest = false;
        
    }
    
    /*  &&&&&&&&&&&&&&&
     
     else if(!self.user.vehicle.hasVehicle) {
        
        self.user.code = MISSING_VEHICLE;
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
        [self presentViewController:viewController animated:YES completion:^{}];
        canRequest = false;
        
    } else if(!self.user.braintree.paymentMethods.count) {

        self.user.code = MISSING_PAYMENT_METHOD;
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
        [self presentViewController:viewController animated:YES completion:^{}];
        canRequest = false;
            
    } else if([self checkForExpiredCards]) {
            
        self.user.code = EXPIRED_PAYMENT_METHOD;
        MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
        [self presentViewController:viewController animated:YES completion:^{}];
        canRequest = false;
     }
    &&&&&&&&&&&&&&&&& */
    
    return canRequest;
}

- (void)requestSpot {
    
    
    if(self.canRequest == false)return;
    
    if(self.canRequest){
        
        [UserInfo createHUD:self.view withOffset:0.0f];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", self.annotation.post_id], @"post_id",
                                self.user.username, @"username", self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@requestSpot", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSLog(@"%@", responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  //alert user request was successful
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                      
                  }
                  
                  [self.requestPostButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
                  [self refreshMapPins];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  NSLog(@"%@", operation.responseObject);
                  
                  //hide HUD
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                      
                      [self hideCurrentView];
                      [self refreshMapPins];
                      
                  } else {
                      
                      [self customAlert:@"We were unable to request this spot for you" withDone:@"OK" withColor:NO withTag:0];
                      
                  }
                  
              }];
        
    }
    
}

- (BOOL)checkForExpiredCards {
    
    PaymentMethod *payment = (PaymentMethod *)[self.user.braintree.paymentMethods objectAtIndex:0];
    return (payment.isExpired) ? YES : NO;
    
}

//if request is pending - if user wants to cancel, this method runs
- (void)confirmCancelRequest {
    
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:@"Are you sure you want to cancel your request?"];
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:3];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//if cancel request, proceed with cancelling request
- (void)cancelRequest {
    
    [self hideCurrentView];
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i", self.annotation.post_id], @"post_id",
                            self.user.username, @"username", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@cancelRequest", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //alert user their request has been canceled
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                  
              }
              
              self.user.hasRequest = NO;
              self.user.request = [[KPAnnotation alloc] init];
              [self refreshMapPins];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                  
              } else {
                  
                  [self customAlert:@"We were unable to cancel this request for you" withDone:@"OK" withColor:NO withTag:0];
                  
              }
              
              [self hideCurrentView];
              [self refreshMapPins];
              
          }];
    
}

- (IBAction)mySpotPageControllerValueChanged:(id)sender {
    
    CGRect frame = CGRectMake((self.mySpotScroller.contentSize.width/self.mySpotPageControl.numberOfPages)*self.mySpotPageControl.currentPage, 0, self.mySpotScroller.frame.size.width, self.mySpotScroller.frame.size.height);
    [self.mySpotScroller scrollRectToVisible:frame animated:YES];
    
}

//decides which stage posted spot is in and performs proper method
- (IBAction)decideToRemoveOrCancel:(id)sender {
    
    if([self.mySpotBtn.titleLabel.text isEqualToString:@"REMOVE POST"]){
        
        [self removePost];
        
    } else if ([self.mySpotBtn.titleLabel.text isEqualToString:@"CANCEL DEAL"]) {
        
        [self cancelDeal:POSTER_CANCELED];
        
    } else if ([self.mySpotBtn.titleLabel.text isEqualToString:@"LEAVE FEEDBACK"]) {
        
        self.user.feebackInfo = [[Feedback alloc] initWithRatee:self.annotation.r_username swapTime:self.annotation.swap_time status:3 postID:self.annotation.post_id];
        [self rateDeal];
        
    } else {
        
        NSLog(@"This shouldn't happen - decideToRemoveOrCancel");
        
    }
    
}

//if poster wants to delete their current post, display a confirm popup
- (void)removePost {
    
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:@"Are you sure you want to remove your post?"];
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:1];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//if post deletion is confirmed, proceed with deleting post
- (void) confirmRemovePost {
    
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", self.annotation.post_id],
                            @"id", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@deletePost", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              //alert user their post has been deleted
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:YES withTag:0];
                  
              }
              
              self.user.hasPost = NO;
              self.user.post = [[KPAnnotation alloc] init];
              [self hideCurrentView];
              [self refreshMapPins];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:YES withTag:0];
                  
              } else {
                  
                  [self customAlert:@"We were unable to delete your post" withDone:@"OK" withColor:YES withTag:0];
                  
              }
              
          }];
    
}

//if user is in requested deal and wants to cancel
- (void)cancelDeal:(int)status {
    
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:@"Are you sure you want to cancel?"];
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"No" forState:UIControlStateNormal];
    [self.customAlert.rightButton setBackgroundColor: (currentView == 2) ? [UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0] : [UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:status];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//if user confirms the deal cancelation, proceed with cancelling deal
- (void)cancelDealConfirmed:(int)status {
    
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%i", self.annotation.post_id], @"post_id",
                            [NSString stringWithFormat:@"%i", status], @"status", self.user.username,
                            @"username", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@cancelSwap", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  NSLog(@"Current View: %i", currentView);
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]
                          withColor:((currentView == 1) ? NO : YES) withTag:0];
                  
              }
              
              [self hideCurrentView];
              [self refreshMapPins];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
              //hide HUD
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              
              [self refreshMapPins];
              
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]
                          withColor:((currentView == 1) ? NO : YES) withTag:0];
                  
              } else {
                  
                  [self customAlert:@"Unable to cancel deal" withDone:@"OK"
                          withColor:((currentView == 1) ? NO : YES) withTag:0];
                  
              }
              
          }];
    
}

- (void)rateDeal {
    
    MainViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"ratedeal"];
    [self.navigationController presentViewController:view animated:YES completion:nil];
    
}

- (IBAction)getDirections:(id)sender {
    
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: self.annotation.coordinate addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = [NSString stringWithFormat:@"%@ %@", self.annotation.address, self.annotation.city_region];
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
    
}


//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Log out
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//

- (void)logOut{
    
    [self.user.keychain setObject:@"" forKey:(__bridge id)(kSecValueData)];
    
    //these values need to be nil
    self.user.username = @"";
    self.user.profileImage = nil;
    self.user.vehicle = [[Vehicle alloc] init];
    self.user.braintree = [[BraintreeUser alloc] init];
    self.user.filter = [[DateFilter alloc] init];
    [self.user.searches removeAllObjects];
    
    self.user.hasPost = NO;
    self.user.post = [[KPAnnotation alloc] init];
    self.user.hasRequest = NO;
    self.user.request = [[KPAnnotation alloc] init];
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//MapView Methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Collects all spots to display that fall within the lat/long range and time constraints
- (void)annotations {
    
    //Creating a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *startSearch, *endSearch;
    
    if(self.user.filter.isActive){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *temp = [NSString stringWithFormat:@"%@:59", [dateFormatter stringFromDate:self.user.filter.date]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.user.filter.date = [dateFormatter dateFromString: temp];
        startSearch = [self.user.filter.date dateByAddingTimeInterval:(self.user.filter.window + 1) * -60];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        temp = [NSString stringWithFormat:@"%@:00", [dateFormatter stringFromDate:self.user.filter.date]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.user.filter.date = [dateFormatter dateFromString: temp];
        endSearch = [self.user.filter.date dateByAddingTimeInterval:(self.user.filter.window + 1) * 60];
        
    } else {
        
        //get spots posted now to a year from now
        startSearch = [NSDate date];
        endSearch = [[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24 * 365)];
        
    }
    
    if(startSearch != [startSearch laterDate:[NSDate date]]){
        
        startSearch = [NSDate date];
        
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: startSearch, @"stime", endSearch, @"etime", [NSString stringWithFormat:@"%i", self.user.postDetails], @"details", [NSString stringWithFormat:@"%f", minLatitude], @"minlat", [NSString stringWithFormat:@"%f", maxLatitude], @"maxlat", [NSString stringWithFormat:@"%f", minLongitude], @"minlon", [NSString stringWithFormat:@"%f", maxLongitude], @"maxlon", self.user.username, @"username", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@getSpots", self.user.uri] parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //array for all spots
             NSMutableArray *pins = [[NSMutableArray alloc] init];
             
             //array for available spots
             NSArray *spots = [responseObject valueForKeyPath:@"spots"];
             for(NSDictionary *item in spots) {
                 
                 KPAnnotation *pin = [[KPAnnotation alloc] init];
                 
                 pin.type = 0;
                 pin.post_id = [[item objectForKey: @"post_id"] unsignedIntValue];
                 pin.p_username = [item objectForKey: @"p_username"];
                 pin.coordinate = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue],
                                                             [[item objectForKey:@"longitude"] floatValue]);
                 
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                 pin.swap_time = [dateFormatter dateFromString:[item objectForKey: @"swap_time"]];
                 [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                 [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
                 pin.date = [dateFormatter stringFromDate:pin.swap_time];
                 [dateFormatter setDateFormat:@"h:mm"];
                 pin.time = [dateFormatter stringFromDate:pin.swap_time];
                 [dateFormatter setDateFormat:@"a"];
                 pin.AMPM = [dateFormatter stringFromDate:pin.swap_time];
                 
                 pin.price = [[item objectForKey:@"post_price"] floatValue];
                 pin.paid = [[item objectForKey:@"paid"] unsignedIntValue];
                 pin.details = [[item objectForKey:@"details"] intValue];
                 pin.total_stars = [[item objectForKey:@"total_stars"] intValue];
                 pin.total_deals = [[item objectForKey:@"total_deals"] intValue];
                 //&&&&&&&&
                 pin.car_make = @""; //[item objectForKey: @"car_make"];
                 pin.car_model = @""; //[item objectForKey: @"car_model"];
                 pin.car_color = @""; //[item objectForKey: @"car_color"];
                 pin.car_size = 0; //[[item objectForKey:@"car_size"] intValue];
                 //&&&&&&&&
                 pin.profile_image = [NSString stringWithFormat:@"%@%@.png", self.user.img_uri, pin.p_username];
                 
                 [pins addObject:pin];
                 
             }
             
             //add posts
             self.user.hasPost = NO;
             NSArray *posts = [responseObject valueForKeyPath:@"posts"];
             for(NSDictionary *item in posts) {
                 
                 if([[item objectForKey: @"status"] unsignedIntValue] < STATUS_LIMIT ||
                    [[item objectForKey: @"status"] unsignedIntValue] == POST_NEEDS_RATING ||
                    [[item objectForKey: @"status"] unsignedIntValue] == REQUESTER_CANCELED){
                     
                     self.user.hasPost = YES;
                     self.user.post.type = 1;
                     self.user.post.post_id = [[item objectForKey: @"post_id"] unsignedIntValue];
                     self.user.post.p_username = [item objectForKey: @"p_username"];
                     self.user.post.r_username = [item objectForKey: @"r_username"];
                     self.user.post.status = [[item objectForKey: @"status"] unsignedIntValue];
                     self.user.post.address = [item objectForKey: @"address"];
                     self.user.post.city_region = [item objectForKey: @"city_region"];
                     self.user.post.coordinate = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue],
                                                                            [[item objectForKey:@"longitude"] floatValue]);
                     
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                     [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                     self.user.post.swap_time = [dateFormatter dateFromString:[item objectForKey: @"swap_time"]];
                     [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                     [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
                     self.user.post.date = [dateFormatter stringFromDate:self.user.post.swap_time];
                     [dateFormatter setDateFormat:@"h:mm"];
                     self.user.post.time = [dateFormatter stringFromDate:self.user.post.swap_time];
                     [dateFormatter setDateFormat:@"a"];
                     self.user.post.AMPM = [dateFormatter stringFromDate:self.user.post.swap_time];
                     
                     self.user.post.price = [[item objectForKey:@"post_price"] floatValue];
                     self.user.post.paid = [[item objectForKey:@"paid"] unsignedIntValue];
                     self.user.post.details = [[item objectForKey:@"details"] intValue];
                     self.user.post.total_stars = [[item objectForKey:@"total_stars"] intValue];
                     self.user.post.total_deals = [[item objectForKey:@"total_deals"] intValue];
                     self.user.post.car_make = [item objectForKey: @"car_make"];
                     self.user.post.car_model = [item objectForKey: @"car_model"];
                     self.user.post.car_color = [item objectForKey: @"car_color"];
                     self.user.post.car_size = [[item objectForKey:@"car_size"] intValue];
                     self.user.post.profile_image = [NSString stringWithFormat:@"%@%@.png", self.user.img_uri, self.user.post.r_username];
                     
                     if(self.user.post && self.user.post.status != REQUESTER_CANCELED)[pins addObject:self.user.post];
                     
                     if(self.user.post.status == REQUESTER_CANCELED){
                         
                         [self.user setCode:RATE_NOW];
                         self.user.feebackInfo = [[Feedback alloc] initWithRatee:self.user.post.r_username swapTime:self.user.post.swap_time status:self.user.post.status postID:self.user.post.post_id];
                         [self.user setShouldPauseRefreshMapPins:YES];
                         if(self.annotation.post_id == self.user.post.post_id)[self hideCurrentView];
                         self.user.hasPost = NO;
                         [self rateDeal];
                         
                     } else if(self.user.post.paid == 1) {
                         
                         [self updatePostPaidStatus:self.user.post.post_id withRequester:self.user.post.r_username];
                         if(currentView == 2){
                             
                             self.annotation = self.user.post;
                             [self setupPostView:self.annotation];
                             
                         }
                         
                     } else if(self.user.post.status == 1) {
                         
                         if(currentView == 2){
                             
                             self.annotation = self.user.post;
                             [self setupPostView:self.annotation];
                             
                         }
                         
                     }
                     
                 }
                 
             }
             
             //add requests
             self.user.hasRequest = NO;
             NSArray *requests = [responseObject valueForKeyPath:@"requests"];
             for(NSDictionary *item in requests) {
                 
                 if([[item objectForKey: @"status"] unsignedIntValue] < STATUS_LIMIT ||
                    [[item objectForKey: @"status"] unsignedIntValue] == REQUEST_NEEDS_RATING ||
                    [[item objectForKey: @"status"] unsignedIntValue] == POSTER_CANCELED){
                     
                     self.user.hasRequest = YES;
                     self.user.request.type = 2;
                     self.user.request.post_id = [[item objectForKey: @"post_id"] unsignedIntValue];
                     self.user.request.p_username = [item objectForKey: @"p_username"];
                     self.user.request.r_username = [item objectForKey: @"r_username"];
                     self.user.request.status = [[item objectForKey: @"status"] unsignedIntValue];
                     self.user.request.address = [item objectForKey: @"address"];
                     self.user.request.city_region = [item objectForKey: @"city_region"];
                     self.user.request.coordinate = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue],
                                                                               [[item objectForKey:@"longitude"] floatValue]);
                     
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                     [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                     self.user.request.swap_time = [dateFormatter dateFromString:[item objectForKey: @"swap_time"]];
                     [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                     [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
                     self.user.request.date = [dateFormatter stringFromDate:self.user.request.swap_time];
                     [dateFormatter setDateFormat:@"h:mm"];
                     self.user.request.time = [dateFormatter stringFromDate:self.user.request.swap_time];
                     [dateFormatter setDateFormat:@"a"];
                     self.user.request.AMPM = [dateFormatter stringFromDate:self.user.request.swap_time];
                     
                     self.user.request.price = [[item objectForKey:@"post_price"] floatValue];
                     self.user.request.paid = [[item objectForKey:@"paid"] unsignedIntValue];
                     self.user.request.details = [[item objectForKey:@"details"] intValue];
                     self.user.request.total_stars = [[item objectForKey:@"total_stars"] intValue];
                     self.user.request.total_deals = [[item objectForKey:@"total_deals"] intValue];
                     self.user.request.car_make = [item objectForKey: @"car_make"];
                     self.user.request.car_model = [item objectForKey: @"car_model"];
                     self.user.request.car_color = [item objectForKey: @"car_color"];
                     self.user.request.car_size = [[item objectForKey:@"car_size"] intValue];
                     self.user.request.profile_image = [NSString stringWithFormat:@"%@%@.png", self.user.img_uri, self.user.request.p_username];
                     
                     if(self.user.request && self.user.request.status != POSTER_CANCELED)[pins addObject:self.user.request];
                     
                     if(self.user.request.status == REQUEST_ACCEPTED){
                         
                         [self updatePostStatus:self.user.request.post_id status:ACKNOWLEDGED_ACCEPTANCE];
                         
                     } else if(self.user.request.status == POSTER_CANCELED){
                         
                         [self.user setCode:RATE_NOW];
                         self.user.feebackInfo = [[Feedback alloc] initWithRatee:self.user.request.p_username swapTime:self.user.request.swap_time status:self.user.request.status postID:self.user.request.post_id];
                         [self.user setShouldPauseRefreshMapPins:YES];
                         if(self.annotation.post_id == self.user.request.post_id)[self hideCurrentView];
                         self.user.hasRequest = NO;
                         [self rateDeal];
                         
                     }
                     
                 } else if([[item objectForKey: @"status"] unsignedIntValue] == REQUEST_DENIED) {
                     
                     [self updatePostStatus:[[item objectForKey: @"post_id"] unsignedIntValue] status:ACKNOWLEDGED_DENIAL];
                     
                 }
                 
             }
             
             //add annotations to map
             [self.treeController setAnnotations:pins];
             
             //if no post, clear post and show user location
             if(!self.user.hasPost && !dropPinActive){
                 
                 self.user.post = [[KPAnnotation alloc] init];
                 //[self.mapView setShowsUserLocation:YES];
                 
             } else if(self.user.hasPost && ![self.user.post.r_username isEqualToString:@""] &&
                       self.user.post.status == 0 && !self.user.dealResponseViewActive){
                 
                 [self hideCurrentView];
                 self.user.dealResponseViewActive = YES;
                 self.user.requesterInfo = self.user.post;
                 self.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"deal_response"];
                 [self addChildViewController:self.viewController];
                 [self.viewController.view setFrame:self.view.frame];
                 [self.view addSubview:self.viewController.view];
                 [self.viewController didMoveToParentViewController:self];
                 
             }
             
             //if no request, clear request
             if(!self.user.hasRequest)self.user.request = [[KPAnnotation alloc] init];
             
             if(!self.user.hasPost && currentView == 2)[self hideCurrentView];
             
             //show or hide deal button
             [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.dealButton setAlpha:((self.user.hasPost && self.user.post.status < STATUS_LIMIT) || (self.user.hasRequest && self.user.request.status < STATUS_LIMIT)) ? 1.0f : 0.0f];}];
             
             //[self.mapView setShowsUserLocation:(self.user.hasPost) ? NO : YES];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Response: %@", [operation.responseObject objectForKey:@"response"]);
             
         }];
}

- (void)updatePostPaidStatus:(int)post_id withRequester:(NSString *)requester {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", post_id], @"post_id",
                            requester, @"r_username", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@updatePostPaidStatus", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              //alert user of their post status
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:33];
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
          }];
    
}

- (void)updatePostStatus:(int)post_id status:(int)status {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", post_id], @"post_id",
                            [NSString stringWithFormat:@"%i", status], @"status", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@updatePostStatus", self.user.uri] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSLog(@"%@", responseObject);
              
              if(status && post_id == self.annotation.post_id){
                  
                  NSLog(@"Updating request view after updating post status");
                  self.annotation = self.user.request;
                  self.annotation.status = status;
                  [self setupRequestView:self.annotation withCentering:NO];
                  
              } else if (!status && post_id == self.annotation.post_id) {
                  
                  NSLog(@"Hiding current view with status %i after updating post status", status);
                  [self hideCurrentView];
                  
              }
              
              //alert user of their post status
              if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                 [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                  
                  [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                           withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:NO withTag:0];
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"%@", operation.responseObject);
              
          }];
    
}

//creates custom annotation views of types of pins
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKPinAnnotationView *v = nil;
    
    //if user's location just return
    if([annotation isKindOfClass:[MKUserLocation class]]){
        
        return nil;
        
    }
    
    //if pin in treeController
    if([annotation isKindOfClass:[KPAnnotation class]]){
        KPAnnotation *a = (KPAnnotation *)annotation;
        
        //if cluster create cluster view for annotation
        if([a isCluster]){
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
            
            if(!v){
                v = [[MKPinAnnotationView alloc] initWithAnnotation:a reuseIdentifier:@"cluster"];
            }
            
            //if not set before add necessary subviews, othewise, update subviews
            if(v.subviews.count == 0){
                NSString *count = [NSString stringWithFormat:@"%i", (int)a.annotations.count];
                CGSize size = [[[NSAttributedString alloc] initWithString:count attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:30]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                //set annotation frame
                v.frame = CGRectMake(v.frame.origin.x - size.width/2, v.frame.origin.y - size.height/2, 55, 55);
                
                //set label view
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 16, 26, 26)];
                label.frame = CGRectMake(v.bounds.origin.x + (v.bounds.size.width/2) - (size.width/2), label.frame.origin.y, size.width, label.frame.size.height);
                [label setTag:90];
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:30];
                label.text = count;
                
                //set cluster group view - currently doesn't stretch to fit label - so might look funny for clusters 100 and over
                UIImageView *clusterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cluster"]];
                clusterImageView.frame = CGRectMake(v.bounds.origin.x,
                                                    v.bounds.origin.y, 55, 55);
                [clusterImageView setTag:80];
                
                //add each view to annotation
                [v addSubview:clusterImageView];
                [v addSubview:label];
            }
            //update existing subviews with information
            else {
                for (UIView *subview in v.subviews) {
                    NSString *count = [NSString stringWithFormat:@"%i", (int)a.annotations.count];
                    CGSize size = [[[NSAttributedString alloc] initWithString:count attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:30]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    
                    //set annotation frame
                    v.frame = CGRectMake(v.frame.origin.x - size.width/2, v.frame.origin.y - size.height/2, 55, 55);
                    
                    if(subview.tag == 80){
                        UIImageView *clusterImageView = (UIImageView*)subview;
                        clusterImageView.frame = CGRectMake(v.bounds.origin.x,
                                                            v.bounds.origin.y, 55, 55);
                        clusterImageView.image = [UIImage imageNamed:@"Cluster"];
                    }
                    if (subview.tag == 90) {
                        UILabel *label = (UILabel*)subview;
                        label.frame = CGRectMake(v.bounds.origin.x + (v.bounds.size.width/2) - (size.width/2), label.frame.origin.y, size.width, label.frame.size.height);
                        label.text = count;
                    }
                }
            }
        } else {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
            if(!v){
                v = [[MKPinAnnotationView alloc] initWithAnnotation:[a.annotations anyObject] reuseIdentifier:@"pin"];
            }
            
            NSString *price = (a.type == 2) ? @"" : [NSString stringWithFormat:@"%i", (int)a.price];
            
            CGSize size = [[[NSAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:25]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            int width = (size.width < 25) ? 34 : size.width + 20;
            int shadowWidth = (size.width < 25) ? 33 : size.width + 24;
            
            //set annotaion frame
            v.frame = CGRectMake(v.frame.origin.x - 8 - size.width/2, v.frame.origin.y - 22, width, 50);
            
            //add correct subviews if none exists
            if(v.subviews.count == 0){
                //set activity image view
                UIImageView *activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Clear"]];
                activityImageView.animationImages = [NSArray arrayWithObjects:
                                                     [UIImage imageNamed:@"Pending 1"],
                                                     [UIImage imageNamed:@"Pending 2"],
                                                     [UIImage imageNamed:@"Pending 3"],
                                                     nil];
                activityImageView.animationDuration = 1.2f;
                activityImageView.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 25, v.bounds.origin.y - 4, 34, 34);
                [activityImageView setTag:40];
                
                //set pin circle shadow image view
                UIImageView *pinShadow = [[UIImageView alloc]init];
                pinShadow.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - shadowWidth/2 + 4,
                                             v.bounds.origin.y + 3, shadowWidth, 33);
                pinShadow.image = [[UIImage imageNamed:@"Pin Shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f) resizingMode:UIImageResizingModeStretch];
                [pinShadow setTag:50];
                
                //set pin stem shadow image view
                UIImageView *pinStemShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pin Stem Shadow"]];
                pinStemShadow.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 8, v.bounds.origin.y + 32, 9, 9);
                [pinStemShadow setTag:60];
                
                //set pin stem image view
                UIImageView *pinStem = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pin Stem"]];
                pinStem.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 9.5,
                                           v.bounds.origin.y + 18, 4, 24);
                [pinStem setTag:70];
                
                //set pin circle image view
                UIImageView *pinCircle = [[UIImageView alloc] initWithFrame:CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - width/2 - 7, v.bounds.origin.y - 5, width, 34)];
                [pinCircle setTag:80];
                
                //set label view
                UILabel *label = [[UILabel alloc] init];
                label.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - size.width/2 - 4, v.bounds.origin.y - 4, size.width, size.height);
                label.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:25];
                label.text = price;
                [label setTag:90];
                
                if(a.type == 1){
                    pinCircle.image = [[UIImage imageNamed:@"Pink Dollar Pin"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0f, 17.0f, 17.0f, 17.0f) resizingMode:UIImageResizingModeStretch];
                } else if(a.type == 2) {
                    if(a.status > 0){
                        pinCircle.image = [UIImage imageNamed:@"Bought Pin"];
                        [activityImageView stopAnimating];
                    } else {
                        pinCircle.image = [UIImage imageNamed:@"Pending Pin"];
                        [activityImageView startAnimating];
                    }
                } else {
                    pinCircle.image = [[UIImage imageNamed:@"Blue Dollar Pin"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0f, 17.0f, 17.0f, 17.0f) resizingMode:UIImageResizingModeStretch];
                }
                
                //add each view to annotation
                [v addSubview:pinShadow];
                [v addSubview:pinStemShadow];
                [v addSubview:pinStem];
                [v addSubview:pinCircle];
                [v addSubview:label];
                [v addSubview:activityImageView];
            } else {
                for (UIView *subview in v.subviews) {
                    if(subview.tag == 40){
                        UIImageView *activityImageView = (UIImageView*)subview;
                        if(a.type == 2){
                            activityImageView.animationImages = [NSArray arrayWithObjects:
                                                                 [UIImage imageNamed:@"Pending 1"],
                                                                 [UIImage imageNamed:@"Pending 2"],
                                                                 [UIImage imageNamed:@"Pending 3"],
                                                                 nil];
                            activityImageView.animationDuration = 1.2f;
                            activityImageView.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 25, v.bounds.origin.y - 4, 34, 34);
                            if(a.status > 0){
                                [activityImageView stopAnimating];
                            } else {
                                if(![activityImageView isAnimating]){
                                    [activityImageView startAnimating];
                                }
                            }
                        } else {
                            [activityImageView stopAnimating];
                        }
                        
                    } else if(subview.tag == 50){
                        UIImageView *pinShadow = (UIImageView*)subview;
                        pinShadow.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - shadowWidth/2 + 4,
                                                     v.bounds.origin.y + 3, shadowWidth, 33);
                        pinShadow.image = [[UIImage imageNamed:@"Pin Shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f) resizingMode:UIImageResizingModeStretch];
                    } else if(subview.tag == 60){
                        UIImageView *pinStemShadow = (UIImageView*)subview;
                        pinStemShadow.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 8,
                                                         v.bounds.origin.y + 32, 9, 9);
                        pinStemShadow.image = [UIImage imageNamed:@"Pin Stem Shadow"];
                    } else if(subview.tag == 70){
                        UIImageView *pinStem = (UIImageView*)subview;
                        pinStem.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - 9.5,
                                                   v.bounds.origin.y + 18, 4, 24);
                        pinStem.image = [UIImage imageNamed:@"Pin Stem"];
                    } else if(subview.tag == 80){
                        UIImageView *pinCircle = (UIImageView*)subview;
                        pinCircle.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - width/2 - 7,
                                                     v.bounds.origin.y - 5, width, 34);
                        
                        if(a.type == 1){
                            pinCircle.image = [[UIImage imageNamed:@"Pink Dollar Pin"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0f, 17.0f, 17.0f, 17.0f) resizingMode:UIImageResizingModeStretch];
                        } else if(a.type == 2) {
                            if(a.status > 0){
                                pinCircle.image = [UIImage imageNamed:@"Bought Pin"];
                            } else {
                                pinCircle.image = [UIImage imageNamed:@"Pending Pin"];
                            }
                        } else {
                            pinCircle.image = [[UIImage imageNamed:@"Blue Dollar Pin"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0f, 17.0f, 17.0f, 17.0f) resizingMode:UIImageResizingModeStretch];
                        }
                    }
                    else if (subview.tag == 90) {
                        UILabel *label = (UILabel*)subview;
                        label.frame = CGRectMake((v.bounds.origin.x + v.bounds.size.width)/2 - size.width/2 - 4, v.bounds.origin.y - 4, size.width, size.height);
                        label.text = [NSString stringWithFormat:@"%i", (int)a.price];
                    }
                }
            }
        }
    }
    
    if([annotation isKindOfClass:[KPAnnotation class]]){
        
        v.image = nil;
        
    }
    
    return v;
    
}

//makes sure each added annotaion has no callout and no default image
- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    for(MKAnnotationView *view in views){
        
        if(view.tag != 1000){
            
            view.canShowCallout = NO;
            view.image = nil;
            
        }
        
    }
    
}

//depending on pin type display proper view and update necessary information
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if([view.annotation isKindOfClass:[KPAnnotation class]]){
        
        view.image = nil;
        
    } else if(![view.annotation isKindOfClass:[MKUserLocation class]]){
        
        return;
        
    }
    
    self.annotation = (KPAnnotation *)view.annotation;
    
    //if of type KPAnnotation apply the following
    if([view.annotation isKindOfClass:[KPAnnotation class]]){
        
        //if cluster zoom in on location to explode
        if(self.annotation.annotations.count > 1){
            
            [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.annotation.coordinate,self.annotation.radius * 2.5f, self.annotation.radius * 2.5f) animated:YES];
            
        } else if(self.annotation.type == 1){ //if posted annotation, update information then display view
            
            [self setupPostView:self.annotation];
            
        } else { //if available pin or requested pin, add necessary information then display view
            
            [self setupRequestView:self.annotation withCentering:YES];
            
        }
        
    }
    //    else if([view.annotation isKindOfClass:[MKUserLocation class]]) { //Otherwise if the annotation is the user location annotation begin posting process
    //
    //        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    //
    //            [self showLocationAlert];
    //
    //        } else if(self.user.hasPost){
    //
    //            [self customAlert:@"Currently, you're only allowed to post one spot at a time" withDone:@"OK" withColor:NO];
    //
    //        } else if(!self.user.vehicle.hasVehicle) {
    //
    //            self.user.code = MISSING_VEHICLE;
    //            MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
    //            [self presentViewController:viewController animated:YES completion:nil];
    //
    //        } else if(![self.user.braintree.subMerchant.status isEqualToString:@"active"]) {
    //
    //            self.user.code = MISSING_FUNDING_SOURCE;
    //            MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
    //            [self presentViewController:viewController animated:YES completion:^{}];
    //
    //        } else {
    //
    //            if(self.user.userSpeed > 0.0){
    //
    //                [self.user setUserSpeed:0.0f];
    //
    //                self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame
    //                                                         withMessage:TYPING_DISABLED_WHILE_DRIVING];
    //                [self.customAlert.leftButton setBackgroundColor:OP_LIGHT_GRAY_COLOR];
    //                [self.customAlert.leftButton setTitle:@"Passenger" forState:UIControlStateNormal];
    //                [self.customAlert.leftButton setTag:5];
    //                [self.customAlert.rightButton setBackgroundColor:OP_PINK_COLOR];
    //                [self.customAlert.rightButton setTitle:@"OK" forState:UIControlStateNormal];
    //                self.customAlert.customAlertDelegate = self;
    //                [self.parentViewController.view addSubview:self.customAlert];
    //                [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    //
    //            } else {
    //
    //                [self showPostView];
    //
    //            }
    //
    //        }
    //    }
}

//- (void)showPostView {
//
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
//
//    self.myGeoThread = [[NSThread alloc] initWithTarget:self selector:@selector(geoLocate:) object:location];
//    [self.myGeoThread start];
//
//    CLLocationCoordinate2D coord = self.annotation.coordinate;
//    coord.latitude += (TALL) ? self.mapView.region.span.latitudeDelta/SHIFT_USER_LOCATION_IOS7_4 : self.mapView.region.span.latitudeDelta/SHIFT_USER_LOCATION_IOS7_3;
//    [self.mapView setCenterCoordinate:coord animated:YES];
//
//    self.user.postCoordinate = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
//
//    [self addChildViewController:self.postSpotViewController];
//    [self.postSpotViewController.view setFrame:self.view.frame];
//    [self.view addSubview:self.postSpotViewController.view];
//    [self.postSpotViewController didMoveToParentViewController:self];
//
//}

- (void)showPostCustom {
    
    dropPinActive = true;
    //[self.mapView setShowsUserLocation:NO];
    [self.confirmDropPostBtn setEnabled:YES];
    [self.dropPinImageView setAlpha:1.0];
    [self.confirmDropPostBtn setAlpha:1.0];
    
}

//confirms selected annotation's image is nil - solves issues of default pin image appearing
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if([view.annotation isKindOfClass:[KPAnnotation class]])view.image = nil;
    
}

//if a pin's menu is being displayed and mapView changed, hide the menu and
//manually deselect annotation to fix bug in MKMapView
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    NSLog(@"regionWillChangeAnimated");
    if(currentView)[self hideCurrentView];
    
    [self.locationButton setUserInteractionEnabled:YES];
    
}

//update mapView on view changed if within constraits
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    //always refresh
    [self.treeController refresh:YES];
    
    //if not zoomed out beyond LAT_DELTA and LON_DELTA
    if(mapView.region.span.latitudeDelta < LAT_DELTA && mapView.region.span.longitudeDelta < LON_DELTA){
        
        //If outside the lat/long boundaries
        if(mapView.region.center.latitude < minLatitude || mapView.region.center.latitude > maxLatitude ||
           mapView.region.center.longitude < minLongitude || mapView.region.center.longitude > maxLongitude){
            
            [self refreshMapPins];
            
        }
    }
}

- (void)setupPostView:(KPAnnotation *)annotation {
    
    CLLocationCoordinate2D coord = annotation.coordinate;
    
    switch (deviceType) {
        case 3:
            coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_6P;
            break;
            
        case 2:
            coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_6;
            break;
            
        case 1:
            coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_5;
            break;
            
        case 0:
            coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_4;
            break;
            
        default:
            NSLog(@"Unknow device type");
            break;
    }
    
    [self.mapView setCenterCoordinate:coord animated:YES];
    
    CGSize size = [[[NSAttributedString alloc] initWithString:annotation.time attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:65]}] boundingRectWithSize:CGSizeMake(230.0f, 65.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    [self.mySpotTime setFrame:CGRectMake(self.mySpotDetailsContainer.frame.size.width/2 - size.width/2 - self.mySpotAMPM.frame.size.width/2, PADDING, size.width, self.mySpotTime.frame.size.height)];
    [self.mySpotAMPM setFrame:CGRectMake(self.mySpotTime.frame.origin.x + self.mySpotTime.frame.size.width, PADDING, self.mySpotAMPM.frame.size.width, self.mySpotAMPM.frame.size.height)];
    
    [self.mySpotTime setText:[NSString stringWithFormat:@"%@", annotation.time]];
    [self.mySpotAMPM setText:[NSString stringWithFormat:@"%@", annotation.AMPM]];
    [self.mySpotDate setText:[NSString stringWithFormat:@"%@", annotation.date]];
    
    [self.mySpotRequesterUsername setText:[annotation.r_username uppercaseString]];
    [self.mySpotRequesterCarInfo setText:[NSString stringWithFormat:@"%@ %@ %@", annotation.car_color, annotation.car_make, annotation.car_model]];
    [self.mySpotRequesterDealTotal setText:[NSString stringWithFormat:@"(%i)", annotation.total_deals]];
    
    if([self.user.userImages objectForKey:annotation.r_username] != nil){
        
        [self.mySpotRequesterImage setImage:[self.user.userImages objectForKey:annotation.r_username]];
        
    } else {
        
        [self.mySpotRequesterImage setImage:[UIImage imageNamed:@"Clear"]];
        self.updateRequesterImg = [[NSThread alloc] initWithTarget:self selector:@selector(fetchRequesterImage:) object:annotation.profile_image];
        [self.updateRequesterImg start];
        
    }
    
    float average = (annotation.total_deals != 0) ? (float)annotation.total_stars/(float)annotation.total_deals : 0.0f;
    if(average >= 5.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFive setImage:[UIImage imageNamed:@"Star Pink"]];
    } else if(average >= 4.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFive setImage:[UIImage imageNamed:@"Star Pink Half"]];
    } else if(average >= 4.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFour setImage:[UIImage imageNamed:@"Star Pink Half"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Star Pink Half"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.5){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Star Pink Half"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.0){
        [self.starOne setImage:[UIImage imageNamed:@"Star Pink"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else {
        [self.starOne setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.starFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    }
    
    switch (annotation.details) {
        case 0:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Inactive"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Inactive"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Inactive"]];
            break;
        case 1:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Inactive"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Inactive"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Active"]];
            break;
        case 2:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Inactive"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Active"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Inactive"]];
            break;
        case 3:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Inactive"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Active"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Active"]];
            break;
        case 4:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Active"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Inactive"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Inactive"]];
            break;
        case 5:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Active"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Inactive"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Active"]];
            break;
        case 6:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Active"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Active"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Inactive"]];
            break;
        case 7:
            [self.mySpotMeter setImage:[UIImage imageNamed:@"Meter Post Active"]];
            [self.mySpotPermit setImage:[UIImage imageNamed:@"Permit Post Active"]];
            [self.mySpotTimeLimit setImage:[UIImage imageNamed:@"Time Post Active"]];
            break;
            
        default:
            NSLog(@"Details weren't properly stored");
            break;
    }
    
    if(annotation.status > 0){
        if(!annotation.paid){
            [self.mySpotBtn setTitle:@"CANCEL DEAL" forState:UIControlStateNormal];
        } else {
            [self.mySpotBtn setTitle:@"LEAVE FEEDBACK" forState:UIControlStateNormal];
        }
        
        [self.mySpotPageControl setEnabled:YES];
        [self.mySpotPageControl setHidden:NO];
        [self.mySpotScroller setUserInteractionEnabled:YES];
        [self.mySpotMeter setFrame:CGRectMake(self.mySpotMeter.frame.origin.x, POST_IN_SWAP,
                                              self.mySpotMeter.frame.size.width, self.mySpotMeter.frame.size.height)];
        [self.mySpotPermit setFrame:CGRectMake(self.mySpotPermit.frame.origin.x, POST_IN_SWAP,
                                               self.mySpotPermit.frame.size.width, self.mySpotPermit.frame.size.height)];
        [self.mySpotTimeLimit setFrame:CGRectMake(self.mySpotTimeLimit.frame.origin.x, POST_IN_SWAP,
                                                  self.mySpotTimeLimit.frame.size.width, self.mySpotTimeLimit.frame.size.height)];
    } else {
        [self.mySpotBtn setTitle:@"REMOVE POST" forState:UIControlStateNormal];
        [self.mySpotPageControl setEnabled:NO];
        [self.mySpotPageControl setHidden:YES];
        [self.mySpotScroller setUserInteractionEnabled:NO];
        [self.mySpotMeter setFrame:CGRectMake(self.mySpotMeter.frame.origin.x, POST_NO_SWAP,
                                              self.mySpotMeter.frame.size.width, self.mySpotMeter.frame.size.height)];
        [self.mySpotPermit setFrame:CGRectMake(self.mySpotPermit.frame.origin.x, POST_NO_SWAP,
                                               self.mySpotPermit.frame.size.width, self.mySpotPermit.frame.size.height)];
        [self.mySpotTimeLimit setFrame:CGRectMake(self.mySpotTimeLimit.frame.origin.x, POST_NO_SWAP,
                                                  self.mySpotTimeLimit.frame.size.width, self.mySpotTimeLimit.frame.size.height)];
    }
    
    [self animateMyPostView:self.view.frame.size.height - self.myPostView.frame.size.height];
    
}

- (void)setupRequestView:(KPAnnotation *)annotation withCentering:(BOOL)shouldCenter {
    
    if(shouldCenter){
        
        NSLog(@"Centering map view %f %f %f %f", self.mapView.centerCoordinate.latitude, self.annotation.coordinate.latitude,
              self.mapView.centerCoordinate.longitude, self.annotation.coordinate.longitude);
        CLLocationCoordinate2D coord = annotation.coordinate;
        
        switch (deviceType) {
            case 3:
                coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_6P;
                break;
                
            case 2:
                coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_6;
                break;
                
            case 1:
                coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_5;
                break;
                
            case 0:
                coord.latitude += self.mapView.region.span.latitudeDelta/SHIFT_MAP_CENTER_4;
                break;
                
            default:
                NSLog(@"Unknow device type");
                break;
        }
        
        [self.mapView setCenterCoordinate:coord animated:YES];
        
    }
    
    [self.requestPageController setCurrentPage:0];
    
    CGSize size = [[[NSAttributedString alloc] initWithString:annotation.time attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:65]}] boundingRectWithSize:CGSizeMake(230.0f, 65.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    [self.requestTime setFrame:CGRectMake(160 - size.width/2 - self.requestAMPM.frame.size.width/2, 20, size.width,
                                          self.requestTime.frame.size.height)];
    [self.requestAMPM setFrame:CGRectMake(self.requestTime.frame.origin.x + self.requestTime.frame.size.width, 20,
                                          self.requestAMPM.frame.size.width, self.requestAMPM.frame.size.height)];
    
    [self.requestTime setText:[NSString stringWithFormat:@"%@", annotation.time]];
    [self.requestAMPM setText:[NSString stringWithFormat:@"%@", annotation.AMPM]];
    [self.requestDate setText:[NSString stringWithFormat:@"%@", annotation.date]];
    
    self.requestPosterUsername.text = [annotation.p_username uppercaseString];
    [self.requestPosterCarInfo setText:[NSString stringWithFormat:@"%@ %@ %@", annotation.car_color, annotation.car_make, annotation.car_model]];
    
    if([self.user.userImages objectForKey:annotation.p_username] != nil){
        
        NSLog(@"Have image already");
        [self.requestPosterImage setImage:[self.user.userImages objectForKey:annotation.p_username]];
        self.posterImage.image = [self.user.userImages objectForKey:annotation.p_username];
        
    } else {
        
        NSLog(@"Fetching image now");
        [self.requestPosterImage setImage:[UIImage imageNamed:@"Clear"]];
        self.myThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchNSData:) object:annotation.profile_image];
        [self.myThread start];
        
    }
    
    [self.requestPosterDealTotal setText:[NSString stringWithFormat:@"(%i)", annotation.total_deals]];
    
    size = [[[NSAttributedString alloc] initWithString:self.requestPosterDealTotal.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:17]}] boundingRectWithSize:CGSizeMake(230.0f, 21.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    [self.requestStarView setFrame:CGRectMake(160 - self.requestStarView.frame.size.width/2 - size.width/2, 135,
                                              self.requestStarView.frame.size.width, self.requestStarView.frame.size.height)];
    
    [self.requestPosterDealTotal setFrame:CGRectMake(self.requestStarView.frame.origin.x + self.requestStarView.frame.size.width, 133, size.width, self.requestPosterDealTotal.frame.size.height)];
    
    float average = (annotation.total_deals != 0) ? (float)annotation.total_stars/(float)annotation.total_deals : 0.0f;
    if(average >= 5.0){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Star Blue"]];
    } else if(average >= 4.5){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Star Blue Half"]];
    } else if(average >= 4.0){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.5){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 3.0){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.5){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 2.0){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.5){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Star Blue Half"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else if(average >= 1.0){
        [self.requestStarOne setImage:[UIImage imageNamed:@"Star Blue"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    } else {
        [self.requestStarOne setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarTwo setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarThree setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFour setImage:[UIImage imageNamed:@"Gray Star Outline"]];
        [self.requestStarFive setImage:[UIImage imageNamed:@"Gray Star Outline"]];
    }
    
    switch (annotation.car_size) {
        case 1:
            [self.requestCarSize setImage:[UIImage imageNamed:@"Small Blue"]];
            [self.requestCarSize setFrame:CGRectMake(44.5, 154, 39, 20)];
            break;
            
        case 2:
            [self.requestCarSize setImage:[UIImage imageNamed:@"Midsize Blue"]];
            [self.requestCarSize setFrame:CGRectMake(37, 154, 54, 20)];
            break;
            
        case 3:
            [self.requestCarSize setImage:[UIImage imageNamed:@"SUV Blue"]];
            [self.requestCarSize setFrame:CGRectMake(33.5, 152, 61, 24)];
            break;
            
        default:
            NSLog(@"Car size wasn't stored correctly");
            [self.requestCarSize setImage:[UIImage imageNamed:@"SUV Blue"]];
            [self.requestCarSize setFrame:CGRectMake(33.5, 152, 61, 24)];
            break;
    }
    
    switch (annotation.details) {
        case 0:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Gray"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Gray"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Gray"]];
            break;
        case 1:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Gray"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Gray"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Blue"]];
            break;
        case 2:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Gray"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Blue"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Gray"]];
            break;
        case 3:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Gray"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Blue"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Blue"]];
            break;
        case 4:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Blue"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Gray"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Gray"]];
            break;
        case 5:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Blue"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Gray"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Blue"]];
            break;
        case 6:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Blue"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Blue"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Gray"]];
            break;
        case 7:
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Blue"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Blue"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Blue"]];
            break;
            
        default:
            NSLog(@"Details weren't properly stored");
            [self.requestMeter setImage:[UIImage imageNamed:@"Meter Gray"]];
            [self.requestPermit setImage:[UIImage imageNamed:@"Permit Gray"]];
            [self.requestTimeLimit setImage:[UIImage imageNamed:@"Time Gray"]];
            break;
    }
    
    self.requestPosterCarInfo.text = [NSString stringWithFormat:@"%@ %@ %@", annotation.car_color, annotation.car_make, annotation.car_model];
    
    if(annotation.status > 0){
        if(!annotation.paid){
            [self.requestCancelButton setFrame:CGRectMake(0, self.requestCancelButton.frame.origin.y, self.spotInfo.frame.size.width/2, self.requestCancelButton.frame.size.height)];
            [self.requestPostButton setFrame:CGRectMake(self.spotInfo.frame.size.width/2, self.requestPostButton.frame.origin.y, self.spotInfo.frame.size.width/2, self.requestPostButton.frame.size.height)];
            [self.requestPostButton setTitle:@"PAY NOW" forState:UIControlStateNormal];
        } else {
            [self.requestPostButton setFrame:CGRectMake(self.spotInfo.frame.origin.x, self.requestPostButton.frame.origin.y, self.spotInfo.frame.size.width, self.requestPostButton.frame.size.height)];
            [self.requestPostButton setTitle:@"LEAVE FEEDBACK" forState:UIControlStateNormal];
        }
    } else if([annotation.r_username isEqualToString:self.user.username]){
        [self.requestPostButton setFrame:CGRectMake(self.spotInfo.frame.origin.x, self.requestPostButton.frame.origin.y, self.spotInfo.frame.size.width, self.requestPostButton.frame.size.height)];
        [self.requestPostButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
    } else {
        [self.requestPostButton setFrame:CGRectMake(self.spotInfo.frame.origin.x, self.requestPostButton.frame.origin.y, self.spotInfo.frame.size.width, self.requestPostButton.frame.size.height)];
        [self.requestPostButton setTitle:@"REQUEST NOW" forState:UIControlStateNormal];
    }
    
    if(annotation.status > 0){
        
        (self.user.profileImage) ? self.requesterImage.image = self.user.profileImage : [self.requesterImage setImage:[UIImage imageNamed:@"No Profile Image"]];
        
        NSLog(@"%@ %@", self.annotation.address, self.annotation.city_region);
        [self.requestAddress setText:self.annotation.address];
        [self.requestAddress setAlpha:1.0f];
        [self.requestAddress setFrame:CGRectMake(0, 110, 320, 21)];
        
        [self.requestCityRegion setText:self.annotation.city_region];
        [self.requestCityRegion setAlpha:1.0f];
        [self.requestCityRegion setFrame:CGRectMake(0, 130, 320, 21)];
        
        [self.requestScroller setContentSize:CGSizeMake(self.view.frame.size.width*3, 205)];
        [self.requestPageController setNumberOfPages:3];
        [self.requestDirectionsView setHidden:NO];
        
        [self.requestDirectionsView setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.requestDirectionsView.frame.size.height)];
        [self.requestDetailsView setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.requestDetailsView.frame.size.height)];
        [self.requestPosterInfoView setFrame:CGRectMake(self.view.frame.size.width*2 + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.requestPosterInfoView.frame.size.height)];
        
    } else {
        
        [self.requestScroller setContentSize:CGSizeMake(self.view.frame.size.width*2, 205)];
        [self.requestPageController setNumberOfPages:2];
        [self.requestDirectionsView setHidden:YES];
        
        [self.requestDirectionsView setFrame:CGRectMake(-self.view.frame.size.width, 0, self.requestDirectionsView.frame.size.width, self.requestDirectionsView.frame.size.height)];
        [self.requestDetailsView setFrame:CGRectMake(self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.requestDetailsView.frame.size.height)];
        [self.requestPosterInfoView setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2 - MAX_WIDTH/2, 0, MAX_WIDTH, self.requestPosterInfoView.frame.size.height)];
        
    }
    
    if(currentView != 1)[self animateSpotInfo:self.view.frame.size.height - self.spotInfo.frame.size.height];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//Location Manager
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation * newLocation = [locations lastObject];
    
    //NSLog(@"User's speed - %f", newLocation.speed);
    [self.user setUserLocation:CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)];
    if(newLocation.speed > 5.0){
        
        [self.user setUserSpeed:newLocation.speed];
        
    } else {
        
        [self.user setUserSpeed:0.0f];
        
    }
    
    //
    if(!updatedLocation && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) &&
       newLocation.horizontalAccuracy <= 65.0f &&
       newLocation.coordinate.latitude != 0.0 &&
       newLocation.coordinate.longitude != 0.0){
        
        NSLog(@"Zoomed in on location!");
        
        updatedLocation = true;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = newLocation.coordinate.latitude;
        coordinate.longitude = newLocation.coordinate.longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
        
        [self.mapView setRegion:viewRegion animated:YES];
        self.mapView.showsUserLocation = YES;
        
    }
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
    NSLog(@"Loctaion manager paused so setting speed to 0");
    [self.user setUserSpeed:0.0f];
    
}

/*
 //constantly stores user's location and if first onpening the app it zooms to location
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
 
 NSLog(@"Setting user location");
 [self.user setUserLocation:CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)];
 
 if(!updatedLocation && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized  && newLocation.horizontalAccuracy <= 65.0f && newLocation.coordinate.latitude != 0 && newLocation.coordinate.longitude != 0){
 
 //dismisses alert indicating location services were disabled
 //        if([self.user.alertView isVisible]){
 //            NSLog(@"Dismissing alertView");
 //            [self.user.alertView dismissWithClickedButtonIndex:0 animated:YES];
 //        }
 updatedLocation = true;
 
 CLLocationCoordinate2D coordinate;
 coordinate.latitude = newLocation.coordinate.latitude;
 coordinate.longitude = newLocation.coordinate.longitude;
 MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
 
 [self.mapView setRegion:viewRegion animated:NO];
 self.mapView.showsUserLocation = YES;
 
 } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
 
 NSLog(@"Showing location alertView");
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
 message:@"To continue using Organic Parking, location services must be enabled in settings"
 delegate:self
 cancelButtonTitle:@"Change in settings"
 otherButtonTitles:nil];
 [alert show];
 
 } else {
 
 NSLog(@"Location services is acting weird");
 
 }
 
 }
 */

//if user has disabled location services, show alert
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied && !locationAlertShowing)[self showLocationAlert];
    
}

- (void)showLocationAlert {
    
    locationAlertShowing = YES;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Services"
                                                        message:@"To use Organic Parking, location services must be enabled within Settings"
                                                       delegate:self
                                              cancelButtonTitle:@"Settings"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Services"
                                                        message:@"To use Organic Parking, location services must be enabled within Settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

//used for checking if location services are enabled - if not, keep showing alert to prevent usage of the app
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        
        locationAlertShowing = NO;
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))if(!buttonIndex)[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        
    }
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//main viewController objects
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//centers on user curent location
- (IBAction)findMe:(id)sender {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self showLocationAlert];
        
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
              [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = self.locationManager.location.coordinate.latitude;
        coordinate.longitude = self.locationManager.location.coordinate.longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
        
        if(viewRegion.span.latitudeDelta == self.mapView.region.span.latitudeDelta &&
           viewRegion.span.longitudeDelta == self.mapView.region.span.longitudeDelta){
            
            [self.mapView setCenterCoordinate:coordinate animated:YES];
            
        } else {
            
            [self.mapView setRegion:viewRegion animated:YES];
            
        }
        
    }
    
}

- (IBAction)findDeals:(id)sender {
    
    if(self.user.hasPost && self.user.hasRequest && self.user.post.status < STATUS_LIMIT && self.user.request.status < STATUS_LIMIT){
        
        float minLat = MIN(self.user.post.coordinate.latitude, self.user.request.coordinate.latitude);
        float maxLat = MAX(self.user.post.coordinate.latitude, self.user.request.coordinate.latitude);
        float minLong = MIN(self.user.post.coordinate.longitude, self.user.request.coordinate.longitude);
        float maxLong = MAX(self.user.post.coordinate.longitude, self.user.request.coordinate.longitude);
        
        CLLocation *postCoordinate = [[CLLocation alloc] initWithLatitude:self.user.post.coordinate.latitude longitude:self.user.post.coordinate.longitude];
        CLLocation *requestCoordinate = [[CLLocation alloc] initWithLatitude:self.user.request.coordinate.latitude longitude:self.user.request.coordinate.longitude];
        
        CLLocationDistance meters = [postCoordinate distanceFromLocation:requestCoordinate];
        
        MKCoordinateRegion region;
        region.center.latitude = (minLat + maxLat)/2.0f;
        region.center.longitude = (minLong + maxLong)/2.0f;
        region.span.latitudeDelta = meters/50000.0f;
        region.span.longitudeDelta = 0.0f;
        
        [self.mapView setRegion:region animated:YES];
        
    } else {
        
        if(self.user.hasPost && self.user.post.status < STATUS_LIMIT &&
           self.user.post.coordinate.latitude != 0.0f && self.user.post.coordinate.longitude != 0.0f){
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.user.post.coordinate, METERS_PER_MILE, METERS_PER_MILE);
            [self.mapView setRegion:region animated:YES];
            
        } else if (self.user.hasRequest && self.user.request.status < STATUS_LIMIT &&
                   self.user.request.coordinate.latitude != 0.0f && self.user.request.coordinate.longitude != 0.0f) {
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.user.request.coordinate, METERS_PER_MILE, METERS_PER_MILE);
            [self.mapView setRegion:region animated:YES];
            
        }
        
    }
    
}

- (BOOL)isNumeric:(NSString*)checkText {
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:checkText];
    
    if (number != nil) {
        
        return true;
        
    }
    
    return false;
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//page controller methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(currentView == 1){
        
        CGFloat pageWidth = self.requestScroller.frame.size.width;
        int page = floor((self.requestScroller.contentOffset.x - pageWidth/2)/pageWidth)+1;
        self.requestPageController.currentPage = page;
        
    } else if(currentView == 2) {
        
        CGFloat pageWidth = self.mySpotScroller.frame.size.width;
        int page = floor((self.mySpotScroller.contentOffset.x - pageWidth/2)/pageWidth)+1;
        self.mySpotPageControl.currentPage = page;
        
    }
    
}

- (IBAction)pageControllerValueChange:(id)sender {
    
    CGRect frame = CGRectMake((self.requestScroller.contentSize.width/self.requestPageController.numberOfPages)*self.requestPageController.currentPage, 0, self.requestScroller.frame.size.width, self.requestScroller.frame.size.height);
    [self.requestScroller scrollRectToVisible:frame animated:YES];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//

- (IBAction)showMenu:(id)sender {
    
    //NSLog(@"showMenu ACCORDION_WIDH = %f", ACCORDION_WIDH);
    
    if(self.mainPosition.x == ACCORDION_WIDH) {
        
        [self animateLayerToPointX:0];
        menuActive = false;
        self.mapView.userInteractionEnabled = YES;
        self.searchBarClear.userInteractionEnabled = YES;
        
    } else {
        
        [self animateLayerToPointX:ACCORDION_WIDH];
        self.mapView.userInteractionEnabled = NO;
        self.searchBarClear.userInteractionEnabled = NO;
        
    }
    
}

- (IBAction)menuPressed:(id)sender {
    
    NSLog(@"menuPressed currentView = %d", currentView);
    menuActive = true;
    if(currentView)[self hideCurrentView];
    
}

- (IBAction)locationPressed:(id)sender {
    
    if(currentView)[self hideCurrentView];
    
}

- (IBAction)chatPressed:(id)sender {
    
    if(currentView)[self hideCurrentView];
    
}

- (IBAction)chatReleased:(id)sender {
    
    MainViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"chatRooms"];
    [self.navigationController pushViewController:view animated:YES];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//View animation methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//

- (void)animateSpotInfo:(CGFloat)y {
    
    [UIView animateWithDuration:ANIMATION_SPEED
                     animations:^{
                         CGRect frame = self.spotInfo.frame;
                         frame.origin.y = y;
                         self.spotInfo.frame = frame;
                     } completion:^(BOOL finished) {
                         if(y == self.view.frame.size.height){
                             currentView = 0;
                             [self.requestScroller scrollRectToVisible:CGRectMake(0, 0, 320, 205) animated:NO];
                         } else {
                             currentView = 1;
                         }
                     }];
    
}

-(void) animateMyPostView:(CGFloat)y
{
    [UIView animateWithDuration:ANIMATION_SPEED
                     animations:^{
                         CGRect frame = self.myPostView.frame;
                         frame.origin.y = y;
                         self.myPostView.frame = frame;
                     } completion:^(BOOL finished) {
                         //set scroller back to initial page after hidden
                         if(self.myPostView.frame.origin.y == self.view.frame.size.height){
                             currentView = 0;
                             [self.mySpotPageControl setCurrentPage:0];
                             [self.mySpotPageControl sendActionsForControlEvents:UIControlEventValueChanged];
                         } else {
                             currentView = 2;
                         }
                     }
     ];
}

- (void)animateLayerToPointX:(CGFloat)x {
    
    [self.locationButton setUserInteractionEnabled:(x == ACCORDION_WIDH) ? NO : YES];
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:ANIMATION_SPEED delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.main.frame;
                         frame.origin.x = x;
                         self.main.frame = frame;
                     }
                     completion:^(BOOL finished){
                         _mainPosition.x = self.main.frame.origin.x;
                     }];
}

- (void)showTutorial {
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:ANIMATION_SPEED delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.main.frame;
                         frame.origin.x = 0.0f;
                         self.main.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         
                         _mainPosition.x = self.main.frame.origin.x;
                         
                         menuActive = false;
                         self.mapView.userInteractionEnabled = YES;
                         self.searchBarClear.userInteractionEnabled = YES;
                         self.locationButton.userInteractionEnabled = YES;
                         
                         MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
                         [self addChildViewController:viewController];
                         [viewController.view setFrame:self.view.frame];
                         [viewController.view setAlpha:0.0f];
                         [self.view addSubview:viewController.view];
                         [viewController didMoveToParentViewController:self];
                         
                     }];
    
}

//*****************************************************************************************************************************//
//*****************************************************************************************************************************//
//UIGestureRecognizer Methods
//*****************************************************************************************************************************//
//*****************************************************************************************************************************//

- (IBAction)dropPost:(UIGestureRecognizer *)recognizer {
    
    UILongPressGestureRecognizer *recognize = (UILongPressGestureRecognizer *)recognizer;
    if(recognize.state == UIGestureRecognizerStateBegan && !dropPinActive && !currentView){
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            
            [self showLocationAlert];
            
        } else if(self.user.hasPost){
            
            [self customAlert:@"Currently, you're only allowed to post one spot at a time" withDone:@"OK" withColor:NO withTag:0];
            
            //        } else if(!self.user.vehicle.hasVehicle) {
            //
            //            self.user.code = MISSING_VEHICLE;
            //            MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
            //            [self presentViewController:viewController animated:YES completion:nil];
            
            //        } else if(![self.user.braintree.subMerchant.status isEqualToString:@"active"]) {
            //
            //            self.user.code = MISSING_FUNDING_SOURCE;
            //            MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
            //            [self presentViewController:viewController animated:YES completion:^{}];
            
        } else {
            
            if(self.user.userSpeed > 0.0){
                
                [self.user setUserSpeed:0.0f];
                
                self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.parentViewController.view.frame
                                                         withMessage:TYPING_DISABLED_WHILE_DRIVING];
                [self.customAlert.leftButton setBackgroundColor:OP_LIGHT_GRAY_COLOR];
                [self.customAlert.leftButton setTitle:@"Passenger" forState:UIControlStateNormal];
                [self.customAlert.leftButton setTag:4];
                [self.customAlert.rightButton setBackgroundColor:OP_PINK_COLOR];
                [self.customAlert.rightButton setTitle:@"OK" forState:UIControlStateNormal];
                [self.customAlert.rightButton setTag:4];
                self.customAlert.customAlertDelegate = self;
                [self.parentViewController.view addSubview:self.customAlert];
                [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
                
            } else {
                
                [self showPostCustom];
                
            }
            
        }
    }
}

- (void)confirmDropPost {
    
    [self.confirmDropPostBtn setEnabled:NO];
    [self.confirmDropPostBtn setAlpha:0.0];
    dropPinInPostState = true;
    
    CLLocationCoordinate2D coord = self.mapView.region.center;
    //coord.longitude = coord.longitude + self.mapView.region.span.longitudeDelta/1000.0;
    switch (deviceType) {
        case 3:
            coord.latitude -= self.mapView.region.span.latitudeDelta/SHIFT_POST_AMOUNT_6P;
            break;
            
        case 2:
            coord.latitude -= self.mapView.region.span.latitudeDelta/SHIFT_POST_AMOUNT_6;
            break;
            
        case 1:
            coord.latitude -= self.mapView.region.span.latitudeDelta/SHIFT_POST_AMOUNT_5;
            break;
            
        case 0:
            coord.latitude -= self.mapView.region.span.latitudeDelta/SHIFT_POST_AMOUNT_4;
            break;
            
        default:
            NSLog(@"Unknow device type");
            break;
    }
    
    NSLog(@"Long shift: %f", self.mapView.region.span.longitudeDelta/1000.0);
    
    self.user.postCoordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude);
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [self fetchAddress:loc];
    
    //    self.myGeoThread = [[NSThread alloc] initWithTarget:self selector:@selector(geoLocate:) object:loc];
    //    [self.myGeoThread start];
    //
    //    NSLog(@"%f", coord.latitude);
}

- (void)fetchAddress:(CLLocation *)loc {
    
    [UserInfo createHUD:self.view withOffset:0.0f];
    
    if(!self.geoCoder)self.geoCoder = [[CLGeocoder alloc] init];
    
    [self.geoCoder reverseGeocodeLocation:loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if (error) {
             NSLog(@"Geocode failed with error: %@", error);
             return ;
         } else if(placemarks && placemarks.count > 0) {
             CLPlacemark *placemark = placemarks[0];
             [self validateAddress:placemark];
         } else {
             NSLog(@"Not sure what just happened - geoLocate");
         }
     }];
    
}

- (void)validateAddress:(CLPlacemark *)placemark {

    /*//&&&&&&&&&
    if(![placemark.country isEqualToString:@"Greece"]){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissedPostView];
        [self customAlert:@"OPA works only in Greece" withDone:@"OΚ" withColor:YES withTag:0];
        return;
    }
    */
    NSString * address = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
    NSString * city_region = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:city_region, @"city_region", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@validAddress", self.user.uri] parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSLog(@"%@", responseObject);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSString * message = [[responseObject valueForKeyPath:@"alert"] valueForKey:@"message"];
             if([message isEqualToString:@"valid"]){
                 
                 self.user.postAddress = address;
                 self.user.postCityRegion = city_region;
                 
                 
                 
                 
                 [self addChildViewController:self.postSpotViewController];
                 [self.postSpotViewController.view setFrame:self.view.frame];
                 [self.view addSubview:self.postSpotViewController.view];
                 [self.postSpotViewController didMoveToParentViewController:self];
                 
             } else {
                 
                 [self dismissedPostView];
                 [self customAlert:@"Organic Parking is unavailable in this city" withDone:@"OK" withColor:YES withTag:0];
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"%@", operation.responseObject);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [self dismissedPostView];
             
             if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                 
                 [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                          withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"] withColor:YES withTag:0];
                 
             } else {
                 
                 [self customAlert:@"Unable to begin posting process" withDone:@"OK" withColor:YES withTag:0];
                 
             }
             
         }];
    
}

- (void)dismissedPostView {
    
    if(self.user.shouldRefreshMapPins){
        
        [self.user setShouldRefreshMapPins:NO];
        [self refreshMapPins];
        
    }
    
    if(dropPinInPostState){
        
        dropPinActive = false;
        dropPinInPostState = false;
        [self.confirmDropPostBtn setEnabled:NO];
        [self.dropPinImageView setAlpha:0.0];
        [self.confirmDropPostBtn setAlpha:0.0];
        
    }
    
}

- (void)swipe:(UIGestureRecognizer*)recognizer {
    
    UIPanGestureRecognizer *recognize = (UIPanGestureRecognizer*)recognizer;
    if(recognizer.state == UIGestureRecognizerStateChanged && menuActive){
        
        CGPoint point = [recognize translationInView:self.main];
        CGRect frame = self.main.frame;
        
        if(self.mainPosition.x + point.x <= ACCORDION_WIDH)frame.origin.x = self.mainPosition.x + point.x;
        if(frame.origin.x < 0)frame.origin.x = 0;
        self.main.frame = frame;
        
        self.mapView.userInteractionEnabled = NO;
        self.searchBarClear.userInteractionEnabled = NO;
        
    } else if(recognizer.state == UIGestureRecognizerStateEnded && menuActive){
        
        if (self.spotInfo.frame.origin.y < 460){
            self.mapView.userInteractionEnabled = YES;
            self.searchBarClear.userInteractionEnabled = YES;
        }
        if(self.main.frame.origin.x <= ACCORDION_WIDH/2) {
            [self animateLayerToPointX:0];
            menuActive = false;
            self.mapView.userInteractionEnabled = YES;
            self.searchBarClear.userInteractionEnabled = YES;
            self.locationButton.userInteractionEnabled = YES;
        } else {
            [self animateLayerToPointX:ACCORDION_WIDH];
            self.mapView.userInteractionEnabled = NO;
            self.searchBarClear.userInteractionEnabled = NO;
            self.locationButton.userInteractionEnabled = NO;
        }
    }
}

- (IBAction)tap:(UITapGestureRecognizer *)tapped {
    if(tapped.state == UIGestureRecognizerStateEnded) {
        CGPoint point1 = [tapped locationInView:self.container];
        CGPoint point2 = [tapped locationInView:self.main];
        
        if(menuActive){
            if(point1.x >= ACCORDION_WIDH && point2.x > 0)
            {
                [self animateLayerToPointX:0];
                self.mapView.userInteractionEnabled = YES;
                self.searchBarClear.userInteractionEnabled = YES;
                self.locationButton.userInteractionEnabled = YES;
            }
        }
        menuActive = false;
        
        if(self.mainPosition.x == 0.0 && self.mainPosition.y == 0.0 && currentView != 0){
            
            NSLog(@"Hiding current view on tap");
            if(currentView)[self hideCurrentView];
            
        }
        
        if(dropPinInPostState){
            
            NSLog(@"Actually got here!");
            
            [UIView animateWithDuration:ANIMATION_SPEED animations:^{
                
                [self.confirmDropPostBtn setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                
                dropPinInPostState = false;
                [self.confirmDropPostBtn setEnabled:YES];
                
            }];
            
        } else if(dropPinActive && !dropPinInPostState) {
            
            [self hidePost];
            
        }
        
    }
    
}

- (void)hidePost {
    
    dropPinActive = false;
    //[self.mapView setShowsUserLocation:YES];
    [self.confirmDropPostBtn setEnabled:NO];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{
        
        [self.dropPinImageView setAlpha:0.0];
        [self.confirmDropPostBtn setAlpha:0.0];
        
    }];
    
}

//if user has no account
- (void)noAccount {
    
    //setup alert and ask user to confirm log out action
    self.customAlert = [[CustomAlert alloc] initWithType:2 withframe:self.view.frame withMessage:@"You need to login or create an account"];
    
    [self.customAlert.leftButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]];
    [self.customAlert.leftButton setTitle:@"Later" forState:UIControlStateNormal];
    [self.customAlert.leftButton setTag:0];
    
    [self.customAlert.rightButton setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [self.customAlert.rightButton setTitle:@"Now" forState:UIControlStateNormal];
    [self.customAlert.rightButton setTag:5];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.parentViewController.view addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (void)customAlert:(NSString *)alert withDone:(NSString *)done withColor:(BOOL)color withTag:(NSInteger)tag {
    
    if(self.customAlert)[UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:0.0f];}];
    
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.frame withMessage:alert];
    self.customAlert.tag = tag;
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    if(color)[self.customAlert.leftButton setBackgroundColor:OP_PINK_COLOR];
    
    self.customAlert.customAlertDelegate = self;
    
    [self.view addSubview:self.customAlert];
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

- (void)leftActionMethod:(int)method {

    switch (method) {
        case 4:
            [self showPostCustom];
            break;
            
        default:
            
            break;
    }
    
    switch (self.customAlert.tag) {
        case 33:
            self.user.feebackInfo = [[Feedback alloc] initWithRatee:self.user.post.r_username swapTime:self.user.post.swap_time status:3 postID:self.user.post.post_id];
            [self rateDeal];
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    }];
    
}

- (void)rightActionMethod:(int)method {
    
    switch (method) {
        case 1:
            [self confirmRemovePost];
            break;
            
        case 3:
            [self cancelRequest];
            break;
            
        case 4:
            [self hidePost];
            break;
            
        case 5:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
            break;
            
        case 7:
            [self cancelDealConfirmed:method];
            break;
            
        case 8:
            [self cancelDealConfirmed:method];
            break;
            
        case 9:
            [self confirmedSendPayment];
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:ANIMATION_SPEED animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    }];
    
}

@end
