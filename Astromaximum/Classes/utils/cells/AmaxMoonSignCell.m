//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxMoonSignCell.h"

@implementation AmaxMoonSignCell

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [timeLabel setText:[e normalizedRangeString]];
        [eventLabel setText:[NSString stringWithFormat:@"%c %c",
                             getSymbol(TYPE_PLANET, e.mPlanet0),
                             getSymbol(TYPE_ZODIAC, [e getDegree])]];
		[self setColorOf:eventLabel byEventMode:e];
    }
    [self updateInfoButtonWith:si];
}

@end
