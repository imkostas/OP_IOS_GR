//
//  Chat.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "Chat.h"
#import "UserInfo.h"
#import "ChatCells.h"

@interface Chat () {
    
    NSMutableArray *activeChatRooms; //array of available chatrooms
    NSMutableArray *inactiveChatRooms; //array of old chatroom history
    
    UIRefreshControl *refreshControl; //refresh controll used when updating table view
    
    BOOL currentDealsActive; //used to indicate when viewing available or old chatrooms
    float headerHeight; //table view header height
    
}

@end

@implementation Chat

#define topBarHeight 65.0
#define IMAGE_VIEW_SIZE 50.0
#define CELL_HEIGHT 80.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.topBar.bounds.size.width, topBarHeight)];
    [self.topBarTitle setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.size.height - self.topBarTitle.bounds.size.height, self.view.bounds.size.width, self.topBarTitle.bounds.size.height)];
    [self.cancelViewBtn setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.size.height - self.cancelViewBtn.bounds.size.height, self.cancelViewBtn.bounds.size.width, self.cancelViewBtn.bounds.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x, self.topBar.bounds.origin.y + self.topBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.topBar.bounds.origin.y + self.topBar.bounds.size.height))];
    
    
}

- (void)viewDidLayoutSubviews {
    [self.tableView updateConstraints];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //initialize refresh control, set its target, and add to table view
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getRooms) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //set table view delegate and data source
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView sizeToFit];
    
    //initialize chatroom arrays
    activeChatRooms = [[NSMutableArray alloc] init];
    inactiveChatRooms = [[NSMutableArray alloc] init];
    
    //initialize view variables
    currentDealsActive = true;
    headerHeight = 50.0f;
    
    //fetch user chatrooms
    [self getRooms];
    
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    

    

    
    // Resizes the table cell rows to match the new size.
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.tableView reloadData];
    } completion:nil];
}

- (void)getRooms {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.user.username, @"username", self.user.apiKey, @"api_key", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@getChatRooms", self.user.uri] parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSLog(@"%@", responseObject);
             
             //store chatroom data to respective arrays
             activeChatRooms = [responseObject valueForKeyPath:@"active_rooms"];
             inactiveChatRooms = [responseObject valueForKeyPath:@"inactive_rooms"];
             
             //reload table view data
             [self.tableView reloadData];
             
#if DEBUG
             NSLog(@"bounds = %f frame =%f", self.view.bounds.size.width, self.view.frame.size.width);
#endif
             
             //end refreshing
             [refreshControl endRefreshing];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"%@", operation.responseObject);
             
             if([[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"] &&
                [[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]){
                 
                 [self customAlert:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"message"]
                          withDone:[[operation.responseObject valueForKey:@"alert"] valueForKey:@"leftAction"]];
                 
             } else {
                 
                 [self customAlert:@"Chat is currently unavailable" withDone:@"Ok"];
                 
             }
             
         }];
    
}

- (IBAction)cancelView:(id)sender {
    
    //pops view controller
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)loadCurrentDeals {
    
    //reload table view with current deal chatrooms
    currentDealsActive = true;
    [self.tableView reloadData];
    
}

- (void)loadPreviousDeals {
    
    //load table view with old chatrooms
    currentDealsActive = false;
    [self.tableView reloadData];
    
}

//returns correct chatroom date
- (NSString *)formatDate:(NSString *)chatDate {
    
    //use date formatter to format chat date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:chatDate];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"M/d/yy"];
    
    return [dateFormatter stringFromDate:date];
    
}

#pragma mark - Table view data source methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //create custom header to switch between viewing available and old chatrooms
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, headerHeight)];
    [header setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    
    //button for viewing available chatrooms
    UIButton *currentDealsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, header.bounds.size.width/2, header.bounds.size.height)];
    [currentDealsBtn setTitle:@"Current Deals" forState:UIControlStateNormal];
    [currentDealsBtn addTarget:self action:@selector(loadCurrentDeals) forControlEvents:UIControlEventTouchUpInside];
    
    //button for viewing old chatrooms
    UIButton *previousDealsBtn = [[UIButton alloc] initWithFrame:CGRectMake(header.bounds.size.width/2, 0, header.bounds.size.width/2, header.bounds.size.height)];
    [previousDealsBtn setTitle:@"Previous Deals" forState:UIControlStateNormal];
    [previousDealsBtn addTarget:self action:@selector(loadPreviousDeals) forControlEvents:UIControlEventTouchUpInside];
    
    //change color states of buttons depending on which is active
    if(currentDealsActive){
        
        [currentDealsBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:17.0]];
        [currentDealsBtn setTitleColor:[UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0] forState:UIControlStateNormal];
        [previousDealsBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:17.0]];
        [previousDealsBtn setTitleColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0] forState:UIControlStateNormal];
        
    } else {
        
        [currentDealsBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:17.0]];
        [currentDealsBtn setTitleColor:[UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0] forState:UIControlStateNormal];
        [previousDealsBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:17.0]];
        [previousDealsBtn setTitleColor:[UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0] forState:UIControlStateNormal];
        
    }
    
    //add buttons to header view
    [header addSubview:currentDealsBtn];
    [header addSubview:previousDealsBtn];
    
    //return header view
    return header;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //return set header height
    return headerHeight;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section needed
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //return the count of the active chatroom array
    if(currentDealsActive){
        
        return [activeChatRooms count];
        
    } else {
        
        return [inactiveChatRooms count];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //height needed for custom cell
    return CELL_HEIGHT;
    
}

- (ChatCells *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //initialize cell
    static NSString *cellIdentifier = @"chatroomcell";
    ChatCells *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[ChatCells alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    NSString *originalUsername;
    
    //load chatrooms based on which is active - available or old
    if(currentDealsActive){
        
        if([activeChatRooms count]){
            
            //get original username for use when loading image
            originalUsername = [NSString stringWithFormat:@"%@",
                                [[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"recipient"]];
            
            //set cell title to username and title color to type of chatroom - requester (OP blue) or poster (OP pink)
            cell.title.text = [originalUsername uppercaseString];
            NSString *type = [NSString stringWithFormat:@"%@", [[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"type"]];
            
            if([type isEqualToString:@"0"]){
                
                [cell.title setTextColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
                
            } else {
                
                [cell.title setTextColor:[UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
                
            }
            
            //set cell subtitle to date
            [cell.subTitle setText:[self formatDate:[[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"swap_time"]]];
            
        }
        
    } else {
        
        if([inactiveChatRooms count]){
            
            //get original username for use when loading image
            originalUsername = [NSString stringWithFormat:@"%@",
                                [[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"recipient"]];
            
            //set cell title to username and title color to type of chatroom - requester (OP blue) or poster (OP pink)
            cell.title.text = [originalUsername uppercaseString];
            NSString *type = [NSString stringWithFormat:@"%@", [[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"type"]];
            
            if([type isEqualToString:@"0"]){
                
                [cell.title setTextColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
                
            } else {
                
                [cell.title setTextColor:[UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]];
                
            }
            
            //set cell subtitle to date
            [cell.subTitle setText:[self formatDate:[[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"swap_time"]]];
            
        }
        
    }
    
    //initialze cell's image view
    [cell.imageView setClipsToBounds:YES];
    [cell.imageView.layer setCornerRadius:IMAGE_VIEW_SIZE/2];
    [cell.imageView setImage:[UIImage imageNamed:@"No Profile Image"]];
    
    //if user's image saved in cache, use it - otherwise, fetch using queue
    if([self.user.userImages objectForKey:originalUsername] != nil){
        
        cell.imageView.image = [self.user.userImages objectForKey:originalUsername];
        
    } else {
        
        char const * s = [originalUsername  UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(s, 0);
        
        dispatch_async(queue, ^{
            
            UIImage *img = nil;
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", self.user.img_uri, originalUsername]]];
            img = [[UIImage alloc] initWithData:data];
            
            if(img){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([tableView indexPathForCell:cell].row == indexPath.row &&
                        [tableView indexPathForCell:cell].section == indexPath.section) {
                        
                        [self.user.userImages setObject:img forKey:originalUsername];
                        cell.imageView.image = [self.user.userImages objectForKey:originalUsername];
                        
                    }
                    
                });
                
            }
            
        });
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //get chatroom data before continuing to chatroom
    if(currentDealsActive){
        
        if([activeChatRooms count]){
            
            //get who chatting with, chatrrom type, chatroom ID, chatroom name, and if messages can be sent in chatroom
            self.user.chatCanSendMessage = true;
            [self.user setChatType:(int)[[[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"type"] integerValue]];
            [self.user setChatUsername:[NSString stringWithFormat:@"%@", [[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"recipient"]]];
            [self.user setChatID:(int)[[[activeChatRooms objectAtIndex:indexPath.row] objectForKey:@"post_id"] integerValue]];
            
        }
        
    } else {
        
        if([inactiveChatRooms count]){
            
            //get who chatting with, chatrrom type, chatroom ID, chatroom name, and if messages can be sent in chatroom
            self.user.chatCanSendMessage = false;
            [self.user setChatType:(int)[[[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"type"] integerValue]];
            [self.user setChatUsername:[NSString stringWithFormat:@"%@", [[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"recipient"]]];
            [self.user setChatID:(int)[[[inactiveChatRooms objectAtIndex:indexPath.row] objectForKey:@"post_id"] integerValue]];
            
        }
        
    }
    
    //load chatroom view controller and push
    Chat *chat = [self.storyboard instantiateViewControllerWithIdentifier:@"chat"];
    [self.navigationController pushViewController:chat animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //only allow old chatrooms to be editable
    BOOL editable = false;
    editable = (currentDealsActive) ? false : true;
    
    return editable;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //currently not allowing users to delete old chatroom history
    NSLog(@"Will delete here");
    
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
