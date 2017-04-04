//
//  ChatCells.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

@interface ChatCells : UITableViewCell

//cell for displaying chat rooms
@property (strong, nonatomic) IBOutlet UIImageView *imageView; //displays chatroom image
@property (strong, nonatomic) IBOutlet UILabel *title; //displays chatroom username
@property (strong, nonatomic) IBOutlet UILabel *subTitle; //displays chatroom date

@end
