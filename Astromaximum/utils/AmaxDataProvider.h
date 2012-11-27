//
//  AmaxDataProvider.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxTypes.h"

@class AmaxCommonDataFile, AmaxLocationDataFile, AmaxEvent, AmaxDataInputStream;

@interface AmaxDataProvider : NSObject

{
    AmaxCommonDataFile * mCommonDataFile;
    AmaxLocationDataFile * mLocationDataFile;
    NSString * documentsDirectory;
    AmaxEvent * mEvents[100];
    NSMutableArray *mEventCache;
    NSCalendar *mCalendar;
    NSDateComponents *mCurrentDateComponents;
    long mStartTime, mEndTime;
    long mStartJD, mFinalJD;
}

+ (AmaxDataProvider *)sharedInstance;

- (void)saveCurrentState;
- (void)restoreSavedState;
- (void)setTodayDate;
- (NSString *)currentDateString;
- (void)prepareCalculation;
- (void)calculateAll;
- (NSString *)locationName;
- (NSString *)getHighlightTimeString;

- (int)readSubDataFromStream:(AmaxDataInputStream *)stream type:(AmaxEventType)evtype planet:(AmaxPlanet)planet isCommon:(BOOL)isCommon dayStart:(long)dayStart dayEnd:(long)dayEnd;
- (NSMutableArray *)getEventsOnPeriodForEvent:(AmaxEventType)evtype planet:(AmaxPlanet)planet special:(BOOL)special from:(long)dayStart to:(long)dayEnd value:(int)value;
- (int)getEventsForType:(AmaxEventType)evtype planet:(AmaxPlanet)planet from:(long)dayStart to:(long)dayEnd;

@property (strong, nonatomic) NSArray * eventCache;
@property long mStartJD;
@property long mFinalJD;
@end
