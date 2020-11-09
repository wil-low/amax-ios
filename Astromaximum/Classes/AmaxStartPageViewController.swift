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
        EV_MOON_PHASE,
        EV_RETROGRADE,
        EV_PLANET_HOUR_EXT,
        EV_MOON_SIGN,
        EV_SUN_DEGREE,
        EV_TITHI,
    ]

    private var mTitleDate: String = ""
    
    private var mHourLabels: [UILabel] = [UILabel]()

    @IBOutlet weak var mVocTime: UILabel!
    @IBOutlet weak var mVcTime: UILabel!
    @IBOutlet weak var mSunDay: UILabel!
    @IBOutlet weak var mSunDegree: UILabel!
    @IBOutlet weak var mSunSign: UILabel!
    @IBOutlet weak var mSunDegreeTime: UILabel!
    @IBOutlet weak var mMoonDayStack: UIStackView!
    @IBOutlet weak var mMoonSign: UILabel!
    @IBOutlet weak var mMoonSignTime: UILabel!
    @IBOutlet weak var mMoonPhase: MoonPhaseView!
    @IBOutlet weak var mTithiStack: UIStackView!
    @IBOutlet weak var mMoonMoveStack: UIStackView!
    @IBOutlet weak var mRetrogradeStack: UIStackView!
    @IBOutlet weak var mPlanetHourDayStack: UIStackView!
    @IBOutlet weak var mPlanetHourNightStack: UIStackView!
    
    @IBOutlet weak var tvCell: UITableViewCell!

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
        for i in 0 ..< 2 {
            for _ in 0 ..< 12 {
                let label = UILabel()
                mHourLabels.append(label)
                label.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE) /*font.pointSize*/)

                //label.layer.borderWidth = 0.8
                //label.layer.borderColor = UIColor.gray.cgColor

                label.textAlignment = .center
                label.isUserInteractionEnabled = true
                (i == 0 ? mPlanetHourDayStack : mPlanetHourNightStack).addArrangedSubview(label)
            }
        }
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
                "VOC " + e.normalizedRangeString()
            }, defaultString: "VOC")
            showEvent(label: mVcTime, dataProvider: dp, findType: EV_VIA_COMBUSTA, interpretationType: EV_VIA_COMBUSTA, string: { e in
                "VC " + e.normalizedRangeString()
            }, defaultString: "VC")

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
            _ = showEventStack(stack: mMoonDayStack, dataProvider: dp, findType: EV_MOON_DAY, interpretationType: EV_MOON_DAY, string: { e in
                return String(format: "%d", e.getDegree())
            }, alignment: .left)

            let tithis = showEventStack(stack: mTithiStack, dataProvider: dp, findType: EV_TITHI, interpretationType: EV_TITHI, string: { e in
                return String(format: "%d", e.getDegree())
            })
            showMoonPhase(dataProvider: dp, events: tithis)

            showMoonMoveStack(stack: mMoonMoveStack, dataProvider: dp)
            showRetrogradeStack(stack: mRetrogradeStack, dataProvider: dp)
            
            showPlanetHourStack(stack: mPlanetHourDayStack, dataProvider: dp, isDay: true)
            showPlanetHourStack(stack: mPlanetHourNightStack, dataProvider: dp, isDay: false)
        }
    }

    func findInCache(dataProvider: AmaxDataProvider, findType: AmaxEventType) -> AmaxSummaryItem? {
        var itemFound: AmaxSummaryItem?
        for item in dataProvider.mEventCache {
            if item.mKey == findType {
                itemFound = item
                break
            }
        }
        return itemFound
    }
    
    func showEvent(label: UILabel, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType,  string: (AmaxEvent) -> String, defaultString: String = "") {
        if let si = findInCache(dataProvider: dataProvider, findType: findType) {
            var pos = -1
            var activeEvent: AmaxEvent?
            pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
            activeEvent = (pos == -1) ? nil : si.mEvents[pos]

            if let e = activeEvent {
                label.text = string(e)
                AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: e)

                //label.layer.borderWidth = 0.8
                //label.layer.borderColor = UIColor.gray.cgColor

                label.isUserInteractionEnabled = true
                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: e, eventType: interpretationType)
                label.addGestureRecognizer(tap)
                return
            }
        }
        label.text = defaultString
        label.gestureRecognizers = []
    }
    
    func showEventStack(stack: UIStackView, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType, string: (AmaxEvent) -> String, alignment: NSTextAlignment = .center) -> [AmaxEvent] {
        for view in stack.subviews {
            view.removeFromSuperview()
        }
        var activeEvent: AmaxEvent?
        let si = findInCache(dataProvider: dataProvider, findType: findType)!
        var pos = -1
        pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
        activeEvent = (pos == -1) ? nil : si.mEvents[pos]
        for event in si.mEvents {
            let label = UILabel()
            label.text = string(event)

            //label.layer.borderWidth = 0.8
            //label.layer.borderColor = UIColor.gray.cgColor

            label.textAlignment = alignment
            AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: event)

            label.isUserInteractionEnabled = true
            let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: event, eventType: interpretationType)
            label.addGestureRecognizer(tap)

            label.sizeToFit()
            stack.addArrangedSubview(label)
        }
        return si.mEvents
    }
    
    func showMoonPhase(dataProvider: AmaxDataProvider, events: [AmaxEvent]) {
        mMoonPhase.phase = Float(events[events.count == 3 ? 1 : 0].getDegree() - 1) / 29
        mMoonPhase.setNeedsDisplay()
        mMoonPhase.gestureRecognizers = []
        if let si = findInCache(dataProvider: dataProvider, findType: EV_MOON_PHASE) {
            if si.mEvents.count > 0 {
                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: si.mEvents[0], eventType: EV_MOON_PHASE)
                mMoonPhase.addGestureRecognizer(tap)
            }
        }
    }

    func showPlanetHourStack(stack: UIStackView, dataProvider: AmaxDataProvider, isDay: Bool) {
        var activeEvent: AmaxEvent?
        let si = findInCache(dataProvider: dataProvider, findType: EV_PLANET_HOUR_EXT)!
        var pos = -1
        pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
        activeEvent = (pos == -1) ? nil : si.mEvents[pos]
        let skipToNum = isDay ? 0 : 12
        var showEvents = false
        var counter = 0;
        for event in si.mEvents {
            if !showEvents && event.getDegree() != skipToNum {
                continue
            }
            showEvents = true
            if event.getDegree() >= skipToNum + 12 {
                break
            }
            let label = mHourLabels[(isDay ? 0 : 12) + counter]
            label.text = String(format: "%c", getSymbol(TYPE_PLANET, event.mPlanet0.rawValue))
            
            label.backgroundColor = (event.date(at: 1) > dataProvider.mEndTime) ? ColorCompatibility.systemGray6 : ColorCompatibility.systemBackground
            let color = isDay ? ColorCompatibility.label : ColorCompatibility.systemIndigo
            AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: event, defaultColor: color)

            label.gestureRecognizers = []
            let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: event, eventType: EV_PLANET_HOUR)
            label.addGestureRecognizer(tap)

            //label.sizeToFit()
            counter += 1
        }
    }

    func showMoonMoveStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        for view in stack.subviews {
            view.removeFromSuperview()
        }
        //stack.layer.borderWidth = 0.8
        //stack.layer.borderColor = UIColor.gray.cgColor

        var activeEvent: AmaxEvent?
        let si = findInCache(dataProvider: dataProvider, findType: EV_MOON_MOVE)!
        var pos = -1
        pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
        activeEvent = (pos == -1) ? nil : si.mEvents[pos]
        for event in si.mEvents {
            let view = Bundle.main.loadNibNamed("MoonMoveView", owner: self, options: nil)![0]
            if let v = view as? AmaxMoonMoveView {
                v.configure(event: event, activeEvent: activeEvent, summaryItem: si)
                
                //v.layer.borderWidth = 0.8
                //v.layer.borderColor = UIColor.gray.cgColor
                
                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: event, eventType: event.mEvtype)
                v.addGestureRecognizer(tap)

                v.sizeToFit()
                stack.addArrangedSubview(v)
            }
        }
    }

    func showRetrogradeStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        for view in stack.subviews {
            view.removeFromSuperview()
        }
        //stack.layer.borderWidth = 0.8
        //stack.layer.borderColor = UIColor.gray.cgColor

        let si = findInCache(dataProvider: dataProvider, findType: EV_RETROGRADE)!
        for event in si.mEvents {
            let cell = Bundle.main.loadNibNamed("RetrogradeCell", owner: self, options: nil)![0] as! UIView
            if let v = cell.viewWithTag(3) {
                let planet = v.viewWithTag(1) as! UILabel
                planet.text = String(format: "%c", getSymbol(TYPE_PLANET, event.mPlanet0.rawValue))
                planet.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE))

                //v.layer.borderWidth = 0.8
                //v.layer.borderColor = UIColor.gray.cgColor

                let tap = AmaxTapRecognizer(target: self, action: #selector(self.itemTapped(sender:)), event: event, eventType: event.mEvtype)
                v.addGestureRecognizer(tap)

                v.sizeToFit()
                stack.addArrangedSubview(v)
            }
        }
        let spacerButton = UIView()
        spacerButton.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacerButton.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        //spacerButton.layer.borderWidth = 0.8
        //spacerButton.layer.borderColor = UIColor.red.cgColor
        stack.addArrangedSubview(spacerButton)
    }

    @objc func itemTapped(sender: UITapGestureRecognizer) {
        if let tap = sender as? AmaxTapRecognizer {
            //print("itemTapped: \(tap.mEvent!.description), type: \(AmaxEvent.EVENT_TYPE_STR[Int(tap.mEventType!.rawValue)])")
            showInterpreterFor(event: tap.mEvent!, type: tap.mEventType!)
        }
    }

}
