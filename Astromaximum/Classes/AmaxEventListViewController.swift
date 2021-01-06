//
//  AmaxEventListViewController.m
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxEventListViewController : AmaxTableViewController {

    var cellNibName: String = ""
    
    @IBOutlet weak var mSubtitle: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mSwitchModeButton: UIBarButtonItem!

    var mExtRangeDataProvider: AmaxDataProvider?

    var detailItem: AmaxSummaryItem?
    var extRangeItem: AmaxSummaryItem?
    var extRangeMode = false
    
    @IBOutlet weak var tvCell: AmaxTableCell?

    override func updateDisplay() -> Bool {
        if let dp = mDataProvider {
            title = dp.currentDateString()
            //TODO: extra calculation when the controller appears
            detailItem = dp.calculateFor(eventType: detailItem!.mKey, extRange: extRangeMode)
            mCurrentTime = dp.getCurrentTime()
            mCustomTime = dp.getCustomTime()
            updateSubtitle()
            mTableView.reloadData()
       }
        return true
    }

    func updateSubtitle() {
        let textId = String(format:"%d", sourceItem()!.mKey.rawValue)
        var sub = NSLocalizedString(textId, tableName: "EventListTitle", comment: "")
        if extRangeMode {
            var mode = ""
            switch detailItem?.extendedRangeMode() {
            case .oneDay:
                mode = "OneDay"
            case .twoDays:
                mode = "TwoDays"
            case .month:
                mode = "Month"
            case .year:
                mode = "Year"
            default:
                mode = "None"
            }
            sub += " (" + NSLocalizedString(mode, tableName: "EventListTitle", comment: "") + ")"
        }
        mSubtitle.text = sub
    }
    
    func configureView() {
        navigationItem.title = NSLocalizedString("event_list_title", comment: "")
    }

    init(nibName: String, bundle nibBundleOrNil: Bundle) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
        mExtRangeDataProvider = AmaxDataProvider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellNibName)
        if cell == nil {
            Bundle.main.loadNibNamed(cellNibName, owner: self, options: nil)
            cell = tvCell
            tvCell = nil
            cell?.accessoryType = .none
        }
        // Configure the cell.
        let event = sourceItem()!.mEvents[indexPath.row]
        let si = AmaxSummaryItem(key: sourceItem()!.mKey, events: [event])
        let c = cell as! AmaxTableCell
        c.summaryItem = si
        _ = c.calculateActiveEvent(customTime: mCustomTime, currentTime: mCurrentTime)
        c.configure(extRangeMode, false)
        return cell!
    }

    // Customize the number of sections in the table view.
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sourceItem()!.mEvents.count
        return count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let e = sourceItem()!.mEvents[indexPath.row]
        showInterpreterFor(event: e, type: e.mEvtype)
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if updateDisplay() {
            mSwitchModeButton.isEnabled = detailItem?.extendedRangeMode() != AmaxSummaryItem.ExtendedRangeMode.none
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToActive()
    }
    
    @IBAction func switchMode(_ sender: AnyObject!) {
        extRangeMode = !extRangeMode
        if extRangeMode && extRangeItem == nil {
            mExtRangeDataProvider?.mLocationDataFile = mDataProvider?.mLocationDataFile
            mExtRangeDataProvider?.setExtRange(mode: (detailItem?.extendedRangeMode())!, provider: mDataProvider!)
            extRangeItem = mExtRangeDataProvider?.calculateFor(eventType: detailItem!.mKey, extRange: true)
        }
        updateSubtitle()
        mTableView.reloadData()
        scrollToActive()
    }
    
    func sourceItem() -> AmaxSummaryItem? {
        return extRangeMode ? extRangeItem : detailItem
    }
    
    func scrollToActive() {
        if extRangeMode {
            let eventIndex = extRangeItem!.activeEventPosition(customTime: -1, currentTime: mDataProvider!.getCurrentTime())
            if eventIndex != -1 {
                let path = IndexPath(row: eventIndex, section: 0)
                mTableView.scrollToRow(at: path, at: .middle, animated: true)
            }
        }
    }
    
    @IBAction func goToPreviousDate(_ sender: AnyObject!) {
        if mDataProvider!.changeDate(deltaDays: -1) {
            title = mDataProvider?.currentDateString()
            _ = updateDisplay()
        }
    }

    @IBAction func goToNextDate(_ sender: AnyObject!) {
        if mDataProvider!.changeDate(deltaDays: 1) {
            title = mDataProvider?.currentDateString()
            _ = updateDisplay()
        }
    }
}
