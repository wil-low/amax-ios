//
//  AmaxPrefs.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxPrefs.h"

NSString * const AMAX_PREFS_KEY_LOCATION_ID = @"location_id";
NSString * const AMAX_PREFS_KEY_LOCATION_LIST = @"location_list";
NSString * const AMAX_PREFS_KEY_CURRENT_DATE = @"current_date";

NSDictionary* getLocations()
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* result = [userDefaults dictionaryForKey:AMAX_PREFS_KEY_LOCATION_LIST];
    return result;
}
