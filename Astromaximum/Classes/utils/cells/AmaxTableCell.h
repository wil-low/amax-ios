//
//  AmaxTableCell.h
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxBaseViewController, AmaxSummaryItem, AmaxEvent;

@interface AmaxTableCell : UITableViewCell
{
    UILabel *eventLabel;
    UILabel *timeLabel;
    AmaxSummaryItem* summaryItem;
}

@property AmaxBaseViewController* controller;

- (void)configure:(AmaxSummaryItem *)si;
- (void)updateInfoButtonWith:(AmaxSummaryItem *)si;
- (void)setColorOf:(UILabel *)label byEventMode:(AmaxEvent *)e;
- (void)calculateActiveEventWithItem:(AmaxSummaryItem *)si customTime:(long)customTime currentTime:(long)currentTime;
@end
