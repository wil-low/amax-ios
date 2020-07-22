//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxViaCombustaCell.h"

@implementation AmaxViaCombustaCell

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [timeLabel setText:[e normalizedRangeString]];
    }
    [self updateInfoButtonWith:si];
}

@end
