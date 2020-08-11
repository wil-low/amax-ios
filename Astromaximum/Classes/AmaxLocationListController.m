//
//  AmaxLocationListController.m
//  
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmaxLocationListController.h"
#import "Astromaximum-Swift.h"
#import "AmaxPrefs.h"

@implementation AmaxLocationListController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didSelectLocation:)];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    workingLocationIndex = 0;
    for (long i = 0; i < [mDataProvider.mSortedLocationKeys count]; ++i) {
        if ([mDataProvider.mLocationId isEqualToString:[mDataProvider.mSortedLocationKeys objectAtIndex:i]]) {
            workingLocationIndex = i;
            break;
        }
    }
    NSIndexPath* path = [NSIndexPath indexPathForRow:workingLocationIndex inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    self.navigationItem.rightBarButtonItem.enabled = false;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:workingLocationIndex inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
    selectedLocationIndex = -1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mDataProvider.mSortedLocationKeys.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [mDataProvider.mLocations objectForKey:[mDataProvider.mSortedLocationKeys objectAtIndex:indexPath.row]];
    
    NSString *key = [mDataProvider.mSortedLocationKeys objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = key;

    cell.accessoryType = selectedLocationIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView1 deselectRowAtIndexPath:indexPath animated:NO];
    
    if (selectedLocationIndex == indexPath.row)
        return;
    
    UITableViewCell *newCell = [tableView1 cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedLocationIndex inSection:0];
    UITableViewCell *oldCell = [tableView1 cellForRowAtIndexPath:oldIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;

    //NSLog(@"didSelect new %d, old %d, selected %d, working %d", [indexPath indexAtPosition:1], [oldIndexPath indexAtPosition:1], selectedLocationIndex, workingLocationIndex);
    
    selectedLocationIndex = indexPath.row;
    self.navigationItem.rightBarButtonItem.enabled = selectedLocationIndex != workingLocationIndex;
}

- (IBAction)didSelectLocation:(id)sender
{
    workingLocationIndex = selectedLocationIndex;
    [mDataProvider loadLocationByIdWithLocationId: [mDataProvider.mSortedLocationKeys objectAtIndex:workingLocationIndex]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
