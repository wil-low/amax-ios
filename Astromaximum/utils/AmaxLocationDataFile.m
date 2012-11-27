//
//  AmaxLocationDataFile.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxLocationDataFile.h"
#import "AmaxDataInputStream.h"
#import "AmaxTimezoneTransition.h"

@implementation AmaxLocationDataFile

@synthesize mStartYear = _mStartYear;
@synthesize mStartMonth = _mStartMonth;
@synthesize mStartDay = _mStartDay;
@synthesize mDayCount = _mDayCount;
@synthesize mCityId = _mCityId;
@synthesize mCity = _mCity;
@synthesize mState = _mState;
@synthesize mCountry = _mCountry;
@synthesize mTimezone = _mTimezone;
@synthesize mData = _mData;

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length
{
    AmaxDataInputStream *dis = [[AmaxDataInputStream alloc]initWithBytes:bytes length:length];
    [dis skipBytes:4]; // signature
    char version = [dis readUnsignedByte];
    if (version == 2) {
        _mStartYear = [dis readShort];
        _mStartMonth = [dis readUnsignedByte];
        _mStartDay = [dis readUnsignedByte];
        _mDayCount = [dis readShort];
        _mCityId = [dis readInt]; // city id
        coords[0] = [dis readShort]; // latitude
        coords[1] = [dis readShort]; // longitude
        coords[2] = [dis readShort]; // altitude
        _mCity = [dis readUTF]; // city
        _mState = [dis readUTF]; // state
        _mCountry = [dis readUTF]; // country
        _mTimezone = [dis readUTF]; // timezone
        customData = [dis readUTF]; // custom data
        int transitionCount = [dis readUnsignedByte];
        transitions = [NSMutableArray array];
        for (int i = 0; i < transitionCount; ++i) {
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:[dis readInt]]; // start_date
            NSTimeInterval offset = [dis readShort] * 60; // gmt_ofs_min
            NSString* name = [dis readUTF]; // name
            AmaxTimezoneTransition *transition = [[AmaxTimezoneTransition alloc]initWithTime:time offset:offset name:name];
            [transitions addObject:transition]; 
        }
        Size bufferLength = [dis availableBytes];
        char *buffer = malloc(bufferLength);
        [dis readToBuffer:buffer length:bufferLength];
        _mData = [[AmaxDataInputStream alloc]initWithBytes:buffer length:bufferLength];
    }
    else {
        NSLog(@"Unknown version %d", version);
    }
    return self;
}

@end
