//
//  FAQs.m
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

#import "FAQs.h"

@interface FAQs () {
    
    int currentExpandedIndex; //stores currently expanded index of table view
    int sectionOfCurrentExpandedIndex; //stores currently expanded section of table view
    
    //arrays for storing all section quesitons and answers
    NSMutableArray *aboutSectionQuestions;
    NSMutableArray *aboutSectionAnswers;
    NSMutableArray *paymentSectionQuestions;
    NSMutableArray *paymentSectionAnswers;
    NSMutableArray *supportSectionQuestions;
    NSMutableArray *supportSectionAnswers;
    
}

@end

@implementation FAQs

#define TOP_BAR_HEIGHT 65.0

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    //position view objects
    [self.topBar setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                                     self.topBar.frame.size.width, TOP_BAR_HEIGHT)];
    [self.topBarTitle setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.topBarTitle.frame.size.height, self.view.frame.size.width, self.topBarTitle.frame.size.height)];
    [self.backBtn setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.size.height - self.backBtn.frame.size.height, self.backBtn.frame.size.width, self.backBtn.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.topBar.frame.origin.y + self.topBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.topBar.frame.origin.y + self.topBar.frame.size.height))];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //set table view delegate, data source, and separator style
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    //initialize view variables
    currentExpandedIndex = -1;
    sectionOfCurrentExpandedIndex = -1;
    
    //initialize arrays
    aboutSectionQuestions = [[NSMutableArray alloc] init];
    aboutSectionAnswers = [[NSMutableArray alloc] init];
    paymentSectionQuestions = [[NSMutableArray alloc] init];
    paymentSectionAnswers = [[NSMutableArray alloc] init];
    supportSectionQuestions = [[NSMutableArray alloc] init];
    supportSectionAnswers = [[NSMutableArray alloc] init];
    
    //load arrays with data
    [self setSectionData];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (IBAction)cancelView:(id)sender {
    
    //dismiss view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - initializing array data

- (void)setSectionData {
    
    //get FAQs data from plist and store into NSDictionary
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"faqs.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    //load each array with proper FAQ data
    for(int i = 0; i < [[plistData objectForKey:@"About"] count]; i++){
        
        [aboutSectionQuestions addObject:[[[plistData objectForKey:@"About"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:0]];
        [aboutSectionAnswers addObject:[[[plistData objectForKey:@"About"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:1]];
        
    }
    for(int i = 0; i < [[plistData objectForKey:@"Payment"] count]; i++){
        
        [paymentSectionQuestions addObject:[[[plistData objectForKey:@"Payment"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:0]];
        [paymentSectionAnswers addObject:[[[plistData objectForKey:@"Payment"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:1]];
        
    }
    for(int i = 0; i < [[plistData objectForKey:@"Support"] count]; i++){
        
        [supportSectionQuestions addObject:[[[plistData objectForKey:@"Support"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:0]];
        [supportSectionAnswers addObject:[[[plistData objectForKey:@"Support"] objectForKey:[NSString stringWithFormat:@"%i", i]] objectAtIndex:1]];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //number of FAQ sections
    return 3;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //section header height
    return 50.0f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //create custom header for each section - header just consists of title for now, it's more about the custimization
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 100)];
    [headerView setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    
    //initilize header label title
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, 50)];
    [sectionTitle setFont:[UIFont fontWithName:@"Avenir-Medium" size:18]];
    [sectionTitle setTextColor:[UIColor whiteColor]];
    [sectionTitle setBackgroundColor:[UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]];
    
    //set proper section title
    switch (section) {
        case 0:
            [sectionTitle setText:@"About"];
            break;
        case 1:
            [sectionTitle setText:@"Payment"];
            break;
        case 2:
            [sectionTitle setText:@"Support"];
            break;
        default:
            break;
    }
    
    //add title to headerView
    [headerView addSubview:sectionTitle];
    
    //return headerView
    return headerView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //calculate number of row in section, which dynamically changes depending on expanded FAQs
    int numOfRows = 0;
    int additionalRow = ((currentExpandedIndex > -1 && sectionOfCurrentExpandedIndex == section) ? 1 : 0);
    
    if(section == 0){
        
        numOfRows = (int)[aboutSectionQuestions count] + additionalRow;
        
    } else if(section == 1) {
        
        numOfRows = (int)[paymentSectionQuestions count] + additionalRow;
        
    } else {
        
        numOfRows = (int)[supportSectionQuestions count] + additionalRow;
        
    }
    
    return numOfRows;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //instance method variables
    NSString *temp;
    CGFloat tempHeight;
    float fontSize;
    float spacing;
    
    //calculate if row is child (is answer to question)
    BOOL isChild = ((currentExpandedIndex > -1) && (indexPath.row == currentExpandedIndex + 1)) && sectionOfCurrentExpandedIndex == indexPath.section;
    
    //if row is child or not, get row text
    if (isChild) {
        
        fontSize = 14.0f;
        spacing = 20.0f;
        
        if(indexPath.section == 0){
            
            temp = [aboutSectionAnswers objectAtIndex:indexPath.row - 1];
            
        } else if(indexPath.section == 1) {
            
            temp = [paymentSectionAnswers objectAtIndex:indexPath.row - 1];
            
        } else {
            
            temp = [supportSectionAnswers objectAtIndex:indexPath.row - 1];
            
        }
        
    } else {
        
        fontSize = 20.0f;
        spacing = 10.0f;
        
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && sectionOfCurrentExpandedIndex == indexPath.section)
        ? (int)indexPath.row - 1
        : (int)indexPath.row;
        
        if(indexPath.section == 0){
            
            temp = [aboutSectionQuestions objectAtIndex:topIndex];
            
        } else if(indexPath.section == 1) {
            
            temp = [paymentSectionQuestions objectAtIndex:topIndex];
            
        } else {
            
            temp = [supportSectionQuestions objectAtIndex:topIndex];
            
        }
        
    }
    
    //calculate size of row text
    tempHeight = [[[NSAttributedString alloc] initWithString:temp attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:fontSize]}] boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    //return height of size plus some spacing
    return tempHeight + spacing;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //initialize cell depending on cell type
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    
    BOOL isChild = ((currentExpandedIndex > -1) && (indexPath.row == currentExpandedIndex + 1)) && sectionOfCurrentExpandedIndex == indexPath.section;
    
    UITableViewCell *cell;
    
    if (isChild) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:ChildCellIdentifier];
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:ParentCellIdentifier];
        
    }
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ParentCellIdentifier];
        
    }
    
    //if child, format for child cell - otherwise, format for parent cell
    if (isChild) {
        
        cell.detailTextLabel.numberOfLines = 0;
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:150/255.0f green:150/255.0f blue:150/255.0f alpha:1.0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if(indexPath.section == 0){
            
            cell.detailTextLabel.text = [aboutSectionAnswers objectAtIndex:indexPath.row - 1];
            
        } else if(indexPath.section == 1) {
            
            cell.detailTextLabel.text = [paymentSectionAnswers objectAtIndex:indexPath.row - 1];
            
        } else {
            
            cell.detailTextLabel.text = [supportSectionAnswers objectAtIndex:indexPath.row - 1];
            
        }
        
    }
    else {
        
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && sectionOfCurrentExpandedIndex == indexPath.section)
        ? (int)indexPath.row - 1
        : (int)indexPath.row;
        
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:19]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.detailTextLabel.text = @"";
        
        if(indexPath.section == 0){
            
            cell.textLabel.text = [aboutSectionQuestions objectAtIndex:topIndex];
            
        } else if(indexPath.section == 1) {
            
            cell.textLabel.text = [paymentSectionQuestions objectAtIndex:topIndex];
            
        } else {
            
            cell.textLabel.text = [supportSectionQuestions objectAtIndex:topIndex];
            
        }
        
    }
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get if child
    BOOL isChild = ((currentExpandedIndex > -1) && (indexPath.row == currentExpandedIndex + 1)) && sectionOfCurrentExpandedIndex == indexPath.section;
    
    //if child, set selected
    if (isChild) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
        [[self.tableView cellForRowAtIndexPath:path] setSelected:YES];
        
        return;
    }
    
    //Reach this point if not a child - begin table view updates
    [self.tableView beginUpdates];
    
    //if currentExpandedIndex selected, collapse it, else, collapse existing and expand new
    if (currentExpandedIndex == indexPath.row && sectionOfCurrentExpandedIndex == indexPath.section) {
        
        //collapse sub items and clear any expanded variable data
        [self collapseSubItems];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        currentExpandedIndex = -1;
        sectionOfCurrentExpandedIndex = -1;
        
    } else {
        
        //check if any index is already epanded
        BOOL shouldCollapse = currentExpandedIndex > -1;
        
        //if index is expanded, collapse it
        if(shouldCollapse)[self collapseSubItems];
        
        //get the row and section of selected index
        currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex && indexPath.section == sectionOfCurrentExpandedIndex) ? (int)indexPath.row - 1: (int)indexPath.row;
        sectionOfCurrentExpandedIndex = (int)indexPath.section;
        
        //expand the selected index
        [self expandItem];
        
    }
    
    [self.tableView endUpdates];
    
}

- (void)expandItem {
    
    //expand item
    NSMutableArray *indexPaths = [NSMutableArray new];
    [indexPaths addObject:[NSIndexPath indexPathForRow:currentExpandedIndex + 1 inSection:sectionOfCurrentExpandedIndex]];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)collapseSubItems {
    
    //collapse sub items
    NSMutableArray *indexPaths = [NSMutableArray new];
    [indexPaths addObject:[NSIndexPath indexPathForRow:currentExpandedIndex + 1 inSection:sectionOfCurrentExpandedIndex]];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:currentExpandedIndex inSection:sectionOfCurrentExpandedIndex];
    [[self.tableView cellForRowAtIndexPath:path] setSelected:NO];
    
}

@end
