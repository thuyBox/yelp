//
//  SwitchTableViewCell.h
//  Yelp
//
//  Created by Baeksan Oh on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *filterSwitch;

@end
