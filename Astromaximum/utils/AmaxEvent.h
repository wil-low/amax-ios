//
//  AmaxEvent.h
//  Astromaximum
//
//  Created by admin on 21.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxTypes.h"

@interface AmaxEvent : NSObject <NSCopying>
{
    long mDate[2];
    NSDateFormatter *mDateFormatter;
}
@property AmaxPlanet mPlanet0;
@property AmaxPlanet mPlanet1;
@property AmaxEventType mEvtype;
@property short mDegree;

+ (void)initialize;
+ (void)setTimeZone:(NSString *)timezone;
+ (NSString *)long2String:(long)date0 format:(NSString *)dateFormat h24:(BOOL)h24;
+ (void)setTimeRangeFrom:(long)date0 to:(long)date1;

- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

- (AmaxEvent *) initWithDate:(long)date planet:(AmaxPlanet)planet;
- (void) setDateAt:(int)index value:(long)date;
- (long) dateAt:(int)index;
- (BOOL) isInPeriodFrom:(long)dayStart to:(long)dayEnd special:(BOOL)special;
- (BOOL)isDateAtIndex:(int)index between:(long)start and:(long)end;

int dateBetween(long date0, long start, long end);

@end
