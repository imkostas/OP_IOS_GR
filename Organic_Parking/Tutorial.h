//
//  Tutorial.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@interface Tutorial : UIViewController <UIScrollViewDelegate>

//scroll view and contents
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scroll view to hold view contents
@property (strong, nonatomic) IBOutlet UIPageControl *pageController; //indicates current page tutorial
@property (strong, nonatomic) IBOutlet UIImageView *tutorialImageOne; //tutorial page one image
@property (strong, nonatomic) IBOutlet UIImageView *tutorialImageTwo; //tutorial page two image
@property (strong, nonatomic) IBOutlet UIImageView *tutorialImageThree; //tutorial page three image
@property (strong, nonatomic) IBOutlet UIImageView *tutorialImageFour; //tutorial page four image
@property (strong, nonatomic) IBOutlet UIButton *skipBtn; //dismisses tutorial

@property (nonatomic, strong) UserInfo *user; //user info

@end
