//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxTableViewController : AmaxBaseViewController, UITableViewDelegate, UITableViewDataSource/*, UIPageViewControllerDataSource*/ {

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    /*func showInterpreterFor(event: AmaxEvent, type: AmaxEventType, title: String = "") {
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
    }*/

}
