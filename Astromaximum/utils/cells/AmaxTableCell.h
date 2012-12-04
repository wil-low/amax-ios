//
//  AmaxTableCell.h
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AmaxSummaryItem.h"

@interface AmaxTableCell : UITableViewCell
{
    UILabel *eventLabel;
    UILabel *timeLabel;
}
- (void)configure:(AmaxSummaryItem *)si;

@end
