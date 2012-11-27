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

static NSCalendar* mCalendar;
static NSDateFormatter *mDateFormatter;
static long mPeriod0;
static long mPeriod1;

static NSString *DEFAULT_DATE_FORMAT = @"%02d-%02d %02d:%02d";

+ (void)initialize
{
    mDateFormatter = [[NSDateFormatter alloc]init];
    [mDateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
}

- (AmaxEvent *) initWithDate:(long)date planet:(AmaxPlanet)planet
{
    _mEvtype = 0;
    _mPlanet0 = planet;
    _mPlanet1 = 1;
    mDate[0] = mDate[1] = date;
    _mDegree = 127;
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    AmaxEvent* copy = [[[self class] allocWithZone:zone] init];
    copy.mEvtype = self.mEvtype;  
    copy.mDegree = self.mDegree;  
    copy.mPlanet0 = self.mPlanet0;  
    copy.mPlanet1 = self.mPlanet1;
    [copy setDateAt:0 value:[self dateAt:0]];
    [copy setDateAt:1 value:[self dateAt:1]];
    return copy;
}

- (BOOL)isDateAtIndex:(int)index between:(long)start and:(long)end
{
    long dat = mDate[index];
    return start <= dat && dat < end;
}

- (NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"%s %@ - %@ p %d/%d dgr %d",
                        "",//EVENT_TYPE_STR[_mEvtype],
                        [AmaxEvent long2String:mDate[0] format:DEFAULT_DATE_FORMAT h24:true],
                        [AmaxEvent long2String:mDate[1] format:DEFAULT_DATE_FORMAT h24:true],
                        _mPlanet0, _mPlanet1,
                        _mDegree];
    return result;
}

+ (NSString *)long2String:(long)date0 format:(NSString *)dateFormat h24:(BOOL)h24
{
    static const unsigned unitFlags =  NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekdayCalendarUnit;

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:date0];
    NSDateComponents *comps = [mCalendar components:unitFlags fromDate:date];
    NSMutableString *result = [[NSMutableString alloc]init];
    if (dateFormat != nil) {
        [result appendString:[NSString stringWithFormat:dateFormat,
                              [comps month], [comps day],
                              [comps hour], [comps minute]]];
        return result;        
    }
    return nil;
    /*
    int hh = 0, mm = 0;
    hh = mCalendar.get(Calendar.HOUR_OF_DAY);
    mm = mCalendar.get(Calendar.MINUTE);
    
    if (h24 && hh + mm == 0) {
        hh = 24;
    }
    s.append(to2String(hh)).append(":").append(to2String(mm));
    //int ss = mCalendar.get(Calendar.SECOND);
    //s.append(":").append(to2String(ss));
    
    // if(!hoursOnly)
    // s.append("/");
    
    // s+=to2String(date0[index])+":"+to2String(date0[index]);
    return s.toString();*/
}

+ (void)setTimeRangeFrom:(long)date0 to:(long)date1
{
    mPeriod0 = date0;
    mPeriod1 = date1;
}

+ (void)setTimeZone:(NSString *)timezone
{
    mCalendar = [NSCalendar currentCalendar];
    [mCalendar setTimeZone:[NSTimeZone timeZoneWithName:timezone]];
}

- (void) setDateAt:(int)index value:(long)date
{
    mDate[index] = date;
}

- (long) dateAt:(int)index
{
    return mDate[index];
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
