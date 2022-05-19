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
let AMAX_PREFS_KEY_CRITICAL_DEGREES = "critical_degrees"
let AMAX_PREFS_KEY_USE_CUSTOM_TIME = "use_custom_time"
let AMAX_PREFS_KEY_CUSTOM_HOUR = "custom_hour"
let AMAX_PREFS_KEY_CUSTOM_MINUTE = "custom_minute"

func getLocations() -> [String: Any]?
{
    let userDefaults = UserDefaults.standard
    let result = userDefaults.dictionary(forKey: AMAX_PREFS_KEY_LOCATION_LIST)
    return result
}

func runStartingController(in window: UIWindow) {
    _ = AmaxInterpretationProvider.sharedInstance
    AmaxBaseViewController.interpreterController = AmaxInterpreterController(nibName: "AmaxInterpreterController", bundle: nil);

    var viewController: UIViewController
    viewController = createStartingController()
    window.rootViewController = UINavigationController(rootViewController: viewController)
}

let dimmedColor = ColorCompatibility.systemGray2.cgColor

func addBorders(to view: UIView) {
    //view.layer.cornerRadius = 10
    //view.layer.masksToBounds = true
    view.layer.borderWidth = 0.8
    view.layer.borderColor = dimmedColor
}

func createStartingController() -> UIViewController {
    return AmaxPageController(nibName: "AmaxPageController", bundle: nil)
    //return AmaxBaseViewController(nibName: "XibTestController", bundle: nil)
}

extension UIScrollView {
    func resizeScrollViewContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.contentSize = contentRect.size
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {

        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
    }

        return self
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
