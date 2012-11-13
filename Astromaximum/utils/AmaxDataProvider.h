//
//  AmaxDataProvider.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxCommonDataFile.h"

@interface AmaxDataProvider : NSObject

{
    AmaxCommonDataFile *commonDataFile;
}

+ (AmaxDataProvider *)sharedInstance;
+ (NSString *)getDocumentsDirectory;

- (void)saveCurrentState;
- (void)restoreSavedState;

@property (strong, nonatomic) NSArray * eventCache;

@end
