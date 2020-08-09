//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxTithiCell.h"
#import "Astromaximum-Swift.h"

@implementation AmaxTithiCell

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [timeLabel setText:[e normalizedRangeString]];
        [eventLabel setText:[NSString stringWithFormat:@"%@ %d",
                             NSLocalizedString(@"tithi", @"Tithi"),
                             [e getDegree]]];
		[self setColorOf:eventLabel byEventMode:e];
    }
    [self updateInfoButtonWith:si];
}

@end
