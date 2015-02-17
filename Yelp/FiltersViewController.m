//
//  FiltersViewController.m
//  Yelp
//
//  Created by Baeksan Oh on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "PriceTableViewCell.h"
#import "OpenNowTableViewCell.h"
#import "SwitchTableViewCell.h"
#import "DTCustomColoredAccessory.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FiltersViewController
NSMutableIndexSet *expandedSections;

int selectedIndexForDistance = 0;
int selectedIndexForSortBy = 0;

NSString * const mostPopularRows[] = { @"Hot & New", @"Offering a deal", @"Delivery" };

NSString * const distanceRows[] = {@"Best Match", @"2 blocks", @"6 blocks", @"1 mile", @"5 miles"};

#define MetersPerBlock 274
#define MetersPerMile 1609.34
float const distanceInMeters[] = {MetersPerBlock*2, MetersPerBlock*6, MetersPerMile, MetersPerMile * 5};

NSString * const sortByRows[] = {@"Best Match", @"Distance", @"Rating"};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    self.tableView.backgroundColor = self.tableView.separatorColor;
    self.tableView.SeparatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView.hidden = YES;
    self.tableView.tableFooterView.hidden = YES;
    
    self.title = @"Filters";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonClicked)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UINib *switchTableViewCellNib = [UINib nibWithNibName:@"SwitchTableViewCell" bundle:nil];
    [self.tableView registerNib:switchTableViewCellNib forCellReuseIdentifier:@"SwitchTableViewCell"];
    
    UINib *openNowTableViewCellNib = [UINib nibWithNibName:@"OpenNowTableViewCell" bundle:nil];
    [self.tableView registerNib:openNowTableViewCellNib forCellReuseIdentifier:@"OpenNowTableViewCell"];
    
    UINib *priceTableViewCellNib = [UINib nibWithNibName:@"PriceTableViewCell" bundle:nil];
    [self.tableView registerNib:priceTableViewCellNib forCellReuseIdentifier:@"PriceTableViewCell"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //TODO: setup filters based on initialFilters
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.alpha = 1;
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    header.contentView.backgroundColor = tableView.separatorColor;
}

- (void) onCancelButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onSearchButtonClicked {
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    if (selectedIndexForDistance) {
        [paramsDict setObject:[NSString stringWithFormat:@"%f", distanceInMeters[selectedIndexForDistance]] forKey:@"radius_filter"];
    }
    [paramsDict setObject:[NSString stringWithFormat:@"%d",selectedIndexForSortBy] forKey:@"sort"];
    
    [self onCancelButtonClicked];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FiltersUpdatedNotification" object:self userInfo:paramsDict];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Price";
            break;
        case 1:
            sectionName = @"Most Popular";
            break;
        case 2:
            sectionName = @"Distance";
            break;
        case 3:
            sectionName = @"Sort by";
    }
    return sectionName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numRows = 0;
    
    switch (section) {
    case 0:
        numRows = 1;
        break;
    case 1:
        numRows = 4;
        break;
    case 2:
        if ([expandedSections containsIndex:section]) {
            numRows = 5; // return rows when expanded
        } else {
            numRows = 1;
        }
        break;
    case 3:
        if ([expandedSections containsIndex:section]) {
            numRows = 3; // return rows when expanded
        } else {
            numRows = 1;
        }
        break;
    }
    return numRows;
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section == 2 || section == 3) return YES;
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"PriceTableViewCell" forIndexPath:indexPath];
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"OpenNowTableViewCell" forIndexPath:indexPath];
        } else {
            SwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchTableViewCell" forIndexPath:indexPath];
            NSLog(@"label name for section1, row %ld=%@",(long)indexPath.row, mostPopularRows[indexPath.row-1]);
            cell.nameLabel.text = mostPopularRows[indexPath.row-1];
            return cell;
        }
    }
    
    static NSString *cellIdentifier = @"Cell";
    if (indexPath.section == 2 || indexPath.section == 3) {
        UITableViewCell *cell =  [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"System-Bold" size:15];
        
        if ([expandedSections containsIndex:indexPath.section]) {
            //this section has been expanded
            //each row shows its corresponding label
            if (indexPath.section == 2) {
                cell.textLabel.text = distanceRows[indexPath.row];
            } else {
                cell.textLabel.text = sortByRows[indexPath.row];
            }
            cell.accessoryView = nil;
            if (indexPath.section ==2) {
                if (indexPath.row == selectedIndexForDistance) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                if (indexPath.row == selectedIndexForSortBy) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else {
            //this section is currently collapsed
            if (indexPath.section == 2) {
                cell.textLabel.text = distanceRows[selectedIndexForDistance];
            } else {
                cell.textLabel.text = sortByRows[selectedIndexForSortBy];
            }
            
            cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeDown];
        }
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //only care about selection on collapsable sections to handle
    //the collapsing/expanding
    if ([self tableView:tableView canCollapseSection:indexPath.section]) {
        NSInteger section = indexPath.section;
        BOOL currentlyExpanded = [expandedSections containsIndex:section];
        NSInteger rows;
        NSMutableArray *tmpArray = [NSMutableArray array];
        
        //keep tracks of rows to delete/add from/to tables
        //if selecting a section which has been expanded,
        //remove this section from the list of expandedSections
        //and vice versa
        if (currentlyExpanded) {
            rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSections removeIndex:section];
        } else {
            [expandedSections addIndex:section];
            rows = [self tableView:tableView numberOfRowsInSection:section];
        }
        
        for (int i=1; i<rows; i++) {
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                            inSection:section];
            [tmpArray addObject:tmpIndexPath];
        }
        
        if (currentlyExpanded) {
            //collapse the section as a cell is selected when all cells are collapsed
            if (indexPath.section == 2) {
                selectedIndexForDistance = (int) indexPath.row;
            } else {
                selectedIndexForSortBy = (int) indexPath.row;
            }
        }
        
        long numberOfSections = [self numberOfSectionsInTableView:tableView];
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(section, numberOfSections-section)] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 5, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            //this row is both last and first row
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            //first row
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            //last row
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor whiteColor].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (3.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = tableView.separatorColor;
        //cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = testView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
