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
let AMAX_PREFS_KEY_START_PAGE_AS_GRID = "start_page_as_grid"
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

    let useSummaryView = UserDefaults.standard.bool(forKey: AMAX_PREFS_KEY_START_PAGE_AS_GRID)

    var viewController: AmaxBaseViewController
    viewController = createStartingController(useSummaryView: useSummaryView)
    window.rootViewController = UINavigationController(rootViewController: viewController)
}

func createStartingController(useSummaryView: Bool) -> AmaxBaseViewController {
    //return AmaxBaseViewController(nibName: "XibTestController", bundle: nil)
    return AmaxPlanetAxisController(nibName: "AmaxPlanetAxisController", bundle: nil)
    if useSummaryView {
        return AmaxSummaryViewController(nibName: "AmaxSummaryViewController", bundle: nil)
    }
    return AmaxStartPageViewController(nibName: "AmaxStartPageViewController", bundle: nil)
}
