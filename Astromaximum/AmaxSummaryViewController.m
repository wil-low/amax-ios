//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSummaryViewController.h"
#import "AmaxEventListViewController.h"
#import "AmaxDataProvider.h"
#import "AmaxSummaryItem.h"
#import "AmaxEvent.h"

@implementation AmaxSummaryViewController

@synthesize mToolbar = _mToolbar;
@synthesize mTableView = _mTableView;
@synthesize eventListViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Summary", @"Summary");
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mDataProvider mEventCache] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    AmaxSummaryItem *si = [[mDataProvider mEventCache]objectAtIndex:[indexPath row]];
    if ([[si mEvents]count] > 0)
        cell.textLabel.text = [[[si mEvents]objectAtIndex:0] description];
    else
        cell.textLabel.text = [NSString stringWithUTF8String:EVENT_TYPE_STR[[si mKey]]];
    return cell;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    mTitleDate = [mDataProvider currentDateString];
    return [NSString stringWithFormat:@"%@: %@ %@",
                     [mDataProvider locationName], 
                     mTitleDate, 
                     [mDataProvider getHighlightTimeString]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.eventListViewController) {
        self.eventListViewController = [[AmaxEventListViewController alloc] initWithNibName:@"AmaxEventListViewController" bundle:nil];
    }
    AmaxSummaryItem *si = [[mDataProvider mEventCache]objectAtIndex:[indexPath row]];
    [self.eventListViewController setDetailItem:si];
    [self.navigationController pushViewController:self.eventListViewController animated:YES];
}

- (void)updateDisplay
{
    mDataProvider = [AmaxDataProvider sharedInstance];
    [mDataProvider prepareCalculation];
    [mDataProvider calculateAll];
    [_mTableView reloadData];
}

- (IBAction)goToPreviousDate:(id)sender 
{
    [mDataProvider changeDate:-1];
    [self updateDisplay];
}

- (IBAction)goToNextDate:(id)sender
{
    [mDataProvider changeDate:1];    
    [self updateDisplay];
}
@end
