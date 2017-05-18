//
//  Privacy.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Privacy.h"

@interface Privacy ()

@end

@implementation Privacy

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                                     self.topBar.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    
    [self.webView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.organicparking.com/privacyPolicy.html"]]];
}

- (IBAction)cancelView:(id)sender {
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
