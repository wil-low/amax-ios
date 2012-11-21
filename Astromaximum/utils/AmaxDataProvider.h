//
//  AmaxDataProvider.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxCommonDataFile.h"
#import "AmaxTypes.h"
#import "AmaxEvent.h"

@interface AmaxDataProvider : NSObject

{
    AmaxCommonDataFile * commonDataFile;
    NSString * documentsDirectory;
    AmaxEvent * mEvents[100];
}

+ (AmaxDataProvider *)sharedInstance;

- (void)saveCurrentState;
- (void)restoreSavedState;

@property (strong, nonatomic) NSArray * eventCache;
@property long mStartJD;
@property long mFinalJD;
@end
