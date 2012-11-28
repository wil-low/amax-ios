//
//  AmaxMasterViewController.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxEventListViewController, AmaxDataProvider;

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

- (void)updateDisplay;

@property (strong, nonatomic) AmaxEventListViewController *eventListViewController;

- (IBAction)goToPreviousDate:(id)sender;
- (IBAction)goToNextDate:(id)sender;

@end
