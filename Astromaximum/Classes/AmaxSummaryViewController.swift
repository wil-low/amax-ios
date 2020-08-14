//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

// sync with START_PAGE_ITEM_SEQ
let xibNames = [
    "VocCell",
    "MoonMoveCell",
    "PlanetHourCell",
    "MoonSignCell",
    "RetrogradeSetCell",
    "AspectSetCell",
    "ViaCombustaCell",
    "SunDegreeCell",
    "TithiCell",
]

class AmaxSummaryViewController : AmaxBaseViewController {

    private var mTitleDate: String = ""

    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak  var mToolbar: UIToolbar!
    @IBOutlet weak  var tvCell: AmaxTableCell!

    var mCustomTime: Int = 0
    var mCurrentTime: Int = 0
    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?
    var dateSelectController: AmaxDateSelectController?

    override init(nibName:String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: NSLocalizedString("Summary", comment: "Summary"), style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDisplay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
    	super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
    	super.viewDidDisappear(animated)
    }

    // Customize the number of sections in the table view.
    func numberOfSections(in: UITableView!) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataProvider!.mEventCache.count
    }

    // Customize the appearance of table view cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = xibNames[indexPath.row]

        let si = mDataProvider!.mEventCache[indexPath.row]

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
            cell = tvCell
            tvCell = nil
            cell?.accessoryType = si.mEvents.count > 0 && si.mKey != EV_ASP_EXACT ? .detailDisclosureButton : .none
            (cell as! AmaxTableCell).controller = self
        }

        // Configure the cell.
        si.calculateActiveEvent(customTime: mCustomTime, currentTime: mCurrentTime)
        (cell as! AmaxTableCell).configure(si)
        return cell!
    }

    /*
    // Override to support rearranging the table view.
    - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
    {
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
    {
        // Return NO if you do not want the item to be re-orderable.
        return YES;
    }
    */

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String! {
        return String(format: "%@, %@",
                      mDataProvider!.getHighlightTimeString(),
                      mDataProvider!.locationName())
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let si = mDataProvider?.mEventCache[indexPath.row]
        if let e = si?.mActiveEvent {
            showInterpreterFor(event: e)
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let si = mDataProvider?.mEventCache[indexPath.row]
        showEventListFor(si: si, xib: xibNames[indexPath.row])
    }

    func showEventListFor(si: AmaxSummaryItem!, xib xibName:String!) {
        if (eventListViewController == nil) {
            eventListViewController = AmaxEventListViewController(nibName:"AmaxEventListViewController", bundle: Bundle.main)
        }
        eventListViewController?.detailItem = si
        eventListViewController?.cellNibName = xibName
        navigationController?.pushViewController(eventListViewController!, animated: true)
    }

    override func updateDisplay() {
        if let dp = mDataProvider {
            title = dp.currentDateString()
            dp.prepareCalculation()
            dp.calculateAll()
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mTableView.reloadData()
        }
    }

    @IBAction func showSettings(_ sender: AnyObject!) {
        if (settingsController == nil) {
            settingsController = AmaxSettingsController(nibName:"AmaxSettingsController", bundle:nil)
        }
        self.navigationController?.pushViewController(self.settingsController!, animated:true)
    }

    @IBAction func goToToday(_ sender: AnyObject!) {
        mDataProvider?.setTodayDate()
        updateDisplay()
    }

    @IBAction func selectDate(_ sender: AnyObject!) {
        if (dateSelectController == nil) {
            dateSelectController = AmaxDateSelectController(nibName:"AmaxDateSelectController", bundle: Bundle.main)
        }
        let date = mDataProvider!.currentDate()
        dateSelectController!.datePicker?.date = date
        navigationController?.pushViewController(dateSelectController!, animated:true)
    }
}
