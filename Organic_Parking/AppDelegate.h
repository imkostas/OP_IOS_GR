//
//  memeAppDelegate.h
//  OPPannig
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>

#import "UserInfo.h"
#import "CustomAlert.h"
#import "KeyboardControls.h"
#import "Localytics.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CustomAlertDelegate>

@property (strong, nonatomic) UIWindow *window; //main window
@property (strong, nonatomic) UserInfo *user; //user info
@property (nonatomic, strong) CustomAlert *customAlert; //custom info

@end
