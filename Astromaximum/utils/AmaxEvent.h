//
//  AmaxEvent.h
//  Astromaximum
//
//  Created by admin on 21.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxTypes.h"

@interface AmaxEvent : NSObject
{
    long mDate[2];
}
@property AmaxPlanet mPlanet0;
@property AmaxPlanet mPlanet1;
@property AmaxEventType mEvtype;
@property short mDegree;

- (AmaxEvent *) initWithDate:(long)date planet:(AmaxPlanet)planet;
- (void) setDateAt:(int)index value:(long)date;
- (BOOL) isInPeriodFrom:(long)dayStart to:(long)dayEnd special:(BOOL)special;

int dateBetween(long date0, long start, long end);

@end
