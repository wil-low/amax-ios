//
//  AmaxDateSelectController.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxPageController : UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!

    @IBOutlet var mSubtitle: UILabel!
    @IBOutlet var mPlaceholder: UIView!
    @IBOutlet var mToolbar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.setViewControllers([viewControllerAt(index: 1)!], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = mPlaceholder.bounds
        mPlaceholder.removeFromSuperview()
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        /*pageViewController.view.topAnchor.constraint(equalTo: mSubtitle.bottomAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: mToolbar.topAnchor).isActive = true*/
        pageViewController.didMove(toParent: self)
    }
    
    func viewControllerAt(index: Int) -> UIViewController? {
        var ctrl: AmaxBaseViewController?
        switch (index) {
        case PAGE_SUMMARY:
            ctrl = AmaxSummaryViewController(nibName: "AmaxSummaryViewController", bundle: nil)
        case PAGE_START:
            ctrl = AmaxStartPageViewController(nibName: "AmaxStartPageViewController", bundle: nil)
        case PAGE_PLANET_AXIS:
            ctrl = AmaxPlanetAxisController(nibName: "AmaxPlanetAxisController", bundle: nil)
        default:
            break
        }
        ctrl?.pageIndex = index
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
}
