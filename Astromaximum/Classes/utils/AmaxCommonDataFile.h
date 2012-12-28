//
//  AmaxCommonDataFile.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AmaxDataInputStream;

@interface AmaxCommonDataFile : NSObject
{
    void *customData;
}
@property int startYear;
@property int startMonth;
@property int startDay;
@property int dayCount;
@property (readonly, strong, nonatomic) AmaxDataInputStream *mData;

- (id)initWithFilePath:(NSString *)filePath;
- (void) dealloc;

@end
