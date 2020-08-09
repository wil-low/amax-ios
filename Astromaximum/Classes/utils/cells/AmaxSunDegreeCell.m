//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSunDegreeCell.h"
#import "Astromaximum-Swift.h"

@implementation AmaxSunDegreeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    degreeLabel = (UILabel *)[self viewWithTag:3];
    zodiacLabel = (UILabel *)[self viewWithTag:4];
}

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [timeLabel setText:[e normalizedRangeString]];
        [eventLabel setText:[NSString stringWithFormat:@"%c",
                             getSymbol(TYPE_PLANET, e.mPlanet0)]];
        [degreeLabel setText:[NSString stringWithFormat:@"%d\u00b0",
                             [e getDegree] % 30 + 1]];
        [zodiacLabel setText:[NSString stringWithFormat:@"%c",
                             getSymbol(TYPE_ZODIAC, [e getDegree] / 30)]];
		[self setColorOf:eventLabel byEventMode:e];
    }
    [self updateInfoButtonWith:si];
}

@end
