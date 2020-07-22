//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxMoonMoveCell.h"

@implementation AmaxMoonMoveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    transitionSignLabel = (UILabel *)[self viewWithTag:3];
    [transitionSignLabel setText:NSLocalizedString(@"norm_range_arrow", "")];
    mDataProvider = [AmaxDataProvider sharedInstance];
}

- (void)configure:(AmaxSummaryItem *)si
{
    [super configure:si];
    AmaxEvent* e = [si mActiveEvent];
    if (e != nil) {
        //mText0.setTextColor(mDefaultTextColor);
        long date0 = [e dateAt:0];
        switch (e.mEvtype) {
            case EV_MOON_MOVE:
                [timeLabel setText:[e normalizedRangeString]];
                [eventLabel setHidden:true];
                [transitionSignLabel setHidden:false];
                //setColorByEventMode(mText0, e);
                break;
            case EV_ASP_EXACT_MOON:
                [eventLabel setText:[NSString stringWithFormat:@"%c %c %c",
                                     getSymbol(TYPE_PLANET, e.mPlanet0),
                                     getSymbol(TYPE_ASPECT, e.mDegree),
                                     getSymbol(TYPE_PLANET, e.mPlanet1)
                                     ]];
                [timeLabel setText:[AmaxEvent long2String:date0 format:[mDataProvider isInCurrentDay:date0] ? nil : [AmaxEvent monthAbbrDayDateFormatter] h24:true]];
                [eventLabel setHidden:false];
                [transitionSignLabel setHidden:true];
                break;
            case EV_SIGN_ENTER:
                [eventLabel setText:[NSString stringWithFormat:@"%c",
                                     getSymbol(TYPE_ZODIAC, e.mDegree)]];
                [eventLabel setHidden:false];
                [timeLabel setText:[AmaxEvent long2String:date0 format:[mDataProvider isInCurrentDay:date0] ? nil : [AmaxEvent monthAbbrDayDateFormatter] h24:true]];
                [transitionSignLabel setHidden:true];
                break;
            default:
                break;
        }
        //[self setColorOf:eventLabel byEventMode:e];
    }
    else {
        [eventLabel setText:@""];
        [eventLabel setHidden:true];
        [transitionSignLabel setHidden:false];
    }
    [self updateInfoButtonWith:si];
}

@end
