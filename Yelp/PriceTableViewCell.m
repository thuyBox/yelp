//
//  PriceTableViewCell.m
//  Yelp
//
//  Created by Baeksan Oh on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "PriceTableViewCell.h"

@implementation PriceTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*- (void)setFrame:(CGRect)frame {
    frame.origin.x += 2;
    frame.size.width -= 2 * 2;
    [super setFrame:frame];
}*/

@end
