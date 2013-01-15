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
    NSCalendar *mCalendar;
    NSDateComponents *mCurrentDateComponents;
    long mStartTime, mEndTime;
    long mStartJD, mFinalJD;
}

+ (AmaxDataProvider *)sharedInstance;

- (void)saveCurrentState;
- (void)restoreSavedState;
- (void)setDateFrom:(NSDate *)date;
- (void)setTodayDate;
- (NSString *)currentDateString;
- (NSDate *)currentDate;
- (void)prepareCalculation;
- (void)calculateAll;
- (NSString *)locationName;
- (NSString *)getHighlightTimeString;
- (void)changeDate:(int)deltaDays;
- (void)loadLocationById:(NSString *)locationId;

@property (strong, nonatomic, readonly) NSMutableArray * mEventCache;
@property (strong, nonatomic) NSString *mLocationId;
@property long mStartJD;
@property long mFinalJD;
@property int mCurrentLocationIndex;
@property (strong, nonatomic) NSDictionary *mLocations;
@property (strong, nonatomic) NSArray *mSortedLocationKeys;

@end
