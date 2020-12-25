//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxSummaryViewController : AmaxTableViewController {

    // sync with START_PAGE_ITEMS
    let xibNames = [
        "VocCell",
        "ViaCombustaCell",
        "MoonMoveCell",
        "PlanetHourCell",
        "MoonSignCell",
        "RetrogradeSetCell",
        "AspectSetCell",
        "SunDegreeCell",
        "TithiCell",
    ]

    let START_PAGE_ITEMS = [
        EV_VOC,
        EV_VIA_COMBUSTA,
        EV_MOON_MOVE,
        EV_PLANET_HOUR,
        EV_MOON_SIGN,
        EV_RETROGRADE,
        EV_ASP_EXACT,
        EV_SUN_DEGREE,
        EV_TITHI,
    ]

    private var mTitleDate: String = ""

    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak  var mToolbar: UIToolbar!
    @IBOutlet weak  var tvCell: AmaxTableCell!

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
        //let backButton = UIBarButtonItem(title: NSLocalizedString("Summary", comment: "Summary"), style: .plain, target: nil, action: nil)
        //navigationItem.backBarButtonItem = backButton
        AmaxBaseViewController.interpreterController!.view.layoutSubviews()
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
        return xibNames.count
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
            (cell as! AmaxTableCell).controller = self
        }

        // Configure the cell.
        let c = cell as! AmaxTableCell
        c.summaryItem = si
        let pos = c.calculateActiveEvent(customTime: mCustomTime, currentTime: mCurrentTime)
        c.activeEventPosition = pos
        c.configure(false, true)

        if si.mEvents.count > 0 {
            switch si.mKey {
            case EV_ASP_EXACT,
                 EV_RETROGRADE,
                 EV_MOON_MOVE:
                cell?.accessoryType = .disclosureIndicator
            default:
                cell?.accessoryType = .detailDisclosureButton
            }
        }
        else {
            cell?.accessoryType = .none
        }

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let si = mDataProvider?.mEventCache[indexPath.row] {
            showEventListFor(si: si, xib: xibNames[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let c = tableView.cellForRow(at: indexPath) as! AmaxTableCell
        if let e = c.getActiveEvent() {
            showInterpreterFor(event: e, type: e.mEvtype)
        }
    }

    override func updateDisplay() {
        if let dp = mDataProvider {
            if skipUpdate(dp) {
                return
            }
            title = dp.currentDateString()
            dp.prepareCalculation()
            dp.calculateAll(types: START_PAGE_ITEMS)
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mTableView.reloadData()
        }
    }
}
