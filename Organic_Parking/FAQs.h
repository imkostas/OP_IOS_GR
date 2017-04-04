//
//  FAQs.h
//  oParking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface FAQs : UIViewController <UITableViewDelegate, UITableViewDataSource>

//navigation bar
@property (strong, nonatomic) IBOutlet UIImageView *topBar; //top bar
@property (strong, nonatomic) IBOutlet UILabel *topBarTitle; //top bar title
@property (strong, nonatomic) IBOutlet UIButton *backBtn; //dismisses view

//table view for displaying FAQs
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
