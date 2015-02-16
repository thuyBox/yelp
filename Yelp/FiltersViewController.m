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

NSString * const mostPopularRows[] = { @"Hot & New", @"Offering a deal", @"Delivery" };// [NSArray arrayWithObjects:@"", nil];

NSString * const distanceRows[] = {@"Best Match", @"2 blocks", @"6 blocks", @"1 mile", @"5 miles"};

NSString * const sortByRows[] = {@"Best Match", @"Distance", @"Rating", @"Most Reviewed"};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    self.tableView.backgroundColor = self.tableView.sectionIndexColor;
    
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
    
    //self.tableView.estimatedRowHeight = 75;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //[self.tableView layoutMargins];
    //[self.tableView layoutSubviews];
    //self.tableView.editing = YES;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (void) onCancelButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onSearchButtonClicked {

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
    // Return the number of sections.
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
        if ([expandedSections containsIndex:section])
        {
            numRows = 5; // return rows when expanded
        } else {
            numRows = 1;
        }
        break;
    case 3:
        if ([expandedSections containsIndex:section])
        {
            numRows = 4; // return rows when expanded
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

int selectedIndexForDistance = 0;
int selectedIndexForSortBy = 0;

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
    //only care about selection on collapsable sections to handle
    //the collapsing/expanding
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
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
            
            [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
        } else {
            //expand the section as a cell is selected when only one cell is shown
            [tableView insertRowsAtIndexPaths:tmpArray
                            withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //this is the space
    return 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
