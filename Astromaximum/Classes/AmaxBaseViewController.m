//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxBaseViewController.h"
#import "Astromaximum-Swift.h"

@implementation AmaxBaseViewController

- (void)updateDisplay
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (IBAction)goToPreviousDate:(id)sender 
{
    [mDataProvider changeDateWithDeltaDays:-1];
    [self updateDisplay];
}

- (IBAction)goToNextDate:(id)sender
{
    [mDataProvider changeDateWithDeltaDays:1];    
    [self updateDisplay];
}

- (void)showInterpreterForEvent:(AmaxEvent *)e
{
    AmaxInterpretationProvider* iProvider = [AmaxInterpretationProvider sharedInstance];
    NSString* text = [iProvider getTextForEvent:e];
    if (text) {
        if (!interpreterController) {
            interpreterController = [[AmaxInterpreterController alloc] initWithNibName:@"AmaxInterpreterController" bundle:nil];
        }
        interpreterController.interpreterText = text;
        interpreterController.interpreterEvent = e;
        [self.navigationController pushViewController:interpreterController animated:YES];
    }
}

@end
