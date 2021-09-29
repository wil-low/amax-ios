//
//  AmaxSettingsController.m
//  Astromaximum
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxSettingsController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var mDataProvider:AmaxDataProvider!
    @IBOutlet weak var _mTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var tvCell: UITableViewCell!
    var locationListController: AmaxLocationListController!
    var helpTopicsController: AmaxHelpTopicsController!

    let CELL_LOCATION_NAME = 0
    let CELL_SHOW_CRITICAL_DEGREEES = 1
    let CELL_HELP_TOPICS = 2
    let CELL_IS_CUSTOM_TIME = 102
    let CELL_HIGHIGHT_TIME = 103

    let AmaxSettingsXibNames = [
        "LocationNameCell",
        "HelpTopicsCell",
        "CustomTimeSwitchCell"
    ]

    override init(nibName: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        title = NSLocalizedString("Settings", comment: "Settings")
        mDataProvider = AmaxDataProvider.sharedInstance
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _mTableView.reloadData()
    }

    // Customize the number of sections in the table view.
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 3
    }

    // Customize the appearance of table view cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = AmaxSettingsXibNames[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .disclosureIndicator
        }
        guard let c = cell else {
            return cell!
        }
        switch (indexPath.row) {
            case CELL_LOCATION_NAME:
                c.textLabel?.text = NSLocalizedString("Current_location", comment: "Current location")
                c.detailTextLabel?.text = mDataProvider.locationName()
            case CELL_SHOW_CRITICAL_DEGREEES:
                c.textLabel?.text = NSLocalizedString("pref_critical_degrees", comment: "")
                let switchView = UISwitch(frame: CGRect.zero)
                c.accessoryView = switchView
                switchView.setOn(mDataProvider.mShowCriticalDegrees, animated: false)
                switchView.addTarget(self, action: #selector(self.criticalDegreesSwitchChanged(sender:)), for: .valueChanged)
            case CELL_HELP_TOPICS:
                c.textLabel?.text = NSLocalizedString("help_title", comment: "Help list")
            case CELL_IS_CUSTOM_TIME:
                c.textLabel?.text = NSLocalizedString("Highlight_time", comment: "Highlight time")
                c.detailTextLabel?.text = "88:88"
                let switchView = UISwitch(frame: CGRect.zero)
                c.accessoryView = switchView
                switchView.setOn(false, animated: false)
                switchView.addTarget(self, action: #selector(self.customTimeSwitchChanged(sender:)), for: .valueChanged)
            default:
                break
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == CELL_LOCATION_NAME {
            if locationListController == nil {
                locationListController = AmaxLocationListController(nibName: "AmaxLocationListController", bundle: nil)
            }
            self.navigationController?.pushViewController(locationListController, animated: true)
        }
        else if indexPath.row == CELL_HELP_TOPICS {
            if helpTopicsController == nil {
                helpTopicsController = AmaxHelpTopicsController(nibName: "AmaxHelpTopicsController", bundle: nil)
            }
            self.navigationController?.pushViewController(helpTopicsController, animated: true)
        }
    }

    @IBAction func criticalDegreesSwitchChanged(sender: AnyObject!) {
        mDataProvider.mShowCriticalDegrees = sender.isOn
        mDataProvider.saveCurrentState()
    }

    @IBAction func customTimeSwitchChanged(sender: AnyObject!) {
        /*let targetCell = tableView(_mTableView, cellForRowAt: IndexPath(row: CELL_HIGHIGHT_TIME, section: 0))
        NSLog("Switch changed to %@\n", sender.isOn ? "YES" : "NO")
    //	self.pickerView.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];

    	// check if our date picker is already on screen
    	if pickerView.superview == nil
    	{
            view.window?.addSubview(pickerView)

    		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
    		//
    		// compute the start frame
            let screenRect = UIScreen.main.bounds
            let pickerSize = pickerView.sizeThatFits(CGSize.zero)
            let startRect = CGRect(x: 0, y: screenRect.origin.y + screenRect.size.height, width: pickerSize.width, height: pickerSize.height)
    		pickerView.frame = startRect

    		// compute the end frame
            //let pickerRect = CGRect(x: 0, y: screenRect.origin.y + screenRect.size.height - pickerSize.height, width: pickerSize.width, height: pickerSize.height)
    		
            // start the slide up animation
            
    		UIView.beginAnimations(nil, context: nil)
            UIView.animationDuration = 0.3

            // we need to perform some post operations after the animation is complete
            UIView.animationDelegate = self

            self->pickerView.frame = pickerRect

            // shrink the table vertical size to make room for the date picker
            var newFrame:CGRect = _mTableView.frame
            newFrame.size.height -= self->pickerView.frame.size.height
            _mTableView.frame = newFrame
    		UIView.commitAnimations()

    		// add the "Done" button to the nav bar
    		self.navigationItem.rightBarButtonItem = doneButton
    	}*/
    }
}
