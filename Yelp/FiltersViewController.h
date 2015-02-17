//
//  FiltersViewController.h
//  Yelp
//
//  Created by Baeksan Oh on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltersViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *initialFilters;
@end
