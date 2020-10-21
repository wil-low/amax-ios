//
//  AmaxPrefs.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation
import UIKit

let AMAX_PREFS_KEY_LOCATION_ID = "location_id"
let AMAX_PREFS_KEY_LOCATION_LIST = "location_list"
let AMAX_PREFS_KEY_CURRENT_DATE = "current_date"

func getLocations() -> [String: Any]?
{
    let userDefaults = UserDefaults.standard
    let result = userDefaults.dictionary(forKey: AMAX_PREFS_KEY_LOCATION_LIST)
    return result
}

func runStartingController(in window: UIWindow) {
    _ = AmaxInterpretationProvider.sharedInstance
    AmaxBaseViewController.interpreterController = AmaxInterpreterController(nibName: "AmaxInterpreterController", bundle: nil);

    var viewController: AmaxBaseViewController
    if true {
        viewController = AmaxSummaryViewController(nibName: "AmaxSummaryViewController", bundle: nil)
    }
    else {
        viewController = AmaxStartPageViewController(nibName: "AmaxStartPageViewController", bundle: nil)
    }
    window.rootViewController = UINavigationController(rootViewController: viewController)
}
