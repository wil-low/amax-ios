//
//  AmaxMasterViewController.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxBaseViewController.h"

@class AmaxEventListViewController, AmaxSettingsController, AmaxDateSelectController, AmaxTableCell;

@interface AmaxSummaryViewController : AmaxBaseViewController
{
    NSString *mTitleDate;
    
	// Outlets
	IBOutlet UITableView *_mTableView;
	IBOutlet UIToolbar *_mToolbar;
}

@property (nonatomic, assign) IBOutlet AmaxTableCell *tvCell;

- (void)updateDisplay;

@property (strong, nonatomic) AmaxEventListViewController *eventListViewController;
@property (strong, nonatomic) AmaxSettingsController *settingsController;
@property (strong, nonatomic) AmaxDateSelectController *dateSelectController;

//- (IBAction)goToPreviousDate:(id)sender;
//- (IBAction)goToNextDate:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)goToToday:(id)sender;
- (IBAction)selectDate:(id)sender;

@end
