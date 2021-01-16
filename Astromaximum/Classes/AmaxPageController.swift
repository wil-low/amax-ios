//
//  AmaxDateSelectController.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxPageController : UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let startingPage = PAGE_START
    var pageViewController: UIPageViewController!

    @IBOutlet weak var mPlaceholder: UIView!
    @IBOutlet weak var mToolbar: UIToolbar!
    @IBOutlet weak var mCornerTime: UILabel!
    @IBOutlet weak var mSelectedViewTime: UILabel!

    var mDataProvider: AmaxDataProvider?
    var mFlippingInProgress = false
    
    var controllers = [AmaxBaseViewController?]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = mDataProvider?.currentDateString()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AmaxBaseViewController.interpreterController!.view.layoutSubviews()
        mDataProvider = AmaxDataProvider.sharedInstance
        for _ in PAGE_SUMMARY ... PAGE_DECUMBITURE {
            controllers.append(nil)
        }
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllerAt(index: startingPage)!], direction: .forward, animated: true, completion: nil)
        mPlaceholder.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let margins = mPlaceholder.layoutMarginsGuide
        pageViewController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
    
    func viewControllerAt(index: Int) -> UIViewController? {
        if let ctrl = controllers[index] {
            return ctrl
        }
        var ctrl: AmaxBaseViewController?
        switch (index) {
        case PAGE_SUMMARY:
            ctrl = AmaxSummaryViewController(nibName: "AmaxSummaryViewController", bundle: nil)
        case PAGE_START:
            ctrl = AmaxStartPageViewController(nibName: "AmaxStartPageViewController", bundle: nil)
        case PAGE_PLANET_AXIS:
            ctrl = AmaxPlanetAxisController(nibName: "AmaxPlanetAxisController", bundle: nil)
        case PAGE_DECUMBITURE:
            ctrl = AmaxDecumbitureController(nibName: "AmaxDecumbitureController", bundle: nil)
        default:
            break
        }
        ctrl?.pageIndex = index
        ctrl?.mParent = self
        controllers[index] = ctrl
        return ctrl
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! AmaxBaseViewController).pageIndex
        if index == 0 {
            return nil
        }
        index -= 1
        return viewControllerAt(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! AmaxBaseViewController).pageIndex
        if index == PAGE_COUNT - 1 {
            return nil
        }
        index += 1
        return viewControllerAt(index: index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return PAGE_COUNT
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @IBAction func goToToday(_ sender: AnyObject!) {
        if mFlippingInProgress {
            return
        }
        mDataProvider?.setTodayDate()
        title = mDataProvider?.currentDateString()
        _ = currentController().updateDisplay()
        /*mSubtitle.text = String(format: "%@, %@",
                      mDataProvider!.getHighlightTimeString(),
                      mDataProvider!.locationName())*/
    }

    @IBAction func goToPreviousDate(_ sender: AnyObject!) {
        if mFlippingInProgress {
            return
        }
        if mDataProvider!.changeDate(deltaDays: -1) {
            title = mDataProvider?.currentDateString()
            _ = currentController().updateDisplay()
        }
    }

    @IBAction func goToNextDate(_ sender: AnyObject!) {
        if mFlippingInProgress {
            return
        }
        if mDataProvider!.changeDate(deltaDays: 1) {
            title = mDataProvider?.currentDateString()
            _ = currentController().updateDisplay()
        }
    }

    @IBAction func selectDate(_ sender: AnyObject!) {
        if mFlippingInProgress {
            return
        }
        if (AmaxBaseViewController.dateSelectController == nil) {
            AmaxBaseViewController.dateSelectController = AmaxDateSelectController(nibName: "AmaxDateSelectController", bundle: Bundle.main)
        }
        let date = mDataProvider!.currentDate()
        AmaxBaseViewController.dateSelectController!.datePicker?.date = date
        navigationController?.pushViewController(AmaxBaseViewController.dateSelectController!, animated: true)
    }

    @IBAction func showSettings(_ sender: AnyObject!) {
        if mFlippingInProgress {
            return
        }
        if (AmaxBaseViewController.settingsController == nil) {
            AmaxBaseViewController.settingsController = AmaxSettingsController(nibName: "AmaxSettingsController", bundle: nil)
        }
        self.navigationController?.pushViewController(AmaxBaseViewController.settingsController!, animated: true)
    }

    func currentController() -> AmaxBaseViewController {
        return pageViewController.viewControllers?.first as! AmaxBaseViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo: [UIViewController]) {
        mFlippingInProgress = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating: Bool, previousViewControllers: [UIViewController], transitionCompleted: Bool) {
        mFlippingInProgress = false
    }
}
