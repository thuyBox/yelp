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
#import "UIScrollView+SVPullToRefresh.h"
#import "SVPullToRefresh.h"
#import <MapKit/MapKit.h>
#import "MyLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "FiltersViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *restaurantTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) YelpClient *client;
@property NSMutableArray *restaurants;
@property UISearchBar *searchBar;
@property CLGeocoder *geocoder;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.restaurants = [NSMutableArray array];
    
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self.client searchWithTerm:@"Thai" offset:0 success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"response: %@", response);
            [self.restaurants addObjectsFromArray:response[@"businesses"]];
            [self.restaurantTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [error description]);
        }];
    }
    return self;
}

- (void) setupTableView {
    UINib *restaurantCellNib = [UINib nibWithNibName:@"TestTableViewCell" bundle:nil];
    [self.restaurantTableView registerNib:restaurantCellNib forCellReuseIdentifier:@"TestTableViewCell"];
    
    // Set delegate/datasource for tableview
    self.restaurantTableView.delegate = self;
    self.restaurantTableView.dataSource = self;
    self.restaurantTableView.estimatedRowHeight = 106;
    self.restaurantTableView.rowHeight = UITableViewAutomaticDimension;
    
    __weak MainViewController *weakSelf = self;
    [self.restaurantTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.client searchWithTerm:@"Thai" offset:weakSelf.restaurants.count success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"response: %@", response);
            
            NSArray *dataToAdd = response[@"businesses"];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            NSInteger currentCount = weakSelf.restaurants.count;
            for (int i = 0; i < dataToAdd.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
            }
            
            // do the insertion
            [weakSelf.restaurants addObjectsFromArray:dataToAdd];
            
            // tell the table view to update (at all of the inserted index paths)
            [weakSelf.restaurantTableView beginUpdates];
            [weakSelf.restaurantTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.restaurantTableView endUpdates];
            [weakSelf.restaurantTableView.infiniteScrollingView stopAnimating];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [error description]);
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchBar];
    [self setupTableView];
    [self setupMap];
}

- (void) setupSearchBar {
    UIBarButtonItem *filtersButton = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(onFiltersButtonClicked)];
    self.navigationItem.leftBarButtonItem = filtersButton;
    
    UIBarButtonItem *listOrMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onListOrMapButtonClicked)];
    self.navigationItem.rightBarButtonItem = listOrMapButton;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.navigationItem.titleView = self.searchBar;
    //self.searchBar.delegate = self;
}

- (void) onFiltersButtonClicked {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void) onListOrMapButtonClicked {
    if ([self.navigationItem.rightBarButtonItem.title isEqual: @"Map"]) {
        self.navigationItem.rightBarButtonItem.title = @"List";
        self.restaurantTableView.hidden = YES;
        self.mapView.hidden = NO;
        NSLog(@"number of mapView annotation %ld", (long)self.mapView.annotations.count);
        if (self.mapView.annotations.count < self.restaurants.count) {
            NSArray *restaurantsToAdd = [self.restaurants subarrayWithRange:NSMakeRange(self.mapView.annotations.count, 20)];
            NSLog(@"number of restaurants to add %ld", (long)restaurantsToAdd.count);
            [self addAnotations:restaurantsToAdd];
        }
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Map";
        self.mapView.hidden = YES;
        self.restaurantTableView.hidden = NO;
    }
}

//#define METERS_PER_MILE 1609.344
- (void) setupMap {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.geocoder = [[CLGeocoder alloc] init];
    
    self.mapView.delegate = self;
    [self setMapRegionWithLatitude:37.774866 longitude:-122.394556];
}

- (void) setMapRegionWithLatitude:(float) latitude longitude:(float) longitude {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude= longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7000, 7000);
    [self.mapView setRegion:viewRegion animated:YES];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"locations: %@", [locations lastObject]);
}

- (void) addAnotations:(NSArray *)restaurantsToAdd {
    for (NSDictionary *restaurant in restaurantsToAdd) {
        NSLog(@"latitude=%@, longitude=%@", restaurant[@"location"][@"coordinate"][@"latitude"], restaurant[@"location"][@"coordinate"][@"longitude"]);
        NSNumber * latitude = [NSNumber numberWithFloat:[restaurant[@"location"][@"coordinate"][@"latitude"] floatValue]];
        NSNumber * longitude = [NSNumber numberWithFloat:[restaurant[@"location"][@"coordinate"][@"longitude"] floatValue]];
        
        //NSString *name = restaurant[@"name"];
        //NSString * reviews = [NSString stringWithFormat:@"%@ Reviews", restaurant[@"review_count"] ];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        [self.mapView addAnnotation:annotation];
        
        /*NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@", restaurant[@"location"][@"address"][0], restaurant[@"location"][@"city"], restaurant[@"location"][@"state_code"], restaurant[@"location"][@"postal_code"]];
        
        NSLog(@"getting coord for address %@", address);
        [self.geocoder geocodeAddressString:address
                          completionHandler:^(NSArray* placemarks, NSError* error){
                              // for (CLPlacemark* aPlacemark in placemarks)
                              //{
                              CLPlacemark *placemark = [placemarks objectAtIndex:0];
                              CLLocation *location = placemark.location;
                              CLLocationCoordinate2D coordinate = location.coordinate;
                              // Process the placemark.
                              //}
                              
                              MyLocation *annotation = [[MyLocation alloc] initWithName:name address:address coordinate:coordinate] ;
                              [self.mapView addAnnotation:annotation];
                          }];*/
    }
    //[self.mapView showAnnotations:self.mapView.annotations animated:YES];
}


# pragma mark MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MKPinAnnotationView";
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //annotationView.pinColor=MKPinAnnotationColorPurple;

            /*annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;*/
            //annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *cell = [self.restaurantTableView dequeueReusableCellWithIdentifier:@"TestTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *restaurant = self.restaurants[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"%ld. %@", (long) indexPath.row + 1, restaurant[@"name"]];
    cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", restaurant[@"location"][@"address"][0], restaurant[@"location"][@"neighborhoods"][0]];
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
