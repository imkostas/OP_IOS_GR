//
//  Tutorial.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Tutorial.h"

@interface Tutorial ()
{
    // Keeps track of the current page/image that is being displayed, for use when rotating
    int tutorialPageBeforeRotation;
}

@end

@implementation Tutorial

//#define TUTORIAL_WIDTH 320.0
//#define TUTORIAL_HEIGHT 388.0

#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define TUTORIAL_WIDTH         (iPad ? 640 : 320.0)
#define TUTORIAL_HEIGHT         (iPad ? 776.0 : 388.0)

//#define TUTORIAL_WIDTH  (iPad ? ([[UIScreen mainScreen] bounds].size.width)*.8 : 320.)
//#define TUTORIAL_HEIGHT (iPad ? ([[UIScreen mainScreen] bounds].size.height)*.8 : 388.0)

#define NUMBER_OF_PAGES 4

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
//    NSLog(@"WDTH +++++++ = %f", [[UIScreen mainScreen] bounds].size.width);
    
    //position view objects
    [self.background setFrame:self.view.frame];
    [self.scrollView setFrame:self.view.frame];
    [self.tutorialImageOne setFrame:CGRectMake(self.view.frame.size.width/2 - TUTORIAL_WIDTH/2, self.scrollView.frame.origin.y, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageTwo setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2 - TUTORIAL_WIDTH/2, self.scrollView.frame.origin.y, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageThree setFrame:CGRectMake((self.view.frame.size.width * 2) + self.view.frame.size.width/2 - TUTORIAL_WIDTH/2, self.scrollView.frame.origin.y, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageFour setFrame:CGRectMake((self.view.frame.size.width * 3) + self.view.frame.size.width/2 - TUTORIAL_WIDTH/2, self.scrollView.frame.origin.y, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.skipBtn setFrame:CGRectMake(self.view.frame.size.width/2 - self.skipBtn.frame.size.width/2, self.view.frame.size.height - 80, self.skipBtn.frame.size.width, self.skipBtn.frame.size.height)];
    [self.pageController setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - 40, self.view.frame.size.width, self.pageController.frame.size.height)];
    
    
    // Update scrollView's contentSize for new width
    [[self scrollView] setContentSize:CGSizeMake(self.view.frame.size.width * NUMBER_OF_PAGES, self.view.frame.size.height)];
    
    // Apply the same page that was displayed before the rotation, if necessary
    if(tutorialPageBeforeRotation != -1)
    {
        // Calculate the new offset
        CGPoint newContentOffset = CGPointMake(tutorialPageBeforeRotation * CGRectGetWidth([[self view] frame]), 0);
        
        // Move to the right page (making sure the value makes sense)
        if(newContentOffset.x >= 0 && newContentOffset.x <= CGRectGetWidth([[self view] frame]) * (NUMBER_OF_PAGES - 1))
            [[self scrollView] setContentOffset:newContentOffset animated:NO];
        
        // Reset the rotation page variable
        tutorialPageBeforeRotation = -1;
    }
    
    // Get existing dimensions of images and view width
    CGFloat viewWidth = [[self view] bounds].size.width;
    CGRect imageTwoFrame = [[self tutorialImageTwo] frame];
    CGRect imageThreeFrame = [[self tutorialImageThree] frame];
    CGRect imageFourFrame = [[self tutorialImageFour] frame];
    
    // Apply horizontal shifts
    imageTwoFrame.origin.x = viewWidth;
    imageThreeFrame.origin.x = viewWidth * 2;
    imageFourFrame.origin.x = viewWidth * 3;
    
    // Finally apply image frames
    [[self tutorialImageTwo] setFrame:imageTwoFrame];
    [[self tutorialImageThree] setFrame:imageThreeFrame];
    [[self tutorialImageFour] setFrame:imageFourFrame];
    
    
}

// Called right before a rotation happens
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Save the current page we are on so we can update the scrollview during the rotation
    tutorialPageBeforeRotation = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width/2)/self.scrollView.frame.size.width)+1;
}

/*-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    NSLog(@"ORIENTATION +++++++ = %d", Orientation);
    
    if(Orientation==UIDeviceOrientationPortrait)
    {
    }
    else if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
     }
    
    NSLog(@"rotating -- view size is: %.1f x %.1f", self.view.bounds.size.width, self.view.bounds.size.height);
    
}*/

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    self.user.showTutorial = false;
    
    [self.skipBtn setHidden:YES];
        
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //set scroll view delegate and content size
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * NUMBER_OF_PAGES, self.view.frame.size.height);
    
    /*
    [self.tutorialImageOne setFrame:CGRectMake(0, 0, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageTwo setFrame:CGRectMake(0, 0, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageThree setFrame:CGRectMake(0, 0, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    [self.tutorialImageFour setFrame:CGRectMake(0, 0, TUTORIAL_WIDTH, TUTORIAL_HEIGHT)];
    */
    
    // Initialize variables
    tutorialPageBeforeRotation = -1;
    
    // Allow the container/main view to resize itself
    // (for some reason this is not possible to set in the storyboard at the moment)
    [[self view] setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //fade in view
    [UIView animateWithDuration:0.25f animations:^{
        
        [self.view setAlpha:1.0f];
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //calculate and set current page
    int currentPage = (int)self.pageController.currentPage;
    self.pageController.currentPage = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width/2)/self.scrollView.frame.size.width)+1;
    
    //if scroll view page changed
    if(currentPage != self.pageController.currentPage){
        
        //if page equal to 3, change skipBtn title to Get Started - otherwise, change it to Skip
        switch (self.pageController.currentPage) {
            case 3:
                [self.skipBtn setTitle:@"ΑΡΧΙΣΕ" forState:UIControlStateNormal];
                [self.skipBtn setHidden:NO];
                break;
                
            default:
                [self.skipBtn setHidden:YES];
                break;
        }
        
    }
    
}

- (IBAction)dismissTutorial:(id)sender {
    
    //dismiss view
    [UIView animateWithDuration:0.25f animations:^{
        
        [self.view setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
