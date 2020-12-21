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
    static var eventListViewController: AmaxEventListViewController?
    static var interpreterController: AmaxInterpreterController?

    static var settingsController: AmaxSettingsController?
    static var dateSelectController: AmaxDateSelectController?

    @IBOutlet weak var mSubtitle: UILabel!
    
    /*var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        //restartAction(self)
        addChild(pageViewController)

        let swipe1 = UISwipeGestureRecognizer(target: self, action: #selector(self.goToPreviousDate(_:)))
        swipe1.direction = [.left]
        swipe1.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipe1)

        let swipe2 = UISwipeGestureRecognizer(target: self, action: #selector(self.goToNextDate(_:)))
        swipe2.direction = [.right]
        swipe2.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipe2)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return pageViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return pageViewController
    }*/
    
    func updateDisplay() {
    }

    @IBAction func goToToday(_ sender: AnyObject!) {
        mDataProvider?.setTodayDate()
        updateDisplay()
    }

    @IBAction func goToPreviousDate(_ sender: AnyObject!) {
        if mDataProvider!.changeDate(deltaDays: -1) {
            updateDisplay()
        }
    }

    @IBAction func goToNextDate(_ sender: AnyObject!) {
        if mDataProvider!.changeDate(deltaDays: 1) {
            updateDisplay()
        }
    }

    @IBAction func selectDate(_ sender: AnyObject!) {
        if (AmaxBaseViewController.dateSelectController == nil) {
            AmaxBaseViewController.dateSelectController = AmaxDateSelectController(nibName: "AmaxDateSelectController", bundle: Bundle.main)
        }
        let date = mDataProvider!.currentDate()
        AmaxBaseViewController.dateSelectController!.datePicker?.date = date
        navigationController?.pushViewController(AmaxBaseViewController.dateSelectController!, animated: true)
    }

    @IBAction func showSettings(_ sender: AnyObject!) {
        if (AmaxBaseViewController.settingsController == nil) {
            AmaxBaseViewController.settingsController = AmaxSettingsController(nibName: "AmaxSettingsController", bundle: nil)
        }
        self.navigationController?.pushViewController(AmaxBaseViewController.settingsController!, animated: true)
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

}
