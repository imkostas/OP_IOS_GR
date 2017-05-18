//
//  memeAppDelegate.m
//  OPPannig
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "AppDelegate.h" //

@implementation AppDelegate

- (id)init {
    
    self = [super init];
    
    return self;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //initialize user info object
    self.user = [UserInfo user];
    
    //Localytics
    [Localytics autoIntegrate:@"b23cac18ab2ba517f074fbe-fd5c0d08-1aad-11e5-444c-006918dcf667" launchOptions:launchOptions];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        
       // [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];  //deprication fix

      //  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
     
   /*
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    
        */
    }
 
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.user.username = @"0";
        // This is the first launch ever
    }
    
    //set widow background color to match white coloring on load
    self.window.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    
    //setting object styling
    NSDictionary *attributes =
        [NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], NSForegroundColorAttributeName, nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    //[[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor darkGrayColor]];
    [[UITextField appearance] setTintColor:OP_BLUE_COLOR];
    [[UITextField appearance] setTextColor:[UIColor darkGrayColor]];
    [[UITabBar appearance] setTintColor:[UIColor darkGrayColor]];
    
    //clear application's badges...but should do elsewhere
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    return YES;
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
    
}

#pragma mark Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    //format device token
     NSLog(@"deviceToken: %@", deviceToken);
    NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
    [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    
    //save device token in user info
    self.user.device = tokenString;
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
	NSLog(@"Failed to register for remote notifications: %@", [error description]);
    
    //storing device as nil in user info
    self.user.device = @"";
    
    //notify user they should enable push notifications
    [self customAlert:@"We recommend enabling push notifications. You can do this within Settings" withDone:@"OK"];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
     NSLog(@"didReceiveLocalNotification");
    
    //local notification - testing functionality, might use later
    if(application.applicationState == UIApplicationStateActive){
        
        //indicate push has been received
        [self.user receivedNotification:notification.userInfo withType:[NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"type"]]];
        
    }
   
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
    
    NSLog(@"%@", info);
    NSLog(@"didReceiveRemoteNotification");
    
    //if application is active, show specific alert/message
    if(application.applicationState == UIApplicationStateActive){
        
        //push types
        if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"canceledDeal"]){
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"canceledDeal"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"autoDeletedPost"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"autoDeletedPost"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"finalizedDeal"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"finalizedDeal"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"postRequested"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"postRequested"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"respondedToRequest"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"respondedToRequest"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"missedMessage"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"missedMessage"];
            
        }
        
    }
    
    else if(application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Creating local notification");
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.alertBody = NSLocalizedString([[info objectForKey:@"aps"] valueForKey:@"alert"], nil);
        notification.alertAction = NSLocalizedString(@"Take Action", nil);
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 1;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[[info objectForKey:@"info"] valueForKeyPath:@"type"] forKey:@"type"];
        notification.userInfo = infoDict;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    } else if (application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"App Inactive");
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
//    NSLog(@"applicationWillResignActive");
    
    [application ignoreSnapshotOnNextApplicationLaunch];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    NSLog(@"applicationDidEnterBackground");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    NSLog(@"applicationWillEnterForeground");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
//    NSLog(@"applicationDidBecomeActive");
    //clear application's badges...but should do elsewhere//test IOS
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
//    NSLog(@"applicationWillTerminate");
    
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.window.frame withMessage:alert];
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    self.customAlert.customAlertDelegate = self;
    
    //add as subview and make alpha 1.0
    [self.window addSubview:self.customAlert];
    [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:1.0f];}];
    
}

//custom alert object left button delegate method
- (void)leftActionMethod:(int)method {
    
    //hide custom alert and remove it from its superview
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.customAlert setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.customAlert removeFromSuperview];
        
    }];
    
}

//custom alert object right button delegate method
- (void)rightActionMethod:(int)method {
    
    //nothing for now
    
}



@end
