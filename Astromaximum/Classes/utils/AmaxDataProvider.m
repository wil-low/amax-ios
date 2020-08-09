//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxDataProvider.h"
#import "Astromaximum-Swift.h"
#import "AmaxPrefs.h"
#import "AmaxSummaryItem.h"

@interface AmaxDataProvider ()

- (int)readSubDataFromStream:(AmaxDataInputStream *)stream type:(AmaxEventType)evtype planet:(AmaxPlanet)planet isCommon:(BOOL)isCommon dayStart:(long)dayStart dayEnd:(long)dayEnd;

- (NSMutableArray *)getEventsOnPeriodForEvent:(AmaxEventType)evtype planet:(AmaxPlanet)planet special:(BOOL)special from:(long)dayStart to:(long)dayEnd value:(int)value;

- (int)getEventsForType:(AmaxEventType)evtype planet:(AmaxPlanet)planet from:(long)dayStart to:(long)dayEnd;

@end

@implementation AmaxDataProvider

@synthesize mEventCache = _mEventCache;
@synthesize mStartJD = _mStartJD;
@synthesize mFinalJD = _mFinalJD;
@synthesize mCurrentHour = _mCurrentHour;
@synthesize mCurrentMinute = _mCurrentMinute;
@synthesize mCustomHour = _mCustomHour;
@synthesize mCustomMinute = _mCustomMinute;
@synthesize mUseCustomTime = _mUseCustomTime;
@synthesize mLocationId = _mLocationId;
@synthesize mCurrentLocationIndex = _mCurrentLocationIndex;
@synthesize mLocations = _mLocations;
@synthesize mSortedLocationKeys = _mSortedLocationKeys;

static const AmaxEventType START_PAGE_ITEM_SEQ[] = {
    EV_VOC,
    EV_MOON_MOVE,
    EV_PLANET_HOUR,
    EV_MOON_SIGN,
    EV_RETROGRADE,
    EV_ASP_EXACT,
    EV_VIA_COMBUSTA,
    EV_SUN_DEGREE,
    EV_TITHI,
};

static const int WEEK_START_HOUR[] = { 0, 3, 6, 2, 5, 1, 4 };
static const AmaxPlanet PLANET_HOUR_SEQUENCE[] = {
    SE_SUN, SE_VENUS, SE_MERCURY, SE_MOON, SE_SATURN, SE_JUPITER, SE_MARS
};

+ (NSString *)getDocumentsDirectory
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];
}

+ (AmaxDataProvider *)sharedInstance
{
    static AmaxDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmaxDataProvider alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"dat"];
        sharedInstance->mCommonDataFile = [[AmaxCommonDataFile alloc] initWithFilePath:filePath];
        sharedInstance->documentsDirectory = [AmaxDataProvider getDocumentsDirectory];
        sharedInstance->_mEventCache = [[NSMutableArray alloc] init];
        sharedInstance->_mUseCustomTime = false;
    });
    return (AmaxDataProvider *)sharedInstance;
}

- (NSString *)locationFileById:(NSString* )locationId
{
    return [NSString stringWithFormat:@"%@/%@.dat", documentsDirectory, locationId];
}

- (void)loadLocationById:(NSString *)locationId
{
    NSString *filePath = [self locationFileById:locationId];
    if (filePath == nil) {
        NSDictionary *sortedLocations = getLocations();
        filePath = [self locationFileById:locationId]; //TODO: use first key
    }
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];

    mLocationDataFile = [[AmaxLocationDataFile alloc]initWithData:fullData headerOnly:NO];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:locationId forKey:AMAX_PREFS_KEY_LOCATION_ID];
    _mLocationId = locationId;
    mCalendar = [NSCalendar currentCalendar];
    [mCalendar setTimeZone:[NSTimeZone timeZoneWithName:mLocationDataFile.mTimezone]];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:mLocationDataFile.mStartYear];
    [comp setMonth:mLocationDataFile.mStartMonth];
    [comp setDay:mLocationDataFile.mStartDay];
    NSDate *date = [mCalendar dateFromComponents:comp];
    mStartJD = [date timeIntervalSince1970];
    mFinalJD = mStartJD + mLocationDataFile.mDayCount * AmaxSECONDS_IN_DAY;
    [AmaxEvent setTimeZone:mLocationDataFile.mTimezone];
    NSLog(@"loadLocationById: %@ %@", _mLocationId, [self locationName]);
}

- (void)saveCurrentState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [mCalendar dateFromComponents:mCurrentDateComponents];
    [userDefaults setObject:date forKey:AMAX_PREFS_KEY_CURRENT_DATE];
}

- (NSString *)unbundleLocationAsset
{
    NSString *lastLocationId = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"dat"];
    AmaxLocationBundle *locBundle = [[AmaxLocationBundle alloc] initWithFilePath:filePath];
    int index = 0;
                    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *locationDictionary = [NSMutableDictionary dictionary];
    for (int i = 0; i < [[locBundle recordLengths] count]; ++i) {
        NSData* data = [locBundle extractLocationBy:index];
        AmaxLocationDataFile *datafile = [[AmaxLocationDataFile alloc]initWithData:data headerOnly:YES];
        lastLocationId = [[NSString alloc]initWithFormat:@"%08X", datafile.mCityId];
        NSLog(@"%d: %@ %@", index, lastLocationId, datafile.mCity);
        NSString *locFile = [self locationFileById:lastLocationId];
        NSError *error;
        if ([data writeToFile:locFile options:0 error:&error] == NO)
            NSLog(@"%@", error);
        else
            [locationDictionary setValue:datafile.mCity forKey:lastLocationId];
        ++index;
    }
    [userDefaults setObject:locationDictionary forKey:AMAX_PREFS_KEY_LOCATION_LIST];
    NSLog(@"unbundled");
    for (id key in locationDictionary) {
        NSLog(@"Location %@ : %@", key, [locationDictionary objectForKey:key]);
    }
    return lastLocationId;
}

- (void)restoreSavedState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _mLocations = getLocations();
    for (id key in _mLocations) {
        NSLog(@"Location %@ : %@", key, [_mLocations objectForKey:key]);
    }
    _mSortedLocationKeys = [_mLocations keysSortedByValueUsingSelector:@selector(compare:)];

    NSString *locationId = [userDefaults stringForKey:AMAX_PREFS_KEY_LOCATION_ID];
    if (locationId == nil) 
        locationId = [self unbundleLocationAsset];
    [self loadLocationById:locationId];
    NSDate* date = [userDefaults objectForKey:AMAX_PREFS_KEY_CURRENT_DATE];
    if (date == nil)
        [self setTodayDate];
    else
        [self setDateFrom:date];
}

- (void)setDateFrom:(NSDate *)date
{
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    mCurrentDateComponents = [mCalendar components:unitFlags fromDate:date]; 
}

- (void)setTodayDate
{
    NSDate *date = [NSDate date];
    [self setDateFrom:date];
}

- (int)readSubDataFromStream:(AmaxDataInputStream *)stream type:(AmaxEventType)evtype planet:(AmaxPlanet)planet isCommon:(BOOL)isCommon dayStart:(long)dayStart dayEnd:(long)dayEnd
{
	const int EF_DATE = 0x1; // contains 2nd date - 4b
	const int EF_PLANET1 = 0x2; // contains 1nd planet - 1b
	const int EF_PLANET2 = 0x4; // contains 2nd planet - 1b
	const int EF_DEGREE = 0x8; // contains degree or angle - 2b
	const int EF_CUMUL_DATE_B = 0x10; // date are cumulative from 1st 4b - 1b
	const int EF_CUMUL_DATE_W = 0x20; // date are cumulative from 1st 4b - 2b
	const int EF_SHORT_DEGREE = 0x40; // contains angle 0..180 - 1b
	const int EF_NEXT_DATE2 = 0x80; // 2nd date is 1st in next event

    [stream reset];
    int eventsCount = 0;
    int flag;
    int skipOff;
    AmaxEvent *last = [[AmaxEvent alloc]initWithDate:0 planet:0];
    last.mEvtype = evtype;
    int fnext_date2;
    int PERIOD = (evtype == EV_ASCAPHETICS) ? 2 * 60 : 24 * 60;
    while (true) {
        [stream readUnsignedByte];
        int rub = [stream readUnsignedByte];
        while (evtype != rub) {
            skipOff = [stream readShort] - 3;
            [stream skipBytes:skipOff];
            [stream readUnsignedByte];
            rub = [stream readUnsignedByte];
            if ([stream reachedEOF])
                return 0;
        }
        skipOff = [stream readShort];
        flag = [stream readShort ];
        if (planet == [stream readByte]) {
            break;
        } else {
            [stream skipBytes:skipOff - 6];
        }
        if ([stream reachedEOF])
            return 0;
    }
    const int count = [stream readShort];
    int fcumul_date_b = (flag & EF_CUMUL_DATE_B);
    int fcumul_date_w = (flag & EF_CUMUL_DATE_W);
    int fdate = (flag & EF_DATE);
    int fplanet1 = (flag & EF_PLANET1);
    int fplanet2 = (flag & EF_PLANET2);
    int fdegree = (flag & EF_DEGREE);
    int fshort_degree = (flag & EF_SHORT_DEGREE);
    fnext_date2 = (flag & EF_NEXT_DATE2);
    
    AmaxPlanet myplanet0 = planet, myplanet1 = -1;
    int mydgr = 127;
    long mydate0, mydate1;
    int cumul;
    long date = 0;
    for (int i = 0; i < count; i++) {
        if (fcumul_date_b != 0) {
            if (i != 0) {
                cumul = [stream readByte];
                date += (cumul + PERIOD) * 60;
            } else {
                date = [stream readInt];
            }
        } else if (fcumul_date_w != 0) {
            if (i != 0) {
                cumul = [stream readShort];
                date += (cumul + PERIOD) * 60;
            } else {
                date = [stream readInt];
            }
        } else {
            date = [stream readInt];
        }
        
        mydate0 = date;
        if (fdate != 0) {
            mydate1 = [stream readInt] - 1;
        } else {
            mydate1 = mydate0;
        }
        if (fplanet1 != 0) {
            myplanet0 = [stream readByte];
        }
        if (fplanet2 != 0) {
            myplanet1 = [stream readByte];
        }
        if (fdegree != 0) {
            if (fshort_degree != 0) {
                mydgr = [stream readUnsignedByte];
            } else {
                mydgr = [stream readShort];
            }
        }
        if (fnext_date2 != 0) {
            [last setDateAt:1 value:(mydate0 - AmaxROUNDING_SEC)];
            mydate1 = _mFinalJD;
        }
        if ([last isInPeriodFrom:dayStart to:dayEnd special:NO]) {
            mEvents[eventsCount++] = [last copy];
        } else {
            if (eventsCount > 0) {
                break;
            }
        }
        last.mPlanet0 = myplanet0;
        last.mPlanet1 = myplanet1;
        last.mDegree = (short) mydgr;
        [last setDateAt:0 value:mydate0];
        [last setDateAt:1 value:mydate1];
    }
    if ([last isInPeriodFrom:dayStart to:dayEnd special:NO]) {
        mEvents[eventsCount++] = [last copy];
    }
    return eventsCount;
}

- (NSString *)currentDateString
{
    NSString *weekday = [NSString stringWithFormat:@"%ld", (long)mCurrentDateComponents.weekday];
    weekday = NSLocalizedStringFromTable(weekday, @"WeekDays", nil);
    return [NSString stringWithFormat:@"%@ %02ld.%02ld %04ld",
            weekday, (long)mCurrentDateComponents.month, mCurrentDateComponents.day, mCurrentDateComponents.year];
}

- (NSMutableArray *)getEventsOnPeriodForEvent:(AmaxEventType)evtype planet:(AmaxPlanet)planet special:(BOOL)special from:(long)dayStart to:(long)dayEnd value:(int)value
{
    BOOL flag = false;
    NSMutableArray *result = [NSMutableArray array];
    int cnt = [self getEventsForType:evtype planet:planet from:dayStart to:dayEnd];
    for (int i = 0; i < cnt; i++) {
        AmaxEvent *ev = mEvents[i];
        if ([ev isInPeriodFrom:dayStart to:dayEnd special:special]) {
            flag = true;
            if (value > 0) {
                ev.mDegree = (short) value;
            }
            [result addObject:ev];
        } else if (flag) {
            break;
        }
    }
    return result;
}

- (int)getEventsForType:(AmaxEventType)evtype planet:(AmaxPlanet)planet from:(long)dayStart to:(long)dayEnd
{
    switch (evtype) {
		case EV_ASTRORISE:
		case EV_ASTROSET:
		case EV_RISE:
		case EV_SET:
		case EV_ASCAPHETICS:
			return [self readSubDataFromStream:mLocationDataFile.mData type:evtype planet:planet isCommon:false dayStart:dayStart dayEnd:dayEnd];
		default:
			return [self readSubDataFromStream:mCommonDataFile.data type:evtype planet:planet isCommon:true dayStart:dayStart dayEnd:dayEnd];
    }
}

- (NSMutableArray *)calculateVOCs
{
    return [self getEventsOnPeriodForEvent:EV_VOC planet:SE_MOON special:false from:mStartTime to:mEndTime value:0];
}

- (NSMutableArray *)calculateVC
{
    return [self getEventsOnPeriodForEvent:EV_VIA_COMBUSTA planet:SE_MOON special:false from:mStartTime to:mEndTime value:0];
}

- (NSMutableArray *)calculateSunDegree
{
    return [self getEventsOnPeriodForEvent:EV_DEGREE_PASS planet:SE_SUN special:false from:mStartTime to:mEndTime value:0];
}

- (NSMutableArray *)calculateMoonSign
{
    return [self getEventsOnPeriodForEvent:EV_SIGN_ENTER planet:SE_MOON special:false from:mStartTime to:mEndTime value:0];
}

- (NSMutableArray *)calculateTithis
{
    return [self getEventsOnPeriodForEvent:EV_TITHI planet:SE_MOON special:false from:mStartTime to:mEndTime value:0];
}

- (void)getPlanetaryHoursInto:(NSMutableArray *)result currentSunRise:(AmaxEvent *)currentSunRise nextSunRise:(AmaxEvent *) nextSunRise dayOfWeek:(int) dayOfWeek
{
    int startHour = WEEK_START_HOUR[dayOfWeek];
    long dayHour = ([currentSunRise dateAt:1] - [currentSunRise dateAt:0]) / 12;
    long nightHour = ([nextSunRise dateAt:0] - [currentSunRise dateAt:1]) / 12;
    NSLog(@"getPlanetaryHoursInto: %ld, %ld", dayHour, nightHour);
    long st = [currentSunRise dateAt:0];
    for (int i = 0; i < 24; ++i) {
        AmaxEvent *ev = [[AmaxEvent alloc]initWithDate:(st - (st % AmaxROUNDING_SEC)) planet:PLANET_HOUR_SEQUENCE[startHour % 7]];
        ev.mEvtype = EV_PLANET_HOUR;
        st += i < 12 ? dayHour : nightHour;
        long date1 = st - AmaxROUNDING_SEC; // exclude last minute
        date1 -= (date1 % AmaxROUNDING_SEC);
        [ev setDateAt:1 value:date1];
        if ([ev isInPeriodFrom:mStartTime to:mEndTime special:false])
            [result addObject:ev];
        ++startHour;
    }
}

- (NSMutableArray *)calculatePlanetaryHours
{
    NSMutableArray *sunRises = [self getEventsOnPeriodForEvent:EV_RISE planet:SE_SUN special:true from:(mStartTime - AmaxSECONDS_IN_DAY) to:(mEndTime + AmaxSECONDS_IN_DAY) value:0];
    NSMutableArray *sunSets = [self getEventsOnPeriodForEvent:EV_SET planet:SE_SUN special:true from:(mStartTime - AmaxSECONDS_IN_DAY) to:(mEndTime + AmaxSECONDS_IN_DAY) value:0];
    NSMutableArray *result = [NSMutableArray array];
    if ([sunRises count] < 3 || [sunRises count] != [sunSets count])
        return result;
    for (int i = 0; i < [sunRises count]; ++i)
        [[sunRises objectAtIndex:i] setDateAt:1 value:[[sunSets objectAtIndex:i] dateAt:0]];
    int dayOfWeek = [mCurrentDateComponents weekday] - 1;
    if (dayOfWeek < 1)
        dayOfWeek = 6;
    else
        --dayOfWeek;
    [self getPlanetaryHoursInto:result currentSunRise:[sunRises objectAtIndex:0] nextSunRise:[sunRises objectAtIndex:1] dayOfWeek:dayOfWeek];
    dayOfWeek = (dayOfWeek + 1) % 7;
    [self getPlanetaryHoursInto:result currentSunRise:[sunRises objectAtIndex:1] nextSunRise:[sunRises objectAtIndex:2] dayOfWeek:dayOfWeek];
    return result;
}

- (NSMutableArray *)getAspectsOnPeriodForPlanet:(AmaxPlanet)planet from:(long)startTime to:(long)endTime
{
    NSMutableArray *result = [NSMutableArray array];
    BOOL flag = false;
    int cnt = [self getEventsForType:EV_ASP_EXACT planet:(planet == SE_MOON ? SE_MOON : -1)
                                from:startTime to:endTime];
    for (int i = 0; i < cnt; i++) {
        AmaxEvent *ev = mEvents[i];
        if (planet == -1 || ev.mPlanet0 == planet || ev.mPlanet1 == planet) {
            if ([ev isDateAt:0 between:startTime and:endTime]) {
                flag = true;
                [result addObject:ev];
            }
        } else if (flag) {
            break;
        }
    }
    return result;
}

static void mergeEvents(NSMutableArray *dest, NSMutableArray *add, BOOL isSort)
{
    for (AmaxEvent *ev in add) {
        if (isSort) {
            int idx = 0;
            long dat = [ev dateAt:0];
            int sz = [dest count];
            while (idx < sz && dat > [[dest objectAtIndex:idx]dateAt:0]) {
                ++idx;
            }
            [dest insertObject:ev atIndex:idx];
        } else {
            [dest addObject:ev];
        }
    }
}

- (NSMutableArray *)calculateMoonMove
{
    NSMutableArray *asp = [self getEventsOnPeriodForEvent:EV_SIGN_ENTER planet:SE_MOON special:true from:(mStartTime - AmaxSECONDS_IN_DAY * 2) to:(mEndTime + AmaxSECONDS_IN_DAY * 4) value:0];
    NSMutableArray *moonMoveVec = [self getAspectsOnPeriodForPlanet:SE_MOON
                                        from:(mStartTime - AmaxSECONDS_IN_DAY * 2) to:(mEndTime + AmaxSECONDS_IN_DAY * 2)];
    
    mergeEvents(moonMoveVec, asp, true);
    [asp removeAllObjects];
    mergeEvents(asp, moonMoveVec, false);
    int id1 = -1;
    int id2 = -1;
    int counter = 0;
    for (AmaxEvent *ev in asp) {
        long dat = [ev dateAt:0];
        if (dat < mStartTime) {
            id1 = counter;
        }
        if (id2 == -1 && dat >= mEndTime) {
            id2 = counter;
        }
        ++counter;
    }
    [moonMoveVec removeAllObjects];
    if (id1 != -1 && id2 != -1) {
        for (int i = id1; i <= id2; i++)
            [moonMoveVec addObject:[asp objectAtIndex:i]];
    }
    
    int sz = [moonMoveVec count] - 1;
    int idx = 1;
    for (int i = 0; i < sz; i++) {
        AmaxEvent *evprev = [moonMoveVec objectAtIndex:(idx - 1)];
        long dd = [evprev dateAt:(evprev.mEvtype == EV_SIGN_ENTER ? 0 : 1)];
        AmaxEvent *ev = [[AmaxEvent alloc]initWithDate:dd planet:-1];
        ev.mEvtype = EV_MOON_MOVE;
        [ev setDateAt:1 value:([[moonMoveVec objectAtIndex:idx] dateAt:0] - AmaxROUNDING_SEC)];
        ev.mPlanet0 = evprev.mPlanet1;
        ev.mPlanet1 = [[moonMoveVec objectAtIndex:idx] mPlanet1];
        [moonMoveVec insertObject:ev atIndex:idx];
        idx += 2;
    }
    sz = [moonMoveVec count];
    for (int i = 0; i < sz; ++i) {
        AmaxEvent *e = [moonMoveVec objectAtIndex:i];
        if (e.mEvtype == EV_MOON_MOVE) {
            int j = i - 1;
            while (j >= 0) {
                AmaxEvent *prev = [moonMoveVec objectAtIndex:j];
                if (prev.mEvtype != EV_MOON_MOVE) {
                    AmaxPlanet planet = prev.mPlanet1;
                    if (planet <= SE_SATURN) {
                        e.mPlanet0 = planet;
                        break;
                    }
                }
                --j;
            }
            j = i + 1;
            while (j < sz) {
                AmaxEvent *next = [moonMoveVec objectAtIndex:j];
                if (next.mEvtype != EV_MOON_MOVE) {
                    AmaxPlanet planet = next.mPlanet1;
                    if (planet <= SE_SATURN) {
                        e.mPlanet1 = planet;
                        break;
                    }
                }
                ++j;
            }
        } else if (e.mEvtype == EV_ASP_EXACT)
            e.mEvtype = EV_ASP_EXACT_MOON;
    }
    return moonMoveVec;
}

- (NSMutableArray *)calculateRetrogrades
{
    NSMutableArray *result = [NSMutableArray array];
    for (AmaxPlanet planet = SE_MERCURY; planet <= SE_PLUTO; ++planet) {
        NSMutableArray *v = [self getEventsOnPeriodForEvent:EV_RETROGRADE planet:planet special:false from:mStartTime to:mEndTime value:0];
        if ([v count])
            [result addObjectsFromArray:v];
    }
    return result;
}

- (NSMutableArray *)getRiseSetForPlanet:(AmaxPlanet)planet from:(long)startTime to:(long)endTime
{
    /*
    ArrayList<Event> result = new ArrayList<Event>();
    Event eop = getEventOnPeriod(Event.EV_RISE, planet, true, startTime,
                                 endTime);
    if (eop == null || eop.mDate[0] < startTime) {
        eop = new Event(0, planet);
    }
    Event eop1 = getEventOnPeriod(Event.EV_SET, planet, false, startTime,
                                  mEndTime);
    if (eop1 == null || eop1.mDate[0] < startTime) {
        eop1 = new Event(0, planet);
    }
    eop.mDate[1] = eop1.mDate[0];
    result.add(eop);
    return result;
     */
    return nil;
}
/*
private Event getEventOnPeriod(int evType, int planet, boolean special,
                               long startTime, long endTime) {
    int cnt = getEvents(evType, planet, startTime, endTime);
    if (evType == Event.EV_RISE && planet == Event.SE_SUN) {
        Event dummy = new Event(startTime, 0);
        dummy.mDate[1] = endTime;
        MyLog.d("dummy", dummy.toString());
        for (int i = 0; i < cnt; i++) {
            MyLog.d("getEventOnPeriod", mEvents[i].toString());
        }
    }
    for (int i = 0; i < cnt; i++) {
        final Event ev = mEvents[i];
        if (ev.isInPeriod(startTime, endTime, special)) {
            return ev;
        }
    }
    return null;
}
*/

- (NSMutableArray *)calculateAspects
{
    return [self getAspectsOnPeriodForPlanet:-1 from:mStartTime to:mEndTime];
}

- (AmaxSummaryItem *)calculateForKey:(AmaxEventType)key
{
    NSMutableArray *events = nil;
    switch (key) {
		case EV_VOC:
			events = [self calculateVOCs];
			break;
		case EV_VIA_COMBUSTA:
			events = [self calculateVC];
			break;
		case EV_SUN_DEGREE:
			events = [self calculateSunDegree];
			break;
		case EV_MOON_SIGN:
			events = [self calculateMoonSign];
			break;
		case EV_PLANET_HOUR:
			events = [self calculatePlanetaryHours];
			break;
		case EV_ASP_EXACT:
			events = [self calculateAspects];
			break;
		case EV_MOON_MOVE:
			events = [self calculateMoonMove];
			break;
		case EV_TITHI:
			events = [self calculateTithis];
			break;
		case EV_RETROGRADE:
			events = [self calculateRetrogrades];
			break;
		default:
			return nil;
    }
    AmaxSummaryItem *si = [[AmaxSummaryItem alloc]initWithKey:key events:events];
    [_mEventCache addObject:si];
    return si;
}

- (void)prepareCalculation
{
    NSDate *date = [mCalendar dateFromComponents:mCurrentDateComponents];
    mStartTime = [date timeIntervalSince1970];
    mEndTime = mStartTime + AmaxSECONDS_IN_DAY - AmaxROUNDING_SEC;
    [AmaxEvent setTimeRangeFrom:mStartTime to:mEndTime];
    [_mEventCache removeAllObjects];
    
}

- (void)calculateAll
{
    for (int i = 0; i < sizeof(START_PAGE_ITEM_SEQ) / sizeof(START_PAGE_ITEM_SEQ[0]); ++i) {
        [self calculateForKey:START_PAGE_ITEM_SEQ[i]];
    }
}

- (NSString *)locationName
{
    return [mLocationDataFile mCity];
}

- (NSString *)getHighlightTimeString
{
    if (_mUseCustomTime)
        return [NSString stringWithFormat:@"%02ld:%02ld", _mCustomHour, _mCustomMinute];
    return [NSString stringWithFormat:@"%02ld:%02ld", _mCurrentHour, _mCurrentMinute];
}

- (void)changeDate:(int)deltaDays
{
    [_mEventCache removeAllObjects];
    mStartTime += AmaxSECONDS_IN_DAY * deltaDays + AmaxSECONDS_IN_DAY / 2;
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:mStartTime];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    mCurrentDateComponents = [mCalendar components:unitFlags fromDate:newDate];
}

- (NSDate *)currentDate
{
    return [mCalendar dateFromComponents:mCurrentDateComponents];
}

- (long)getCustomTime
{
/*
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    mCurrentDateComponents = [mCalendar components:unitFlags fromDate:date];

    Calendar calendar = Calendar.getInstance(mCalendar.getTimeZone());
    if (mUseCustomTime) {
        calendar.set(mYear, mMonth, mDay, mCustomHour, mCustomMinute);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
    } else {
        calendar.set(Calendar.YEAR, mYear);
        calendar.set(Calendar.MONTH, mMonth);
        calendar.set(Calendar.DAY_OF_MONTH, mDay);
        mCurrentHour = calendar.get(Calendar.HOUR_OF_DAY);
        mCurrentMinute = calendar.get(Calendar.MINUTE);
    }
    MyLog.d("getCustomTime",
            (String) DateFormat.format("dd MMMM yyyy, kk:mm:ss", calendar));
    return calendar.getTimeInMillis();
 */
    return 0;
}

- (long)getCurrentTime
{
    if (!_mUseCustomTime) {
        NSDateComponents* comp = [mCurrentDateComponents copy];
        NSDate *date = [NSDate date];
        unsigned unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents* comp2 = [mCalendar components:unitFlags fromDate:date];
        _mCurrentHour = comp2.hour;
        _mCurrentMinute = comp2.minute;
        [comp setHour:_mCurrentHour];
        [comp setMinute:_mCurrentMinute];
        date = [mCalendar dateFromComponents:comp];
        return [date timeIntervalSince1970];
    }
    return 0;
}

- (bool)isInCurrentDay:(long)date
{
    return dateBetween(date, mStartTime, mEndTime) == 0;
}
@end
