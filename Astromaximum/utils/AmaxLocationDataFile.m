//
//  AmaxLocationDataFile.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxLocationDataFile.h"
#import "AmaxTimezoneTransition.h"

@implementation AmaxLocationDataFile

- (id)initWithFilePath:(NSString *)filePath
{
    NSData *fullData = [NSData dataWithContentsOfFile:filePath];
    AmaxDataInputStream *dis = [[AmaxDataInputStream alloc]initWithData:fullData];
    [dis skipBytes:4]; // signature
    char version = [dis readUnsignedByte];
    if (version == 2) {
        startYear = [dis readShort];
        startMonth = [dis readUnsignedByte];
        startDay = [dis readUnsignedByte];
        dayCount = [dis readShort];
        cityId = [dis readInt]; // city id
        coords[0] = [dis readShort]; // latitude
        coords[1] = [dis readShort]; // longitude
        coords[2] = [dis readShort]; // altitude
        city = [dis readUTF]; // city
        state = [dis readUTF]; // state
        country = [dis readUTF]; // country
        timezone = [dis readUTF]; // timezone
        customData = [dis readUTF]; // custom data
        int transitionCount = [dis readUnsignedByte];
        transitions = [NSArray array];
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
        data = [[AmaxDataInputStream alloc]initWithBytes:buffer length:bufferLength];
    }
    else {
        NSLog(@"Unknown version %d", version);
    }
    return self;
}

@end
