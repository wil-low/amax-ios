//
//  AmaxPrefs.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

let AMAX_PREFS_KEY_LOCATION_ID = "location_id"
let AMAX_PREFS_KEY_LOCATION_LIST = "location_list"
let AMAX_PREFS_KEY_CURRENT_DATE = "current_date"

func getLocations() -> [String: Any]?
{
    let userDefaults = UserDefaults.standard
    let result = userDefaults.dictionary(forKey: AMAX_PREFS_KEY_LOCATION_LIST)
    return result
}
