//
//  AmaxEvent.m
//  Astromaximum
//
//  Created by admin on 21.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxEvent.h"

@implementation AmaxEvent
@synthesize mPlanet0 = _mPlanet0;
@synthesize mPlanet1 = _mPlanet1;
@synthesize mEvtype = _mEvtype;
@synthesize mDegree = _mDegree;

- (AmaxEvent *) initWithDate:(long)date planet:(AmaxPlanet)planet
{
    _mEvtype = 0;
    _mPlanet0 = planet;
    _mPlanet1 = 1;
    mDate[0] = mDate[1] = date;
    _mDegree = 127;
    return self;
}

- (void) setDateAt:(int)index value:(long)date
{
    mDate[index] = date;
}

- (BOOL) isInPeriodFrom:(long)start to:(long)end special:(BOOL)special;
{
    if (mDate[0] == 0) {
        return NO;
    }
    const int f = dateBetween(mDate[0], start, end) + dateBetween(mDate[1], start, end);
    if ((f == 2) || (f == -2)) {
        return NO;
    }
    if (special) {
        if (f == -1) {
            return NO;
        }
    }
    return YES;
    
}

int dateBetween(long date0, long start, long end)
{
    if (date0 < start) {
        return -1;
    }
    if (date0 > end) {
        return 1;
    }
    return 0;
}


@end
