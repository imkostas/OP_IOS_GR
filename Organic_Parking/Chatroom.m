//
//  Chatroom.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "Chatroom.h"
#import "UserInfo.h"
#import "AudioToolbox/AudioToolbox.h"

@interface Chatroom () {
    
    NSMutableArray *messages; //mutable array to store chat messages
    UIImage *image; //recipient's image
    NSTimer *timer; //timer to fetch messages
    int lastID; //value to only get new messages
    int prevMessageCount; //value to see if new messages found
    BOOL gettingMessages; //indicates when fetching messages
    
}

@end

@implementation Chatroom

//Definitions
#define fontMessageSize 18
#define timestampSize 11
#define userPicSize 45
#define rowBuffer 25
#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                     self.topBar.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.bounds.size.width/2 - self.topBarTitle.frame.size.width/2, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.topBarTitle.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.cancelViewBtn setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.size.height - self.cancelViewBtn.frame.size.height, self.cancelViewBtn.frame.size.width, self.cancelViewBtn.frame.size.height)];
    
    if(self.user.chatCanSendMessage){
        
        [self.messageView setFrame:CGRectMake(0, self.view.bounds.size.height - self.messageView.frame.size.height, self.view.bounds.size.width, self.messageView.frame.size.height)];
        [self.divider setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        [self.sendMessageBtn setFrame:CGRectMake(self.view.bounds.size.width - self.sendMessageBtn.frame.size.width, 0, self.sendMessageBtn.frame.size.width, self.messageView.frame.size.height)];
        [self.messageTextfield setFrame:CGRectMake(0, 0, self.sendMessageBtn.frame.origin.x, self.messageView.frame.size.height)];
        
        UIView *spacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.messageView.frame.size.height)];
        [self.messageTextfield setLeftViewMode:UITextFieldViewModeAlways];
        [self.messageTextfield setLeftView:spacer];
        
        [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.topBar.frame.size.height - self.messageView.frame.size.height)];
        
    } else {
        
        [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.topBar.frame.size.height)];
        [self.messageView setHidden:YES];
        
    }
    
    [self.tableView setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];

    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initializing table view delegate, data source, and separator style
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //initialize view objects
    [self.topBarTitle setText:[self.user.chatUsername uppercaseString]];
    
    if(![self.user.userImages objectForKey:self.user.chatUsername]){
        
        image = [UIImage imageNamed:@"No Profile Image"];
        
    } else {
        
        image = [self.user.userImages objectForKey:self.user.chatUsername];
        
    }
    
    //adding callback method to textfield to check when editing changes
    [self.messageTextfield addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    //keyboard callbacks
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    //tap gesture recognizer added to tableview to dismiss keyboard
    UITapGestureRecognizer *tappedView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView:)];
    [self.tableView addGestureRecognizer:tappedView];
    
    //initialize view variables
    lastID = 0;
    prevMessageCount = 0;
    gettingMessages = NO;
    self.currentlySendingMessage = NO;
    
    //initializing messages array
    messages = [[NSMutableArray alloc] init];
    
    //fetch chatroom messages
    [self getMessages];
    
    //initialize timer if a current deal chatroom since old chatrooms won't have new incomming messages
    if(self.user.chatCanSendMessage){
        
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getMessages) userInfo:nil repeats:YES];
        
    }
    
}

- (void)viewDidLayoutSubviews {
    [self.tableView updateConstraints];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}


- (void)textFieldDidChange {
    
    //if length is 0 user can't send message, else use can send message
    if(self.messageTextfield.text.length == 0){
        
        [self.sendMessageBtn setEnabled:NO];
        
    } else {
        
        [self.sendMessageBtn setEnabled:YES];
        
    }
    
}

- (void)didTapTableView:(UIGestureRecognizer*)recognizer {
    
    //hide keyboard if active
    [self.messageTextfield resignFirstResponder];
    
}

- (void)keyboardFrameChanged:(NSNotification*)notification {
    
    //show keyboard
    [self scrollViewForKeyboard:notification up:YES];
    
}

- (void)liftViewWhenKeybordAppears:(NSNotification*)notification {
    
    //show keyboard
    [self scrollViewForKeyboard:notification up:YES];
    
}

- (void)returnViewToInitialPosition:(NSNotification*)notification {
    
    //keyboard will hide
    [self scrollViewForKeyboard:notification up:NO];
    
}

- (void)scrollViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    
    NSDictionary* userInfo = [notification userInfo];
    
    //get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    //start of animations
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    // When the iPad is rotated, the keyboard's frame is still given as if it were in portrait mode,
    // so the "height" given is actually the keyboard's width, etc.etc...
    // We use -convertRect: here to find out really where the keyboard is, from the perspective
    // of this ViewController's view
    CGRect correctKeyboardFrame = [[self view] convertRect:keyboardFrame fromView:nil];
    
    //change messageView y position based on keyboard status
    [self.messageView setFrame:CGRectMake(self.messageView.frame.origin.x,
        (self.view.bounds.size.height - self.messageView.frame.size.height) - (correctKeyboardFrame.size.height * (up?1:0)),
        self.messageView.frame.size.width, self.messageView.frame.size.height)];
    
    //change tableView content inset based on keyboard status
    [self.tableView setContentInset:UIEdgeInsetsMake(10, 0, (correctKeyboardFrame.size.height * (up?1:0)), 0)];
    
    [UIView commitAnimations];
    
    //if messages exist in tableView, scroll to bottom
    if(up && [messages count] != 0){
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    
}

- (IBAction)cancelView:(id)sender {
    
    //remove observers from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //kill timer
    [timer invalidate];
    timer = nil;
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section needed
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section {
    
    //number of rows equals the number of messages
    return [messages count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    //get message details for indexPath
    static NSDictionary *item = nil;
    item = [messages objectAtIndex:indexPath.row];
    
    //find size of message text and timestamp
    CGFloat messageHeight = [[[NSAttributedString alloc] initWithString:[item objectForKey:@"text"] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:fontMessageSize]}] boundingRectWithSize:CGSizeMake(220.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    CGFloat timestampHeight = [[[NSAttributedString alloc] initWithString:[item objectForKey:@"time_sent"] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:timestampSize]}] boundingRectWithSize:CGSizeMake(220.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    
    
    //return height of both plus a buffer
    return MAX(68, messageHeight + timestampHeight + rowBuffer);
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    //declare and initialize cell objects
    NSString *cellIdentifier = @"cell";
    NSDictionary *item = nil;
    item = [messages objectAtIndex:indexPath.row];
    UIImageView *balloonView;
    UIImageView *userCarImage;
    UIImageView *tik;
	UILabel *label;
    UILabel *timestamp;
    UIImage *balloon;
    UIImage *userImage;
    UIImage *tikImage;
	
    //setup cell or reuse
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		message.tag = 0;
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = 1;
		
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.tag = 2;
		label.numberOfLines = 0;
		label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentLeft;
		label.font = [UIFont fontWithName:@"Avenir-Light" size:fontMessageSize];
        label.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        
        timestamp = [[UILabel alloc] initWithFrame:CGRectZero];
		timestamp.backgroundColor = [UIColor clearColor];
		timestamp.tag = 3;
		timestamp.numberOfLines = 0;
		timestamp.lineBreakMode = NSLineBreakByWordWrapping;
		timestamp.font = [UIFont fontWithName:@"Avenir-Light" size:timestampSize];
        timestamp.textColor = [UIColor colorWithRed:130/255.0f green:130/255.0f blue:130/255.0f alpha:1.0f];
        
        userCarImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        userCarImage.tag = 4;
        
        tik = [[UIImageView alloc] initWithFrame:CGRectZero];
        tik.tag = 5;
        
		[message addSubview:balloonView];
		[message addSubview:label];
        [message addSubview:timestamp];
        [message addSubview:userCarImage];
        [message addSubview:tik];
		[cell.contentView addSubview:message];
        
	} else {
        
        //get existing cell objects using tag
		balloonView = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		label = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        timestamp = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        userCarImage = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:4];
        tik = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:5];
        
	}
    
    //have to convert UTC timestamp into user's local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:[item objectForKey:@"time_sent"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"h:mm"];
    NSString *messagehmm = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"a"];
    NSString *messageAMPM = [dateFormatter stringFromDate:date];
    NSString *formattedTime = [NSString stringWithFormat:@"%@ %@", messagehmm, messageAMPM];
    
    //get size of message text
    CGSize size = [[[NSAttributedString alloc] initWithString:[item objectForKey:@"text"] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:fontMessageSize]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    //get timestamp size
    CGSize timeSize = [[[NSAttributedString alloc] initWithString:formattedTime attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:timestampSize]}] boundingRectWithSize:CGSizeMake(220.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
	
    //if message sender username is the same as current user's username, create grey bubble, else create red/blue bubble
	if([[item objectForKey:@"sender"] isEqualToString:self.user.username]) {
        
		balloonView.frame = CGRectMake(self.view.bounds.size.width - size.width - 30, 0.0f, size.width + 20.0f, MAX(userPicSize, size.height + 20.0f));
        balloon = [[UIImage imageNamed:@"Gray Bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f) resizingMode:UIImageResizingModeStretch];
        tik.frame = CGRectMake(balloonView.frame.origin.x + balloonView.frame.size.width, balloonView.frame.origin.y + balloonView.frame.size.height/2 - 5.5, 6, 11);
        tikImage = [UIImage imageNamed:@"Gray Pointer"];
		label.frame = CGRectMake(balloonView.frame.origin.x + balloonView.frame.size.width/2 - size.width/2, balloonView.frame.origin.y + balloonView.frame.size.height/2 - size.height/2, size.width + 4, size.height);
        timestamp.frame = CGRectMake(balloonView.frame.origin.x + balloonView.frame.size.width - timeSize.width, balloonView.frame.size.height + 2, timeSize.width, timeSize.height);
        userImage = nil;
        
	} else {
        
		balloonView.frame = CGRectMake(userPicSize + 18, 0.0f, size.width + 20, MAX(userPicSize, size.height + 20.0f));
        userCarImage.frame = CGRectMake(6, balloonView.frame.origin.y + balloonView.frame.size.height/2 - userPicSize/2, userPicSize, userPicSize);
        tik.frame = CGRectMake(balloonView.frame.origin.x - 6, balloonView.frame.origin.y + balloonView.frame.size.height/2 - 5.5, 6, 11);
        
        if(!self.user.chatType){
            
            balloon = [[UIImage imageNamed:@"Blue Bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f) resizingMode:UIImageResizingModeStretch];
            tikImage = [UIImage imageNamed:@"Blue Pointer"];
            
        } else {
            
            balloon = [[UIImage imageNamed:@"Pink Bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f) resizingMode:UIImageResizingModeStretch];
            tikImage = [UIImage imageNamed:@"Pink Pointer"];
            
        }
        
		userImage = image;
		label.frame = CGRectMake(balloonView.frame.origin.x + balloonView.frame.size.width/2 - size.width/2, balloonView.frame.origin.y + balloonView.frame.size.height/2 - size.height/2, size.width, size.height);
        timestamp.frame = CGRectMake(balloonView.frame.origin.x, balloonView.frame.size.height + 2, timeSize.width, timeSize.height);
        
	}
	
    //set message values to respective messages objects
    [balloonView setImage:balloon];
    [tik setImage:tikImage];
	label.text = [item objectForKey:@"text"];
    timestamp.text = formattedTime;
    [userCarImage setImage:userImage];
    
    //make sure user image is formatted properly
    if(userImage != nil){
        
        [userCarImage setContentMode:UIViewContentModeScaleAspectFill];
        [userCarImage setClipsToBounds:YES];
        [userCarImage.layer setCornerRadius:userPicSize/2];
        
    }
    
    return cell;
    
}

- (IBAction)sendMessage:(id)sender {
    
    //if not fetching messages and message text not empty, send message
    if(!self.currentlySendingMessage && ![self.messageTextfield.text isEqualToString:@""]){
        
        //indicate message sending in progress
        self.currentlySendingMessage = true;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", self.user.chatID], @"post_id", self.user.username, @"sender",
                                self.user.chatUsername, @"recipient", self.messageTextfield.text, @"message",
                                [NSString stringWithFormat:@"%f", self.user.userLocation.latitude], @"latitude",
                                [NSString stringWithFormat:@"%f", self.user.userLocation.longitude], @"longitude",
                                self.user.apiKey, @"api_key", nil];
        
        AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@sendMesage", self.user.uri] parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSLog(@"%@", responseObject);
                  
                  //stop network activity indicator
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  
                  //clear message text
                  [self.messageTextfield setText:@""];
                  
                  //get new messages
                  if(!gettingMessages)[self getMessages];
                  
                  //restart timer
                  [timer invalidate];
                  timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(getMessages) userInfo:nil repeats:YES];
                  
                  //indicate no longer sending message
                  self.currentlySendingMessage = false;
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  NSLog(@"%@", operation.responseObject);
                  
                  //stop network activity indicator
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  
                  //indicate no longer sending message
                  self.currentlySendingMessage = false;
                  
                  [self.messageTextfield resignFirstResponder];
                  
                  if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                     [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                      
                      [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                               withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                      
                  } else {
                      
                      [self customAlert:@"We were unable to send your message" withDone:@"OK"];
                      
                  }
                  
              }];
        
    }
    
}

- (void)getMessages {
    
    //if not already getting messages, proceed
    if(!gettingMessages){
        
        //indicate getting messages
        gettingMessages = true;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", lastID], @"last",
                                [NSString stringWithFormat:@"%i", self.user.chatID], @"post_id",
                                [NSString stringWithFormat:@"%@", self.user.username], @"recipient",
                                self.user.apiKey, @"api_key", nil];
        
        NSString *request = (self.user.chatCanSendMessage) ? @"getMessages" : @"getArchivedMessages" ;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@%@", self.user.uri, request] parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 NSLog(@"%@", responseObject);
                 
                 //store messages
                 NSArray *chatMessages = [responseObject valueForKeyPath:@"messages"];
                 
                 //save existing message count
                 prevMessageCount = (int)[messages count];
                 
                 //add new messages to message array
                 for(NSDictionary *item in chatMessages) {
                     
                     lastID = (int)[[item objectForKey:@"id"] integerValue];
                     [messages addObject:item];
                     
                 }
                 
                 //if existing messages not equal to new message count, reload data and scroll to bottom
                 if([messages count] > 0 && prevMessageCount != [messages count]){
                     
                     [self.tableView reloadData];
                     
                     if(prevMessageCount != 0){
                         
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                         
                     } else {
                         
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                         
                     }
                     
                 }
                 
                 //indicate no longer fetching messages
                 gettingMessages = false;
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 NSLog(@"%@", operation.responseObject);
                 
                 //indicate no longer fetching messages
                 gettingMessages = false;
                 
//                 if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
//                    [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
//                     
//                     [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
//                              withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
//                     
//                 } else {
//                     
//                     [self customAlert:@"Chat is currently unavailable" withDone:@"OK"];
//                     
//                 }
                 
             }];
        
    } else {
        
        NSLog(@"Already getting chat messages...network might be slow");
        
    }
}

//method for creating and presenting a custom alert object
- (void)customAlert:(NSString *)alert withDone:(NSString *)done {
    
    //if alert already showing, hide it
    if(self.customAlert){
        
        //set custom alert alpha to 0
        [UIView animateWithDuration:0.25 animations:^{[self.customAlert setAlpha:0.0f];}];
        
    }
    
    //initialize custom alert object
    self.customAlert = [[CustomAlert alloc] initWithType:1 withframe:self.view.frame withMessage:alert];
    [self.customAlert.leftButton setTitle:done forState:UIControlStateNormal];
    self.customAlert.customAlertDelegate = self;
    
    //add as subview and make alpha 1.0
    [self.view addSubview:self.customAlert];
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
