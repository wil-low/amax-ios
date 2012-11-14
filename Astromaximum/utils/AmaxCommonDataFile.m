//
//  AmaxCommonDataFile.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmaxCommonDataFile.h"
#import "AmaxDataInputStream.h"

@implementation AmaxCommonDataFile

@synthesize startYear = _startYear;
@synthesize startMonth = _startMonth;
@synthesize startDay = _startDay;
@synthesize dayCount = _dayCount;

- (id)initWithFilePath:(NSString *)filePath;
{
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];
    AmaxDataInputStream *is = [[AmaxDataInputStream alloc]initWithData:fullData];
    _startYear = [is readShort];
    _startMonth = [is readUnsignedByte];
    _startDay = [is readUnsignedByte];
    
    Size customDataLen = [is readUnsignedShort]; // customData length
    _dayCount = [is readShort];
    if (customDataLen > 0) {
        customData = malloc(customDataLen);
        [is readToBuffer:customData length:customDataLen];
    }
    Size bufferLength = [is availableBytes];
    void *buffer = malloc(bufferLength);
    [is readToBuffer:buffer length:bufferLength];
    data = [[AmaxDataInputStream alloc]initWithBytes:buffer length:bufferLength];
    free(buffer);
    return self;
}

- (void) dealloc
{
    free(customData);
}
@end
