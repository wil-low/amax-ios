//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxTableViewController : AmaxBaseViewController, UITableViewDelegate, UITableViewDataSource/*, UIPageViewControllerDataSource*/ {

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
