//
//  AmaxLocationBundle.h
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AmaxDataInputStream;

@interface AmaxLocationBundle : NSObject
{
    int* recordLengths;
    AmaxDataInputStream *locStream;
}
@property int mRecordCount;


- (id)initWithFilePath:(NSString *)filePath;
- (void) dealloc;
- (Size) extractLocationByIndex:(int)index intoData:(NSData *)data;

@end
