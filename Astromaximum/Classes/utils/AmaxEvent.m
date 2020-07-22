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
static long mPeriod0;
static long mPeriod1;

static NSString *DEFAULT_DATE_FORMAT = @"%02d-%02d %02d:%02d";
static NSDateFormatter *mMonthAbbrDayDateFormatter;

const bool USE_EXACT_RANGE = false;

+ (void)initialize
{
    mMonthAbbrDayDateFormatter = [[NSDateFormatter alloc]init];
    [mMonthAbbrDayDateFormatter setDateFormat:NSLocalizedString(@"month_abbr_day_date_format",  nil)];
}

+ (NSDateFormatter *)monthAbbrDayDateFormatter
{
    return mMonthAbbrDayDateFormatter;
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
                        [AmaxEvent long2String:mDate[0] format:mMonthAbbrDayDateFormatter h24:true],
                        [AmaxEvent long2String:mDate[1] format:mMonthAbbrDayDateFormatter h24:true],
                        _mPlanet0, _mPlanet1,
                        _mDegree];
    return result;
}

- (NSString *)normalizedRangeString
{
    long date0 = mDate[0], date1 = mDate[1];
    if (USE_EXACT_RANGE) {
        if (date0 < mPeriod0)
            date0 = mPeriod0;
        if (date1 > mPeriod1)
            date1 = mPeriod1;
        
        return [NSString stringWithFormat:@"%@ - %@", [AmaxEvent long2String:date0 format:nil h24:false], [AmaxEvent long2String:date1 format:nil h24:true]];
    }
    
    bool isTillRequired = date0 < mPeriod0;
    bool isSinceRequired = date1 > mPeriod1;
    
    if (isTillRequired && isSinceRequired)
        return NSLocalizedString(@"norm_range_whole_day", "");
    
    if (isTillRequired)
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"norm_range_arrow", ""), [AmaxEvent long2String:date1 format:nil h24:true]];
    
    if (isSinceRequired)
        return [NSString stringWithFormat:@"%@ %@", [AmaxEvent long2String:date0 format:nil h24:false], NSLocalizedString(@"norm_range_arrow", "")];
    
    return [NSString stringWithFormat:@"%@ - %@", [AmaxEvent long2String:date0 format:nil h24:false], [AmaxEvent long2String:date1 format:nil h24:true]];
}

+ (NSString *)long2String:(long)date0 format:(NSDateFormatter *)dateFormatter h24:(BOOL)h24
{
    static const unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday;

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:date0];
    NSDateComponents *comps = [mCalendar components:unitFlags fromDate:date];
    NSMutableString *result = [[NSMutableString alloc]init];
    
    if (dateFormatter != nil) {
        dateFormatter.calendar = mCalendar;
        [result appendString:[dateFormatter stringFromDate:date]];
        [result appendString:@" "];
    }
    
    int hh = [comps hour];
    int mm = [comps minute];
    
    if (h24 && hh + mm == 0) {
        hh = 24;
    }
    [result appendString:[NSString stringWithFormat:@"%02d:%02d", hh, mm]];
    return result;
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

- (int)getDegree
{
    return _mDegree & 0x3ff;
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
