//
//  memeAppDelegate.h
//  OPPannig
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "CustomAlert.h"
#import "KeyboardControls.h"
#import "Localytics.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CustomAlertDelegate>

@property (strong, nonatomic) UIWindow *window; //main window
@property (strong, nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom info

@end
