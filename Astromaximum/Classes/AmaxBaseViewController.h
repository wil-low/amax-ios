//
//  AmaxBaseViewController.h
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AmaxDataProvider, AmaxEvent, AmaxInterpreterController;

@interface AmaxBaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AmaxDataProvider *mDataProvider;
    AmaxInterpreterController *interpreterController;
}

- (void)showInterpreterForEvent:(AmaxEvent *)e;

- (void)updateDisplay;
- (IBAction)goToPreviousDate:(id)sender;
- (IBAction)goToNextDate:(id)sender;
@end
