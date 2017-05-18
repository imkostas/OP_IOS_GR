//
//  TermsPrivacy.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "TermsPrivacy.h"

@interface TermsPrivacy ()

@end

@implementation TermsPrivacy

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if(self.user.showTerms){
        
        [self setSelectedIndex:0];
        
    } else {
        
        [self setSelectedIndex:1];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
