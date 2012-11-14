//
//  AmaxLocationBundle.h
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxDataInputStream.h"

@interface AmaxLocationBundle : NSObject
{
    int recordCount;
    int* recordLengths;
    AmaxDataInputStream *locStream;
}

- (id)initWithFilePath:(NSString *)filePath;
- (void) dealloc;
- (Size) extractLocationByIndex:(int)index intoBuffer:(void *)destBuffer;

@end
