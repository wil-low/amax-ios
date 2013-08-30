//
//  AmaxSettingsController.h
//  Astromaximum
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxLocationListController, AmaxDataProvider;

@interface AmaxSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AmaxDataProvider* mDataProvider;
    IBOutlet UITableView *_mTableView;
}

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (strong, nonatomic) AmaxLocationListController *locationListController;

- (IBAction)customTimeSwitchChanged:(id)sender;
@end
