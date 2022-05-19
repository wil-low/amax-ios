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
    private var mCustomTimeChanged = false
    @IBOutlet weak var _mTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var tvCell: UITableViewCell!
    var locationListController: AmaxLocationListController!
    var helpTopicsController: AmaxHelpTopicsController!

    let CELL_LOCATION_NAME = 0
    let CELL_SHOW_CRITICAL_DEGREEES = 1
    let CELL_IS_CUSTOM_TIME = 2
    let CELL_HELP_TOPICS = 3

    let AmaxSettingsXibNames = [
        "LocationNameCell",
        "CriticalDegreesCell",
        "CustomTimeSwitchCell",
        "HelpTopicsCell",
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
        mCustomTimeChanged = false
        _mTableView.reloadData()
    }

    override func viewDidDisappear(_ animated:Bool) {
        if mCustomTimeChanged {
            if let topVC = UIApplication.shared.topMostViewController() as? AmaxPageController {
                topVC.currentController().cachedStartTime = -1  // to force update
                _ = topVC.currentController().updateDisplay()
            }
        }
    }

    // Customize the number of sections in the table view.
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 4
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
                c.detailTextLabel?.text = String(format: "%02d:%02d",
                                                 AmaxDataProvider.sharedInstance.mCustomHour,
                                                 AmaxDataProvider.sharedInstance.mCustomMinute)

                let switchView = UISwitch(frame: CGRect.zero)
                c.accessoryView = switchView
                switchView.setOn(mDataProvider.mUseCustomTime, animated: false)
                switchView.addTarget(self, action: #selector(self.customTimeSwitchChanged(sender:)), for: .valueChanged)
            default:
                break
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch(indexPath.row) {
        case CELL_LOCATION_NAME:
            if locationListController == nil {
                locationListController = AmaxLocationListController(nibName: "AmaxLocationListController", bundle: nil)
            }
            self.navigationController?.pushViewController(locationListController, animated: true)
        case CELL_HELP_TOPICS:
            if helpTopicsController == nil {
                helpTopicsController = AmaxHelpTopicsController(nibName: "AmaxHelpTopicsController", bundle: nil)
            }
            self.navigationController?.pushViewController(helpTopicsController, animated: true)
        case CELL_IS_CUSTOM_TIME:
            let targetCell = self.tableView(_mTableView, cellForRowAt: IndexPath(row: indexPath.row, section: 0))
            let sw = targetCell.accessoryView as! UISwitch
            if sw.isOn {
                showCustomTimeDialog(cell: targetCell, keepOn: true)
            }
        default:
            break
        }
    }

    @IBAction func criticalDegreesSwitchChanged(sender: AnyObject!) {
        mDataProvider.mShowCriticalDegrees = sender.isOn
        mDataProvider.saveCurrentState()
    }

    @IBAction func customTimeSwitchChanged(sender: AnyObject!) {
        let targetCell = tableView(_mTableView, cellForRowAt: IndexPath(row: CELL_IS_CUSTOM_TIME, section: 0))
        if sender.isOn {
            showCustomTimeDialog(cell: targetCell, keepOn: false)
        }
        else {
            mDataProvider.mUseCustomTime = false
            mCustomTimeChanged = true
            mDataProvider.saveCurrentState()
        }
    }
    
    func showCustomTimeDialog(cell: UITableViewCell, keepOn: Bool) {
        let dpd = DatePickerDialog()
        dpd.show(  NSLocalizedString("time_picker_title", comment:"")
                 , doneButtonTitle: NSLocalizedString("date_picker_done", comment:"")
                 , cancelButtonTitle: NSLocalizedString("date_picker_cancel", comment:"")
                 , defaultDate: mDataProvider.getCustomTimeForPicker()
                 , datePickerMode: .time) { time in
            if let tm = time {
                self.mDataProvider.setCustomTime(from: tm)
                self.mDataProvider.mUseCustomTime = true
            }
            else {
                if !keepOn {
                    self.mDataProvider.mUseCustomTime = false
                }
            }
            self._mTableView.reloadData()
            self.mCustomTimeChanged = true
            self.mDataProvider.saveCurrentState()
        }
    }
}
