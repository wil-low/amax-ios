//
//  AmaxDataInputStream.h
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmaxDataInputStream : NSObject
{
    Size position;
    Size dataLength;
    unsigned char *data;
}

- (AmaxDataInputStream *)initWithBytes:(const void *)bytes length:(NSUInteger)length;
- (AmaxDataInputStream *)initWithData:(const NSData *)data;
- (void) dealloc;

- (void)reset;
- (void)skipBytes:(size_t)byteCount;
- (Size)availableBytes;
- (BOOL)reachedEOF;

- (SInt16)readShort;
- (unsigned char)readUnsignedByte;
- (char)readByte;
- (UInt16)readUnsignedShort;
- (int)readInt;

- (void)readToBuffer:(void *)buffer length:(Size)byteCount;
- (NSString *)readUTF;
@end
