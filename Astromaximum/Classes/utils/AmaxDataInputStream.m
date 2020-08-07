//
//  AmaxDataInputStream.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "Astromaximum-Bridging-Header.h"

@implementation AmaxDataInputStream

- (AmaxDataInputStream *)initWithBytes:(const void *)bytes length:(NSUInteger)length
{
    dataLength = length;
    data = malloc(dataLength);
    memcpy(data, bytes, dataLength);
    return self;
}

- (AmaxDataInputStream *)initWithData:(const NSData *)rawData
{
    dataLength = [rawData length];
    data = malloc(dataLength);
    memcpy(data, [rawData bytes], dataLength);
    return self;
}

- (void) dealloc
{
    free(data);
}

- (void)reset
{
    position = 0;
}

- (void)skipBytes:(size_t)byteCount
{
    position += byteCount;
}

- (BOOL)reachedEOF
{
    return position >= dataLength;
}

- (SInt16)readShort
{
    SInt16 res = data[position++];
    res <<= 8;
    res += data[position++];
    return res;
}

- (unsigned char)readUnsignedByte
{
    return data[position++];
}

- (char)readByte
{
    return data[position++];
}

- (UInt16)readUnsignedShort
{
    UInt32 n0 = data[position++];
    UInt32 n1 = data[position++];
    return (n0 << 8) + n1;
    
}

- (int)readInt
{
    int res = data[position++];
    res <<= 8;
    res += data[position++];
    res <<= 8;
    res += data[position++];
    res <<= 8;
    res += data[position++];
    return res;
}

- (Size)availableBytes
{
    return dataLength - position;
}

- (void)readToBuffer:(void *)buffer length:(Size)byteCount
{
    memcpy(buffer, &data[position], byteCount);
    position += byteCount;
}

- (NSString *)readUTF
{
    UInt16 stringLength = [self readUnsignedShort];
    char *buffer = malloc(stringLength + 1);
    [self readToBuffer:buffer length:stringLength];
    buffer[stringLength] = 0;
    return [[NSString alloc]initWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end
