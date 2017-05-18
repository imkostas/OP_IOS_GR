//
//  SearchCell.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2017 OPA, Inc. All rights reserved.
//

@interface SearchCell : UITableViewCell

//cell for displaying previously searched locations or search results based on search string
@property (strong, nonatomic) IBOutlet UILabel *title; //displays main address
@property (strong, nonatomic) IBOutlet UILabel *subtitle; //displays city, region, country

@end
