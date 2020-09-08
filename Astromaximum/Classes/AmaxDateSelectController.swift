//
//  AmaxDateSelectController.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxDateSelectController : UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker?

    override init(nibName: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibName, bundle:nibBundleOrNil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(self.didSelectDate(sender:)))
        title = NSLocalizedString("pick_date", comment: "Pick date")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker?.minimumDate = Date(timeIntervalSince1970: TimeInterval(AmaxDataProvider.sharedInstance.mStartJD))
        datePicker?.maximumDate = Date(timeIntervalSince1970: TimeInterval(AmaxDataProvider.sharedInstance.mFinalJD))
        let date = AmaxDataProvider.sharedInstance.currentDate()
        //print(date)
        datePicker!.setDate(date, animated: false)
    }
    
    @IBAction func didSelectDate(sender:AnyObject!) {
        AmaxDataProvider.sharedInstance.setDate(from: datePicker!.date)
        self.navigationController?.popViewController(animated: true)
    }
}
