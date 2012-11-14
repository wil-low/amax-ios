//
//  AmaxCommonDataFile.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxDataInputStream.h"

@interface AmaxCommonDataFile : NSObject
{
    AmaxDataInputStream *data;
    void *customData;
}
@property int startYear;
@property int startMonth;
@property int startDay;
@property int dayCount;

- (id)initWithFilePath:(NSString *)filePath;
- (void) dealloc;

@end
