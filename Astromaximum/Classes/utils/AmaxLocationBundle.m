//
//  AmaxLocationBundle.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "Astromaximum-Bridging-Header.h"
#import "Astromaximum-Swift.h"

@implementation AmaxLocationBundle

@synthesize mRecordCount = _mRecordCount;

- (id)initWithFilePath:(NSString *)filePath
{
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];
    AmaxDataInputStream *is = [[AmaxDataInputStream alloc]initWithData:fullData];
    [is readShort]; // skip year
    _mRecordCount = [is readUnsignedShort];
    recordLengths = malloc(_mRecordCount * sizeof(recordLengths[0]));
    for (int i = 0; i < _mRecordCount; ++i)
        recordLengths[i] = [is readUnsignedShort];
    Size bufferLength = [is availableBytes];
    NSData* locData = [is readWithLength:bufferLength];
    locStream = [[AmaxDataInputStream alloc]initWithData:locData];
    return self;
}

- (void) dealloc
{
    free(recordLengths);
}

- (Size) extractLocationByIndex:(int)index intoData:(NSData *)data
{
    [locStream reset];
    Size offset = 0;
    for (int i = 0; i < index; i++) {
        offset += recordLengths[i];
    }
    Size length = recordLengths[index];
    [locStream skipBytes:offset];
    data = [locStream readWithLength:length];
    return length;
}

@end
