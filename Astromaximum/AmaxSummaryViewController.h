//
//  AmaxMasterViewController.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxEventListViewController, AmaxDataProvider, AmaxSettingsController, AmaxDateSelectController, AmaxTableCell;

@interface AmaxSummaryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AmaxDataProvider *mDataProvider;
    NSString *mTitleDate;
    
	// Outlets
	IBOutlet UITableView *_mTableView;
	IBOutlet UIToolbar *_mToolbar;
}

@property (nonatomic, readonly) UITableView* mTableView;
@property (nonatomic, readonly) UIToolbar* mToolbar;
@property (nonatomic, assign) IBOutlet AmaxTableCell *tvCell;

- (void)updateDisplay;

@property (strong, nonatomic) AmaxEventListViewController *eventListViewController;
@property (strong, nonatomic) AmaxSettingsController *settingsController;
@property (strong, nonatomic) AmaxDateSelectController *dateSelectController;

- (IBAction)goToPreviousDate:(id)sender;
- (IBAction)goToNextDate:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)goToToday:(id)sender;
- (IBAction)selectDate:(id)sender;

@end
