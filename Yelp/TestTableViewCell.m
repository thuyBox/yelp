//
//  TestTableViewCell.m
//  Yelp
//
//  Created by Baeksan Oh on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "TestTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.posterView.layer.cornerRadius = 3;
    self.posterView.clipsToBounds = YES;
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
