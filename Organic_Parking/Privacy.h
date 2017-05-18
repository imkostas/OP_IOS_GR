//
//  Privacy.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Definitions.h"

@interface Privacy : UIViewController

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //view title
@property (strong, nonatomic) IBOutlet UIButton *backBtn; //dismisses view

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
