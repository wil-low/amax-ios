//
//  AmaxCommonDataFile.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxCommonDataFile.h"
#import "Astromaximum-Bridging-Header.h"
#import "Astromaximum-Swift.h"

@implementation AmaxCommonDataFile

@synthesize startYear = _startYear;
@synthesize startMonth = _startMonth;
@synthesize startDay = _startDay;
@synthesize dayCount = _dayCount;
@synthesize mData = _mData;

- (id)initWithFilePath:(NSString *)filePath
{
    const int isLegacy = false;
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];
    AmaxDataInputStream *is = [[AmaxDataInputStream alloc]initWithData:fullData];
    _startYear = [is readShort];
    _startMonth = [is readUnsignedByte] - 1;
    _startDay = [is readUnsignedByte];
    
    Size customDataLen = [is readUnsignedShort]; // customData length
    if (isLegacy)
        _dayCount = [is readShort];
    else
        _monthCount = [is readUnsignedByte];
    if (customDataLen > 0) {
        customData = (NSMutableData*)[is readWithLength:customDataLen];
    }
    Size bufferLength = [is availableBytes];
    NSMutableData* buffer = (NSMutableData*)[is readWithLength:bufferLength];
    _mData = [[AmaxDataInputStream alloc]initWithData:buffer];
    return self;
}

@end
