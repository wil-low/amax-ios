//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxPlanetHourCell.h"
#import "Astromaximum-Swift.h"

@implementation AmaxPlanetHourCell

- (void)awakeFromNib {
    [super awakeFromNib];
    hourLabel = (UILabel *)[self viewWithTag:3];
    [hourLabel setText:NSLocalizedString(@"hour_of", @"Planet hour event caption")];
}

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [timeLabel setText:[e normalizedRangeString]];
        [eventLabel setText:[NSString stringWithFormat:@"%c",
                             getSymbol(TYPE_PLANET, e.mPlanet0)]];
		[self setColorOf:eventLabel byEventMode:e];
    }
    [self updateInfoButtonWith:si];
}

@end
