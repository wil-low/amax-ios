//
//  AmaxLocationDataFile.h
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxDataInputStream.h"
#import "AmaxTimezoneTransition.h"

@interface AmaxLocationDataFile : NSObject
{
    int coords[3];
	NSString *customData;
	NSMutableArray *transitions;
	AmaxDataInputStream *data;
}
@property (readonly) int mStartYear;
@property (readonly) int mStartMonth;
@property (readonly) int mStartDay;
@property (readonly) int mDayCount;
@property (readonly) int mCityId;
@property (readonly, strong, nonatomic) NSString *mCity;
@property (readonly, strong, nonatomic) NSString *mState;
@property (readonly, strong, nonatomic) NSString *mCountry;
@property (readonly, strong, nonatomic) NSString *mTimezone;

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length;

@end
