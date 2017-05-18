//
//  todos.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "todos.h"
#import "todoCell.h"

@interface todos () {
    
    int headerHeight;
    
}

@end

@implementation todos

#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                                     self.topBar.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    
    //set table view delegate, data source, and separator style
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //initialize view variables
    headerHeight = 82;
    
    //initialize todo array
    self.todos = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //remove all since one could have been completed
    [self.todos removeAllObjects];
    
    //if user has no car info, insert as todo
    if(!self.user.vehicle.hasVehicle){
        
        [self.todos addObject:@"add_vehicle"];
        
    }
    
    //if user has no payment info, insert as todo
    if(self.user.braintree.paymentMethods.count == 0){
        
        [self.todos addObject:@"add_payment"];
        
    }
    
    //reload table view data
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //if todo array count equals 0, dismiss view controller
    if([self.todos count] == 0){
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)doneWithView:(id)sender {
    
    //dismiss view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Table view data source methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //create custom header
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    [header setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    
    //create divider for bottom of header
    UILabel *divider = [[UILabel alloc] initWithFrame:CGRectMake(header.frame.origin.x, header.frame.size.height - 1, header.frame.size.width, 1)];
    [divider setBackgroundColor:[UIColor colorWithWhite:170/255.0f alpha:1.0f]];
    
    //create header title
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, headerHeight/2 - 15, self.tableView.frame.size.width, 30)];
    [headerTitle setText:@"COMPLETE TO CONTINUE"];
    [headerTitle setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    [headerTitle setTextColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    [headerTitle setTextAlignment:NSTextAlignmentCenter];
    
    //add both the divider and header title to the header view
    [header addSubview:divider];
    [header addSubview:headerTitle];
    
    //return the header
    return header;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //return initialized header height
    return headerHeight;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section needed
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //return the number of todos
    return [self.todos count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //needed height for custom cell
    return 60.0f;
    
}

- (todoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //initialize cell
    static NSString *cellIdentifier = @"todoCell";
    todoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[todoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    //set todo image
    [cell.todoImageView setImage:[UIImage imageNamed:[self.todos objectAtIndex:indexPath.row]]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    //depending on type of todo selected, segue to proper view controller
//    if([[self.todos objectAtIndex:indexPath.row] isEqualToString:@"add_vehicle"]){
//        
//        self.user.todo = 5;
//        todos *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
//        [self presentViewController:viewController animated:YES completion:nil];
//        
//    } else if([[self.todos objectAtIndex:indexPath.row] isEqualToString:@"add_payment"]){
//        
//        self.user.todo = 5;
//        todos *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentNavController"];
//        [self presentViewController:viewController animated:YES completion:nil];
//        
//    }
    
}

@end
