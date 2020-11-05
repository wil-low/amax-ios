//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxTapRecognizer : UITapGestureRecognizer {
    var mEvent: AmaxEvent?
    var mEventType: AmaxEventType?
    
    init(target: Any?, action: Selector?, event: AmaxEvent, eventType: AmaxEventType) {
        super.init(target: target, action: action)
        numberOfTapsRequired = 1
        mEvent = event
        mEventType = eventType
    }
}

class AmaxStartPageViewController : AmaxBaseViewController {

    let START_PAGE_ITEMS = [
        EV_VOC,
        EV_VIA_COMBUSTA,
        EV_SUN_DAY,
        EV_MOON_DAY,
        EV_MOON_RISE,
        EV_MOON_MOVE,
        EV_PLANET_HOUR,
        EV_MOON_SIGN,
        EV_RETROGRADE,
        EV_ASP_EXACT,
        EV_SUN_DEGREE,
        EV_TITHI,
    ]

    private var mTitleDate: String = ""

    @IBOutlet weak var mVocTime: UILabel!
    @IBOutlet weak var mVcTime: UILabel!
    @IBOutlet weak var mSunDay: UILabel!
    @IBOutlet weak var mSunDegree: UILabel!
    @IBOutlet weak var mSunSign: UILabel!
    @IBOutlet weak var mSunDegreeTime: UILabel!
    @IBOutlet weak var mMoonDayStack: UIStackView!
    @IBOutlet weak var mMoonSign: UILabel!
    @IBOutlet weak var mMoonSignTime: UILabel!
    @IBOutlet weak var mMoonPhase: UIImageView!
    @IBOutlet weak var mTithiStack: UIStackView!
    @IBOutlet weak var mMoonMoveTable: UITableView!
    @IBOutlet weak var mPlanetHourTable: UITableView!

    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?
    var dateSelectController: AmaxDateSelectController?

    override init(nibName:String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
        // set static labels
        if let v = view.viewWithTag(1) {
            (v as! UILabel).text = String(format: "%c", getSymbol(TYPE_PLANET, SE_SUN.rawValue))
        }
        if let v = view.viewWithTag(2) {
            (v as! UILabel).text = String(format: "%c", getSymbol(TYPE_PLANET, SE_MOON.rawValue))
        }
        /*if let v = view.viewWithTag(3) {
            (v as! UILabel).text = String(format: "%c", getSymbol(TYPE_PLANET, SE_SUN.rawValue))
        }
        if let v = view.viewWithTag(4) {
            (v as! UILabel).text = String(format: "%c", getSymbol(TYPE_PLANET, SE_SUN.rawValue))
        }*/
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
/*
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
*/
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

    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let si = mDataProvider?.mEventCache[indexPath.row] {
            showEventListFor(si: si, xib: xibNames[indexPath.row])
        }
    }
     */

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let c = tableView.cellForRow(at: indexPath) as! AmaxTableCell
        if let e = c.getActiveEvent() {
            showInterpreterFor(event: e, type: e.mEvtype)
        }
    }

    func showEventListFor(si: AmaxSummaryItem, xib xibName: String!) {
        if si.mEvents.count == 0 {
            return
        }
        
        if (eventListViewController == nil) {
            eventListViewController = AmaxEventListViewController(nibName: "AmaxEventListViewController", bundle: Bundle.main)
        }
        
        if let el = eventListViewController {
            el.detailItem = si
            el.cellNibName = xibName
            el.extRangeMode = false
            el.extRangeItem = nil
            navigationController?.pushViewController(el, animated: true)
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

    override func updateDisplay() {
        if let dp = mDataProvider {
            title = dp.currentDateString()
            dp.prepareCalculation()
            dp.calculateAll(types: START_PAGE_ITEMS)
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mSubtitle.text = String(format: "%@, %@", dp.getHighlightTimeString(), dp.locationName())

            showEvent(label: mVocTime, dataProvider: dp, findType: EV_VOC, interpretationType: EV_VOC, string: { e in
                        e.normalizedRangeString() })
            showEvent(label: mVcTime, dataProvider: dp, findType: EV_VIA_COMBUSTA, interpretationType: EV_VIA_COMBUSTA, string: { e in
                        e.normalizedRangeString() })

            showEvent(label: mSunDay, dataProvider: dp, findType: EV_SUN_DAY, interpretationType: EV_SUN_DAY, string: { e in
                var day = e.getDegree()
                if day >= 360 {
                    day = -(day - 359)
                }
                return String(format: "%d", day)
            })
            showEvent(label: mSunDegree, dataProvider: dp, findType: EV_SUN_DEGREE, interpretationType: EV_DEGREE_PASS, string: { e in
                String(format: "%d\u{00b0} ", e.getDegree() % 30 + 1)
            })
            showEvent(label: mSunSign, dataProvider: dp, findType: EV_SUN_DEGREE, interpretationType: EV_DEGREE_PASS, string: { e in
                String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree() / 30)))
            })
            showEvent(label: mSunDegreeTime, dataProvider: dp, findType: EV_SUN_DEGREE, interpretationType: EV_DEGREE_PASS, string: { e in
                e.normalizedRangeString()
            })

            showEvent(label: mMoonSign, dataProvider: dp, findType: EV_MOON_SIGN, interpretationType: EV_SIGN_ENTER, string: { e in
                String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree())))
            })
            showEvent(label: mMoonSignTime, dataProvider: dp, findType: EV_MOON_SIGN, interpretationType: EV_SIGN_ENTER, string: { e in
                e.normalizedRangeString()
            })
            showEventStack(stack: mMoonDayStack, dataProvider: dp, findType: EV_MOON_DAY, interpretationType: EV_MOON_DAY, string: { e in
                return String(format: "%d", e.getDegree())
            })

            showEventStack(stack: mTithiStack, dataProvider: dp, findType: EV_TITHI, interpretationType: EV_TITHI, string: { e in
                return String(format: "%d", e.getDegree())
            })
        }
    }

    func showEvent(label: UILabel, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType, string: (AmaxEvent) -> String) {
        var itemFound: AmaxSummaryItem?
        for item in dataProvider.mEventCache {
            if item.mKey == findType {
                itemFound = item
                break
            }
        }
        if let si = itemFound {
            var pos = -1
            var activeEvent: AmaxEvent?
            pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
            activeEvent = (pos == -1) ? nil : si.mEvents[pos]

            if let e = activeEvent {
                label.text = string(e)
                AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: e)

                label.layer.borderWidth = 0.8
                label.layer.borderColor = UIColor.gray.cgColor

                label.isUserInteractionEnabled = true
                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: e, eventType: interpretationType)
                label.addGestureRecognizer(tap)
                return
            }
        }
        label.text = ""
        label.gestureRecognizers = []
    }
    
    func showEventStack(stack: UIStackView, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType, string: (AmaxEvent) -> String) {
        var itemFound: AmaxSummaryItem?
        for item in dataProvider.mEventCache {
            if item.mKey == findType {
                itemFound = item
                break
            }
        }
        for view in stack.subviews {
            view.removeFromSuperview()
        }
        if let si = itemFound {
            var pos = -1
            var activeEvent: AmaxEvent?
            pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
            activeEvent = (pos == -1) ? nil : si.mEvents[pos]
            for event in si.mEvents {
                let label = UILabel()
                label.text = string(event)

                label.layer.borderWidth = 0.8
                label.layer.borderColor = UIColor.gray.cgColor

                label.textAlignment = .center
                AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: event)

                label.isUserInteractionEnabled = true
                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: event, eventType: interpretationType)
                label.addGestureRecognizer(tap)

                label.sizeToFit()
                stack.addArrangedSubview(label)
            }
        }
    }

    @objc func itemTapped(sender: UITapGestureRecognizer) {
        if let tap = sender as? AmaxTapRecognizer {
            print("itemTapped: \(tap.mEvent!.description), type: \(AmaxEvent.EVENT_TYPE_STR[Int(tap.mEventType!.rawValue)])")
            showInterpreterFor(event: tap.mEvent!, type: tap.mEventType!)
        }
    }

}
