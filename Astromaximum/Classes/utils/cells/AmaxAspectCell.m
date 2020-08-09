//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxAspectCell.h"
#import "Astromaximum-Swift.h"

@implementation AmaxAspectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    mDataProvider = [AmaxDataProvider sharedInstance];
}

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        [eventLabel setText:[NSString stringWithFormat:@"%c %c %c",
                             getSymbol(TYPE_PLANET, e.mPlanet0),
                             getSymbol(TYPE_ASPECT, e.mDegree),
                             getSymbol(TYPE_PLANET, e.mPlanet1)]];
        [timeLabel setText:[AmaxEvent long2String:[e dateAt:0] format:nil h24:false]];
    }
    [self updateInfoButtonWith:si];
}

@end
