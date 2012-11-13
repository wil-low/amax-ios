//
//  AmaxCommonDataFile.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmaxCommonDataFile.h"

@implementation AmaxCommonDataFile

- (id)initWithFilePath:(NSString *)filePath;
{
    data = [NSData dataWithContentsOfFile:filePath];
    return self;
}

@end
