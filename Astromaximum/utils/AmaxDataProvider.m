//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxDataProvider.h"
#import "AmaxPrefs.h"
#import "AmaxEvent.h"

@implementation AmaxDataProvider

@synthesize eventCache = _eventCache;
@synthesize mStartJD = _mStartJD;
@synthesize mFinalJD = _mFinalJD;

+ (AmaxDataProvider *)sharedInstance
{
    static AmaxDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmaxDataProvider alloc] init];
        [sharedInstance setEventCache:[NSArray array]];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"dat"];
        sharedInstance->commonDataFile = [[AmaxCommonDataFile alloc] initWithFilePath:filePath];
    });
    return (AmaxDataProvider *)sharedInstance;
}

+ (NSString *)getDocumentsDirectory
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];
}

- (void) loadLocationById:(NSString *)locationId
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:locationId ofType:@"dat"];
    if (filePath == nil) {
        
    }
}

- (void)saveCurrentState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"Kiev" forKey:AMAX_PREFS_KEY_LOCATION_ID];
}

- (void)restoreSavedState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *locationId = [userDefaults stringForKey:AMAX_PREFS_KEY_LOCATION_ID];
    [self loadLocationById:locationId];
}

- (int) readSubDataFromStream:(AmaxDataInputStream *)stream type:(AmaxEventType)evtype planet:(AmaxPlanet)planet isCommon:(BOOL)isCommon dayStart:(long)dayStart dayEnd:(long)dayEnd
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

@end
