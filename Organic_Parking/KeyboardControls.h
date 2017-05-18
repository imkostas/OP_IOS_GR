//
//  KeyboardControls.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@protocol KeyboardControlDelegate

//delegate methods
- (void)nextPressed;
- (void)previousPressed;
- (void)donePressed;

@end

@interface KeyboardControls : NSObject

//keyboard control delegate
@property (nonatomic, strong) id <KeyboardControlDelegate> delegate;

//initialization method
- (UIToolbar *)createControls:(BOOL)prev withNext:(BOOL)next withDone:(BOOL)done showNextPrev:(BOOL)showNextPrev;

@end
