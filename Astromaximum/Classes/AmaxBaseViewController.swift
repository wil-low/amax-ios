//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxBaseViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mDataProvider: AmaxDataProvider?
    static var interpreterController: AmaxInterpreterController?

    func updateDisplay() {

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    @IBAction func goToPreviousDate(_ sender: AnyObject!) {
        mDataProvider?.changeDate(deltaDays: -1)
        updateDisplay()
    }

    @IBAction func goToNextDate(_ sender: AnyObject!) {
        mDataProvider?.changeDate(deltaDays: 1)
        updateDisplay()
    }

    func showInterpreterFor(event: AmaxEvent) {
        let iProvider = AmaxInterpretationProvider.sharedInstance
        if let text = iProvider.getTextFor(event: event) {
            AmaxBaseViewController.interpreterController?.interpreterText = text
            AmaxBaseViewController.interpreterController?.interpreterEvent = event
            navigationController?.pushViewController(AmaxBaseViewController.interpreterController!, animated: true)
        }
    }
}
