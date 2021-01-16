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
let PAGE_DECUMBITURE = 3
let PAGE_COUNT = 4

class AmaxBaseViewController : UIViewController {

    var pageIndex = -1
    var mCustomTime: Int = 0
    var mCurrentTime: Int = 0
    var mDataProvider: AmaxDataProvider?
    var mParent: AmaxPageController?
    var cachedStartTime = -1
    var cachedLocationId = ""
    var cachedHasPeriod: Bool?
    var cachedYear: Int?
    
    @IBOutlet weak var mDataMissingView: DataMissingView!
    @IBOutlet weak var mDataAvailableView: UIView!

    static var eventListViewController: AmaxEventListViewController?
    static var interpreterController: AmaxInterpreterController?

    static var settingsController: AmaxSettingsController?
    static var dateSelectController: AmaxDateSelectController?

    func updateDisplay() -> Bool {
        if let dp = mDataProvider {
            let hasPeriod = dp.hasPeriod()
            if (cachedHasPeriod == nil) || (cachedHasPeriod! != hasPeriod) || (cachedYear == nil) || (cachedYear != dp.mCurrentYear) {
                cachedHasPeriod = hasPeriod
                cachedYear = dp.mCurrentYear
                mDataMissingView.isHidden = hasPeriod
                mDataAvailableView.isHidden = !hasPeriod
                if let parent = mParent {
                    if !hasPeriod {
                        mDataMissingView.setBuyButtonText(year: dp.mCurrentYear)
                        parent.mCornerTime.text = ""
                        parent.mSelectedViewTime.text = ""
                    }
                }
            }
            return hasPeriod
        }
        return true;
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
    
    @IBAction func buyPressed(_ sender: AnyObject?) {
        print("Buy pressed")
    }
}
