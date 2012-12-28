//
//  AmaxLocationBundle.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxLocationBundle.h"
#import "AmaxDataInputStream.h"

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
    char *buffer = malloc(bufferLength);
    [is readToBuffer:buffer length:bufferLength];
    locStream = [[AmaxDataInputStream alloc]initWithBytes:buffer length:bufferLength];
    free(buffer);
    return self;
}

- (void) dealloc
{
    free(recordLengths);
}

- (Size) extractLocationByIndex:(int)index intoBuffer:(void *)destBuffer
{
    [locStream reset];
    Size offset = 0;
    for (int i = 0; i < index; i++) {
        offset += recordLengths[i];
    }
    Size length = recordLengths[index];
    [locStream skipBytes:offset];
    [locStream readToBuffer:destBuffer length:length];
    return length;
}

@end
