//
//  AmaxLocationListController.m
//  
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmaxLocationListController.h"
#import "AmaxDataProvider.h"
#import "AmaxPrefs.h"

@implementation AmaxLocationListController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Current location", @"Current location");
        self->mDataProvider = [AmaxDataProvider sharedInstance];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    mLocations = getLocations();
    for (id key in mLocations) {
        NSLog(@"Location %@ : %@", key, [mLocations objectForKey:key]);
    }
    mSortedLocationKeys = [mLocations keysSortedByValueUsingSelector:@selector(compare:)];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
}

- (void)viewDidDisappear:(BOOL)animated
{
    mDataProvider.mLocationId = [mSortedLocationKeys objectAtIndex:mCurrentLocationIndex];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mSortedLocationKeys.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [mLocations objectForKey:[mSortedLocationKeys objectAtIndex:indexPath.row]];
    
    NSString *key = [mSortedLocationKeys objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = key;

    if ([mDataProvider.mLocationId isEqualToString:key]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        mCurrentLocationIndex = indexPath.row;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView1 deselectRowAtIndexPath:indexPath animated:NO];
    
    if (mCurrentLocationIndex == indexPath.row)
        return;
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:mCurrentLocationIndex inSection:0];
    
    UITableViewCell *newCell = [tableView1 cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        mCurrentLocationIndex = indexPath.row;
    }
    
    UITableViewCell *oldCell = [tableView1 cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
}
@end
