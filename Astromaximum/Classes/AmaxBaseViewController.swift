//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

let PAGE_SUMMARY = 0
let PAGE_START = 1
let PAGE_PLANET_AXIS = 2
let PAGE_COUNT = 3

class AmaxBaseViewController : UIViewController {

    var pageIndex = -1
    var mCustomTime: Int = 0
    var mCurrentTime: Int = 0
    var mDataProvider: AmaxDataProvider?
    var mParent: AmaxPageController?
    var cachedStartTime = -1
    var cachedLocationId = ""

    static var eventListViewController: AmaxEventListViewController?
    static var interpreterController: AmaxInterpreterController?

    static var settingsController: AmaxSettingsController?
    static var dateSelectController: AmaxDateSelectController?

    func updateDisplay() {
    }

    func showEventListFor(si: AmaxSummaryItem, xib xibName: String!) {
        if si.mEvents.count == 0 {
            return
        }
        
        if (AmaxBaseViewController.eventListViewController == nil) {
            AmaxBaseViewController.eventListViewController = AmaxEventListViewController(nibName: "AmaxEventListViewController", bundle: Bundle.main)
        }
        
        if let el = AmaxBaseViewController.eventListViewController {
            el.detailItem = si
            el.cellNibName = xibName
            el.extRangeMode = false
            el.extRangeItem = nil
            navigationController?.pushViewController(el, animated: true)
        }
    }

    func showInterpreterFor(event: AmaxEvent, type: AmaxEventType, title: String = "") {
        let iProvider = AmaxInterpretationProvider.sharedInstance
        if let text = iProvider.getTextFor(event: event, type: type) {
            if let ic = AmaxBaseViewController.interpreterController {
                ic.interpreterText = text
                ic.interpreterEvent = event
                ic.eventType = type
                ic.title = title
                navigationController?.pushViewController(ic, animated: true)
            }
        }
    }

    func skipUpdate(_ dp: AmaxDataProvider) -> Bool {
        if cachedStartTime == dp.mStartTime && cachedLocationId == dp.mLocationId {
            return true
        }
        cachedStartTime = dp.mStartTime
        cachedLocationId = dp.mLocationId
        return false
    }
}
