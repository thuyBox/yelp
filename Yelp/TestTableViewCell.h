//
//  TestTableViewCell.h
//  Yelp
//
//  Created by Baeksan Oh on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *posterView;
@property (strong, nonatomic) IBOutlet UIImageView *ratingView;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;
@property (strong, nonatomic) IBOutlet UILabel *dollarLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@end
