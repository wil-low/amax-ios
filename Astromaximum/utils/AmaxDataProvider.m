//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxDataProvider.h"
#import "AmaxDataInputStream.h"
#import "AmaxCommonDataFile.h"
#import "AmaxLocationBundle.h"
#import "AmaxLocationDataFile.h"
#import "AmaxPrefs.h"
#import "AmaxEvent.h"
#import "AmaxSummaryItem.h"

@implementation AmaxDataProvider

@synthesize mEventCache = _mEventCache;
@synthesize mStartJD = _mStartJD;
@synthesize mFinalJD = _mFinalJD;

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
    });
    return (AmaxDataProvider *)sharedInstance;
}

- (NSString *)locationFileById:(NSString* )locationId
{
    return [NSString stringWithFormat:@"%@/%@.dat", documentsDirectory, locationId];
}

- (void) loadLocationById:(NSString *)locationId
{
    NSString *filePath = [self locationFileById:locationId];
    if (filePath == nil) {
        NSDictionary *sortedLocations = getSortedLocations();
        filePath = [self locationFileById:locationId]; //TODO: use first key
    }
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];

    mLocationDataFile = [[AmaxLocationDataFile alloc]initWithBytes:[fullData bytes] length:[fullData length]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:locationId forKey:AMAX_PREFS_KEY_LOCATION_ID];
    mCalendar = [NSCalendar currentCalendar];
    [mCalendar setTimeZone:[NSTimeZone timeZoneWithName:mLocationDataFile.mTimezone]];
    NSDateComponents *comp = [NSDateComponents alloc];
    [comp setYear:mLocationDataFile.mStartYear];
    [comp setMonth:mLocationDataFile.mStartMonth];
    [comp setDay:mLocationDataFile.mStartDay];
    NSDate *date = [mCalendar dateFromComponents:comp];
    mStartJD = [date timeIntervalSince1970];
    mFinalJD = mStartJD + mLocationDataFile.mDayCount * AmaxSECONDS_IN_DAY;
    [AmaxEvent setTimeZone:mLocationDataFile.mTimezone];
}

- (void)saveCurrentState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mCurrentDateComponents forKey:AMAX_PREFS_KEY_CURRENT_DATE];
}

- (NSString *)unbundleLocationAsset
{
    NSString *lastLocationId = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"dat"];
    AmaxLocationBundle *locBundle = [[AmaxLocationBundle alloc] initWithFilePath:filePath];
    int index = 0;
    char buffer[16000];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < [locBundle mRecordCount]; ++i) {
        Size bufferSize = [locBundle extractLocationByIndex:index intoBuffer:buffer];
        AmaxLocationDataFile *datafile = [[AmaxLocationDataFile alloc]initWithBytes:buffer length:bufferSize];
        lastLocationId = [[NSString alloc]initWithFormat:@"%08X", datafile.mCityId];
        NSLog(@"%d: %@ %@", index, lastLocationId, datafile.mCity);
        NSString *locFile = [self locationFileById:lastLocationId];
        NSData *outputData = [NSData dataWithBytes:buffer length:bufferSize];
        NSError *error;
        if ([outputData writeToFile:locFile options:0 error:&error] == NO) {
            NSLog(@"%@", error);
            [userDefaults setObject:datafile.mCity forKey:lastLocationId];
        }
        ++index;
    }
    return lastLocationId;
}

- (void)restoreSavedState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *locationId = [userDefaults stringForKey:AMAX_PREFS_KEY_LOCATION_ID];
    if (locationId == nil) 
        locationId = [self unbundleLocationAsset];
    [self loadLocationById:locationId];
    mCurrentDateComponents = [userDefaults objectForKey:AMAX_PREFS_KEY_CURRENT_DATE];
    if (mCurrentDateComponents == nil)
        [self setTodayDate];
}

- (void)setTodayDate
{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDate *date = [NSDate date];
    mCurrentDateComponents = [mCalendar components:unitFlags fromDate:date]; 
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
        }
        skipOff = [stream readShort];
        flag = [stream readShort ];
        if (planet == [stream readByte]) {
            break;
        } else {
            [stream skipBytes:skipOff - 6];
        }
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
    return @"Nov 12";
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
			return [self readSubDataFromStream:mCommonDataFile.mData type:evtype planet:planet isCommon:true dayStart:dayStart dayEnd:dayEnd];
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

- (NSMutableArray *)calculatePlanetaryHours
{
    /*
    ArrayList<Event> sunRises = getEventsOnPeriod(Event.EV_RISE,
                                                  Event.SE_SUN, true, mStartTime - MSECINDAY, mEndTime
                                                  + MSECINDAY, 0);
    ArrayList<Event> sunSets = getEventsOnPeriod(Event.EV_SET,
                                                 Event.SE_SUN, true, mStartTime - MSECINDAY, mEndTime
                                                 + MSECINDAY, 0);
    for (int i = 0; i < sunRises.size(); ++i)
        sunRises.get(i).mDate[1] = sunSets.get(i).mDate[0];
    ArrayList<Event> result = new ArrayList<Event>();
    getPlanetaryHours(result, sunRises.get(0), sunRises.get(1));
    getPlanetaryHours(result, sunRises.get(1), sunRises.get(2));
    return result;*/
    return nil;
}
/*
private void getPlanetaryHours(ArrayList<Event> result,
                               Event currentSunRise, Event nextSunRise) {
    int startHour = WEEK_START_HOUR[mCalendar.get(Calendar.DAY_OF_WEEK) - 1];
    final long dayHour = (currentSunRise.mDate[1] - currentSunRise.mDate[0]) / 12;
    final long nightHour = (nextSunRise.mDate[0] - currentSunRise.mDate[1]) / 12;
    long st = currentSunRise.mDate[0];
    for (int i = 0; i < 24; ++i) {
        Event ev = new Event(st - (st % Event.ROUNDING_MSEC), PLANET_HOUR_SEQUENCE[startHour % 7]);
        ev.mEvtype = Event.EV_PLANET_HOUR;
        st += i < 12 ? dayHour : nightHour;
        ev.mDate[1] = st - Event.ROUNDING_MSEC; // exclude last minute
        ev.mDate[1] -= (ev.mDate[1] % Event.ROUNDING_MSEC);
        if (ev.isInPeriod(mStartTime, mEndTime, false))
            result.add(ev);
        ++startHour;
    }
}
*/
- (NSMutableArray *)calculateAspects
{
    /*
    return [self getAspectsOnPeriodForPlanet:-1 from:mStartTime to:mEndTime];
     */
    return nil;
}

- (NSMutableArray *)calculateMoonMove
{
    /*
    ArrayList<Event> asp = getEventsOnPeriod(Event.EV_SIGN_ENTER,
                                             Event.SE_MOON, true, mStartTime - MSECINDAY * 2, mEndTime
                                             + MSECINDAY * 4, 0);
    ArrayList<Event> moonMoveVec = getAspectsOnPeriod(Event.SE_MOON,
                                                      mStartTime - MSECINDAY * 2, mEndTime + MSECINDAY * 2);
    
    mergeEvents(moonMoveVec, asp, true);
    asp.clear();
    mergeEvents(asp, moonMoveVec, false);
    int id1 = -1;
    int id2 = -1;
    int counter = 0;
    for (Event ev : asp) {
        final long dat = ev.mDate[0];
        if (dat < mStartTime) {
            id1 = counter;
        }
        if (id2 == -1 && dat >= mEndTime) {
            id2 = counter;
        }
        ++counter;
    }
    moonMoveVec.clear();
    for (int i = id1; i <= id2; i++)
        moonMoveVec.add(asp.get(i));
    
    int sz = moonMoveVec.size() - 1;
    int idx = 1;
    for (int i = 0; i < sz; i++) {
        Event evprev = moonMoveVec.get(idx - 1);
        long dd = (evprev.mEvtype == Event.EV_SIGN_ENTER) ? evprev.mDate[0]
        : evprev.mDate[1];
        Event ev = new Event(dd, -1);
        ev.mEvtype = Event.EV_MOON_MOVE;
        ev.mDate[1] = moonMoveVec.get(idx).mDate[0] - Event.ROUNDING_MSEC;
        ev.mPlanet0 = evprev.mPlanet1;
        ev.mPlanet1 = moonMoveVec.get(idx).mPlanet1;
        moonMoveVec.add(idx, ev);
        idx += 2;
    }
    sz = moonMoveVec.size();
    for (int i = 0; i < sz; ++i) {
        Event e = moonMoveVec.get(i);
        if (e.mEvtype == Event.EV_MOON_MOVE) {
            int j = i - 1;
            while (j >= 0) {
                Event prev = moonMoveVec.get(j);
                if (prev.mEvtype != Event.EV_MOON_MOVE) {
                    byte planet = prev.mPlanet1;
                    if (planet <= Event.SE_SATURN) {
                        e.mPlanet0 = planet;
                        break;
                    }
                }
                --j;
            }
            j = i + 1;
            while (j < sz) {
                Event next = moonMoveVec.get(j);
                if (next.mEvtype != Event.EV_MOON_MOVE) {
                    byte planet = next.mPlanet1;
                    if (planet <= Event.SE_SATURN) {
                        e.mPlanet1 = planet;
                        break;
                    }
                }
                ++j;
            }
        } else if (e.mEvtype == Event.EV_ASP_EXACT)
            e.mEvtype = Event.EV_ASP_EXACT_MOON;
    }
    return moonMoveVec;
     */
    return nil;
}
/*
private static void mergeEvents(ArrayList<Event> dest,
                                ArrayList<Event> add, boolean isSort) {
    for (Event ev : add) {
        if (isSort) {
            int idx = 0;
            final long dat = ev.mDate[0];
            final int sz = dest.size();
            while (idx < sz && dat > dest.get(idx).mDate[0]) {
                ++idx;
            }
            dest.add(idx, ev);
        } else {
            dest.add(ev);
        }
    }
}
*/
- (NSMutableArray *)calculateRetrogrades
{
/*
    ArrayList<Event> result = new ArrayList<Event>();
    for (int planet = Event.SE_MERCURY; planet <= Event.SE_PLUTO; ++planet) {
        ArrayList<Event> v = getEventsOnPeriod(Event.EV_RETROGRADE, planet,
                                               false, mStartTime, mEndTime, 0);
        if (!v.isEmpty())
            result.addAll(v);
    }
    return result;
 */
    return nil;
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
/*
private ArrayList<Event> getAspectsOnPeriod(int planet, long startTime,
                                            long endTime) {
    ArrayList<Event> result = new ArrayList<Event>();
    boolean flag = false;
    int cnt = getEvents(Event.EV_ASP_EXACT,
                        planet == Event.SE_MOON ? Event.SE_MOON : -1, startTime,
                        endTime);
    for (int i = 0; i < cnt; i++) {
        final Event ev = mEvents[i];
        if (planet == -1 || ev.mPlanet0 == planet || ev.mPlanet1 == planet) {
            if (ev.isDateBetween(0, startTime, endTime)) {
                flag = true;
                result.add(ev);
            }
        } else if (flag) {
            break;
        }
    }
    return result;
}
*/
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
    for(int i = 0; i < [events count]; ++i)
        NSLog(@"%@", [events objectAtIndex:i]);
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
    /*
    for (StartPageItem item : mStartPageLayout) {
        if (item.mIsEnabled)
            calculate(START_PAGE_ITEM_SEQ[item.mIndex]);
    }
    */
    [self calculateForKey:EV_SUN_DEGREE];
}

- (NSString *)locationName
{
    return @"NY";
}

- (NSString *)getHighlightTimeString
{
    return @"88:88";
}


@end
