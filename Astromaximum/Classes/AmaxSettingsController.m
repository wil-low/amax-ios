//
//  AmaxSettingsController.m
//  Astromaximum
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSettingsController.h"
#import "AmaxLocationListController.h"
#import "AmaxDataProvider.h"

@implementation AmaxSettingsController
@synthesize pickerView;

@synthesize locationListController = _locationListController;
@synthesize tvCell = _tvCell;

const int CELL_LOCATION_NAME = 0;
const int CELL_IS_CUSTOM_TIME = 1;
const int CELL_HIGHIGHT_TIME = 2;

NSString *AmaxSettingsXibNames[] = {
    @"LocationNameCell",
    @"CustomTimeSwitchCell"
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_mTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = AmaxSettingsXibNames[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    switch ([indexPath row]) {
        case CELL_LOCATION_NAME:
            cell.textLabel.text = NSLocalizedString(@"Current location", @"Current location");
            cell.detailTextLabel.text = [mDataProvider locationName];
            break;
        case CELL_IS_CUSTOM_TIME:
            cell.textLabel.text = NSLocalizedString(@"Highlight time", @"Highlight time");
            cell.detailTextLabel.text = @"88:88";
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView setOn:NO animated:NO];
            [switchView addTarget:self action:@selector(customTimeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == CELL_LOCATION_NAME) {
        if (!self.locationListController) {
            self.locationListController = [[AmaxLocationListController alloc] initWithNibName:@"AmaxLocationListController" bundle:nil];
        }
        [self.navigationController pushViewController:self.locationListController animated:YES];
    }
}

- (IBAction)customTimeSwitchChanged:(id)sender
{
    UITableViewCell *targetCell = [self tableView:_mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CELL_HIGHIGHT_TIME inSection:0]];
    NSLog(@"Switch changed to %@\n", [sender isOn] ? @"YES" : @"NO");
//	self.pickerView.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
	
	// check if our date picker is already on screen
	if (self->pickerView.superview == nil)
	{
		[self.view.window addSubview: self->pickerView];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self->pickerView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self->pickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
		
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
		
        self->pickerView.frame = pickerRect;
		
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = _mTableView.frame;
        newFrame.size.height -= self->pickerView.frame.size.height;
        _mTableView.frame = newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
}
@end
