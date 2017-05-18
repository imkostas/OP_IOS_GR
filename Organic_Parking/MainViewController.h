//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "UserInfo.h"
#import "KPTreeController.h"
#import "Definitions.h"

@interface MainViewController : UIViewController

<UIScrollViewDelegate, MKMapViewDelegate, KPTreeControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, PushControlDelegate, CustomAlertDelegate>

//views used in main view
@property (strong, nonatomic) IBOutlet UIView *container; //self.view
@property (strong, nonatomic) IBOutlet UIView *main; //holds contents of main
@property (strong, nonatomic) IBOutlet UIView *menu; //holds contents of menu
@property (strong, nonatomic) IBOutlet UIView *spotInfo; //holds contents of available spot details
@property (strong, nonatomic) IBOutlet UIView *myPostView; //holds contents of posted spot details

//main view objects
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //nav bar image
@property (strong, nonatomic) IBOutlet UIImageView *topBarLogo;
@property (strong, nonatomic) IBOutlet MKMapView *mapView; //map view for showing pins
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar; //search bar for aesthetic purposes
@property (strong, nonatomic) IBOutlet UIButton *searchBarClear; //segues to search view
@property (strong, nonatomic) IBOutlet UIButton *menuButton; //hides or unhides menu
@property (strong, nonatomic) IBOutlet UIButton *chatroomBtn; //segues to chatrooms view
@property (strong, nonatomic) IBOutlet UIButton *locationButton; //centers on user location
@property (strong, nonatomic) IBOutlet UIButton *dealButton; //centers on user posts or deals
@property (strong, nonatomic) IBOutlet UIButton *filtersBtn; //segues to filters view

//my posted spot view objects
@property (strong, nonatomic) IBOutlet UIImageView *mySpotBackground;
@property (strong, nonatomic) IBOutlet UIImageView *mySpotBackgroundTip;
@property (strong, nonatomic) IBOutlet UIScrollView *mySpotScroller; //scroll view to hold contents of posted spot view
@property (weak, nonatomic) IBOutlet UIView *mySpotDetailsContainer;
@property (weak, nonatomic) IBOutlet UIView *mySpotRequesterDetailsContainer;
@property (strong, nonatomic) IBOutlet UIPageControl *mySpotPageControl; //indicates current page of posted spot view
@property (strong, nonatomic) IBOutlet UIButton *mySpotBtn; //used for removing post, canceling deal, or rating
@property (strong, nonatomic) IBOutlet UILabel *mySpotTime; //displays posted spot time
@property (strong, nonatomic) IBOutlet UILabel *mySpotAMPM; //displays AM or PM
@property (strong, nonatomic) IBOutlet UILabel *mySpotDate; //displays post date
@property (strong, nonatomic) IBOutlet UIImageView *mySpotMeter; //indicates post is metered
@property (strong, nonatomic) IBOutlet UIImageView *mySpotPermit; //indicates post needs permit
@property (strong, nonatomic) IBOutlet UIImageView *mySpotTimeLimit; //indicates post has time limit
@property (strong, nonatomic) IBOutlet UIView *mySpotRequesterStarView; //holds contents for rating stars
@property (strong, nonatomic) IBOutlet UIImageView *starOne; //star rating of one
@property (strong, nonatomic) IBOutlet UIImageView *starTwo; //star rating of two
@property (strong, nonatomic) IBOutlet UIImageView *starThree; //star rating of three
@property (strong, nonatomic) IBOutlet UIImageView *starFour; //star rating of four
@property (strong, nonatomic) IBOutlet UIImageView *starFive; //star rating of five
@property (strong, nonatomic) IBOutlet UILabel *mySpotRequesterDealTotal; //indicates number of ratings
@property (strong, nonatomic) IBOutlet UIImageView *mySpotRequesterImage; //dislpays requester image
@property (strong, nonatomic) IBOutlet UILabel *mySpotRequesterUsername; //displays requester username
@property (strong, nonatomic) IBOutlet UILabel *mySpotRequesterCarInfo; //dislpays requester car info

//available spot objects
@property (strong, nonatomic) IBOutlet UIImageView *requestBackground;
@property (strong, nonatomic) IBOutlet UIImageView *requestBackgroundTip;
@property (strong, nonatomic) IBOutlet UIView *requestDirectionsView;
@property (strong, nonatomic) IBOutlet UIView *requestDetailsView;
@property (strong, nonatomic) IBOutlet UIView *requestPosterInfoView;
@property (strong, nonatomic) IBOutlet UIScrollView *requestScroller; //scroll view to hold contents of an available spot
@property (strong, nonatomic) IBOutlet UIPageControl *requestPageController; //indicates current page of available spot view
@property (strong, nonatomic) IBOutlet UIButton *requestCancelButton;
@property (strong, nonatomic) IBOutlet UIButton *requestPostButton; //used for requesting post, canceling deal, and rating
@property (strong, nonatomic) IBOutlet UILabel *requestTime; //displays available spot time
@property (strong, nonatomic) IBOutlet UILabel *requestAMPM; //displays AM or PM
@property (strong, nonatomic) IBOutlet UILabel *requestDate; //displays available spot date
@property (strong, nonatomic) IBOutlet UIImageView *requestMeter; //indicates if spot is metered
@property (strong, nonatomic) IBOutlet UIImageView *requestPermit; //indicates if spot needs permit
@property (strong, nonatomic) IBOutlet UIImageView *requestTimeLimit; //indicates if spot has time limit
@property (strong, nonatomic) IBOutlet UIImageView *requestCarSize; //indicates poster's car size
@property (strong, nonatomic) IBOutlet UIView *requestStarView; //holds contents of rating stars
@property (strong, nonatomic) IBOutlet UIImageView *requestStarOne; //star rating of one
@property (strong, nonatomic) IBOutlet UIImageView *requestStarTwo; //star rating of two
@property (strong, nonatomic) IBOutlet UIImageView *requestStarThree; //star rating of three
@property (strong, nonatomic) IBOutlet UIImageView *requestStarFour; //star rating of four
@property (strong, nonatomic) IBOutlet UIImageView *requestStarFive; //star rating of five
@property (strong, nonatomic) IBOutlet UILabel *requestPosterDealTotal; //indicates number of ratings
@property (strong, nonatomic) IBOutlet UIImageView *requestPosterImage; //displays poster profile image
@property (strong, nonatomic) IBOutlet UILabel *requestPosterUsername; //displays poster username
@property (strong, nonatomic) IBOutlet UILabel *requestPosterCarInfo; //displays poster car info
@property (strong, nonatomic) IBOutlet UIImageView *requesterImage; //displays user's image if in deal
@property (strong, nonatomic) IBOutlet UIImageView *posterImage; //displays poster's image if in deal
@property (strong, nonatomic) IBOutlet UILabel *requestAddress; //displays post address
@property (strong, nonatomic) IBOutlet UILabel *requestCityRegion; //dsiplays post city and region
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

//view variables
@property (nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom alert

//objects to store and cluster annotations
@property (nonatomic, strong) KPTreeController *treeController;
@property (nonatomic) KPAnnotation *annotation;

//tracking
@property (nonatomic, strong) MKPointAnnotation *trackingPoint;
@property (nonatomic, strong) MKAnnotationView *trackingPin;

//used for menu slide functionality
@property (nonatomic) CGPoint mainPosition;

//geocoding spot locations
@property (strong, nonatomic) CLGeocoder *geoCoder;

//threads to perform side tasks
@property (nonatomic, strong) NSThread *myThread;
@property (nonatomic, strong) NSThread *myGeoThread;
@property (nonatomic, strong) NSThread *updateProfileImg;
@property (nonatomic, strong) NSThread *updateRequesterImg;
@property (nonatomic, strong) NSThread *fetchClientTokenThread;
@property (nonatomic, strong) NSThread *fetchPaymentMethodsThread;
@property (nonatomic, strong) NSThread *fetchSubMerchantThread;

//timers to refresh pins and check requests
@property (nonatomic, strong) NSTimer *refreshTimer;

//location manager to update and get user location
@property (nonatomic, strong) CLLocationManager *locationManager;

//gesture recognizers
@property (nonatomic, strong) UIPanGestureRecognizer *panned;
@property (strong, nonatomic) UIImageView *dropPinImageView;
@property (nonatomic, strong) UIButton *confirmDropPostBtn;

//badge object to indicate unread messages or alerts
//@property (nonatomic ,strong) CustomBadge *chatBadge;

//view controller objects for reuse to reduce memory used
@property (nonatomic, strong) MainViewController *viewController;
@property (nonatomic, strong) MainViewController *postSpotViewController;

//instance methods
- (void)dismissedPostView;
- (void)showTutorial;

@end
