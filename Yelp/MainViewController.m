//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "TestTableViewCell.h"
#import "UIImageView+AFNetworkingFadingIn.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *restaurantTableView;
@property (nonatomic, strong) YelpClient *client;
@property NSArray *restaurants;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self.client searchWithTerm:@"Thai" success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"response: %@", response);
            self.restaurants = response[@"businesses"];
            [self.restaurantTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [error description]);
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UISearchBar alloc] init];
    UINib *restaurantCellNib = [UINib nibWithNibName:@"TestTableViewCell" bundle:nil];
    [self.restaurantTableView registerNib:restaurantCellNib forCellReuseIdentifier:@"TestTableViewCell"];
    
    // Set delegate/datasource for tableview
    self.restaurantTableView.delegate = self;
    self.restaurantTableView.dataSource = self;
    self.restaurantTableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *cell = [self.restaurantTableView dequeueReusableCellWithIdentifier:@"TestTableViewCell" forIndexPath:indexPath];
    //cell.frame = CGRectMake(0,0,self.moviesTableView.frame.size.width,cell.frame.size.height);
    
    NSDictionary *restaurant = self.restaurants[indexPath.row];
    NSLog(@"restaurant=%@, address=%@, city=%@", restaurant, restaurant[@"location"][@"address"], restaurant[@"location"][@"city"]);
    cell.nameLabel.text = [NSString stringWithFormat:@"%ld. %@", (long) indexPath.row + 1, restaurant[@"name"]];
    cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", restaurant[@"location"][@"address"][0], restaurant[@"location"][@"city"]];
    cell.reviewLabel.text = [NSString stringWithFormat:@"%@ Reviews", restaurant[@"review_count"] ];
    NSString *posterURLString = restaurant[@"image_url"];//rating_img_url_small
    [cell.posterView setImageWithURL:posterURLString fadingInDuration:0.3];
    NSString *ratingURLString = restaurant[@"rating_img_url_small"];//rating_img_url_small
    [cell.ratingView setImageWithURL:ratingURLString fadingInDuration:0.3];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", [restaurant[@"distance"] floatValue] * 0.000621371];
    cell.dollarLabel.text = @"$$";
    
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    for (NSArray *elem in restaurant[@"categories"]) {
        [categories addObject:elem[0]];
    }
    
    cell.categoryLabel.text = [categories componentsJoinedByString:@", "];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
