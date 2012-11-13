//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmaxDataProvider.h"
#import "AmaxPrefs.h"

@implementation AmaxDataProvider

@synthesize eventCache = _eventCache;

+ (AmaxDataProvider *)sharedInstance
{
    static AmaxDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmaxDataProvider alloc] init];
        [sharedInstance setEventCache:[NSArray array]];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"dat"];
        sharedInstance->commonDataFile = [[AmaxCommonDataFile alloc] initWithFilePath:filePath];
    });
    return (AmaxDataProvider *)sharedInstance;
}

+ (NSString *)getDocumentsDirectory
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];
}

- (void) loadLocationById:(NSString *)locationId
{
    
}

- (void)saveCurrentState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"Kiev" forKey:AMAX_PREFS_KEY_LOCATION_ID];
}

- (void)restoreSavedState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *locationId = [userDefaults stringForKey:AMAX_PREFS_KEY_LOCATION_ID];
    [self loadLocationById:locationId];
}

@end
