//
//  AmaxEventListViewController.m
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxEventListViewController.h"
#import "AmaxSummaryItem.h"
#import "AmaxEvent.h"
#import "AmaxTableCell.h"

@implementation AmaxEventListViewController

@synthesize mTableView = _mTableView;
@synthesize detailItem = _detailItem;
@synthesize tvCell = _tvCell;
@synthesize cellNibName = _cellNibName;

- (void)setDetailItem:(AmaxSummaryItem *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    self.navigationItem.title = NSLocalizedString(@"event_list_title", nil);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AmaxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellNibName];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:_cellNibName owner:self options:nil];
        cell = _tvCell;
        self.tvCell = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell.
    AmaxEvent *event = [_detailItem.mEvents objectAtIndex:indexPath.row];
    AmaxSummaryItem *si = [[AmaxSummaryItem alloc]initWithKey:_detailItem.mKey events:[NSMutableArray arrayWithObject:event]];
    [cell configure:si];
    return cell;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[_detailItem mEvents]count];
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* textId = [NSString stringWithFormat:@"%d", _detailItem.mKey];
    return NSLocalizedStringFromTable(textId, @"EventListTitle", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AmaxEvent *e = [_detailItem.mEvents objectAtIndex:indexPath.row];
    if (e != nil)
        [self showInterpreterForEvent:e];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
