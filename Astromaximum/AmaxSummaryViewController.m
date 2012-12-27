//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSummaryViewController.h"
#import "AmaxEventListViewController.h"
#import "AmaxEventDetailViewController.h"
#import "AmaxSettingsController.h"
#import "AmaxDateSelectController.h"
#import "AmaxDataProvider.h"
#import "AmaxSummaryItem.h"
#import "AmaxEvent.h"
#import "AmaxTableCell.h"

NSString *xibNames[] = {
    @"MoonSignCell",
    @"MoonMoveCell",
    @"PlanetHourCell",
    @"TithiCell",
    @"SunDegreeCell",
    @"AspectSetCell",
    @"RetrogradeSetCell",
    @"VocCell",
    @"ViaCombustaCell"
};

@implementation AmaxSummaryViewController

@synthesize mToolbar = _mToolbar;
@synthesize mTableView = _mTableView;
@synthesize eventListViewController = _eventListViewController;
@synthesize settingsController = _settingsController;
@synthesize dateSelectController = _dateSelectController;
@synthesize tvCell = _tvCell;

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
    NSString *cellIdentifier = xibNames[indexPath.row];

    AmaxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = _tvCell;
        self.tvCell = nil;
    }
    // Configure the cell.
    AmaxSummaryItem *si = [[mDataProvider mEventCache]objectAtIndex:indexPath.row];
    [cell configure:si];
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
    [self.eventListViewController setCellNibName:xibNames[indexPath.row]];
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

- (IBAction)showSettings:(id)sender {
    if (!self.settingsController) {
        self.settingsController = [[AmaxSettingsController alloc] initWithNibName:@"AmaxSettingsController" bundle:nil];
    }
    [self.navigationController pushViewController:self.settingsController animated:YES];
}

- (IBAction)goToToday:(id)sender {
    [mDataProvider setTodayDate];
    [self updateDisplay];
}

- (IBAction)selectDate:(id)sender {
    if (!self.dateSelectController) {
        self.dateSelectController = [[AmaxDateSelectController alloc] initWithNibName:@"AmaxDateSelectController" bundle:nil];
    }
    self.dateSelectController.datePicker.date = mDataProvider.currentDate;
    [self.navigationController pushViewController:self.dateSelectController animated:YES];
}
@end
