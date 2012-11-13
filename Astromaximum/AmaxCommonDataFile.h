//
//  AmaxCommonDataFile.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmaxCommonDataFile : NSObject
{
    NSData *data;
}
- (id)initWithFilePath:(NSString *)filePath;

@end
