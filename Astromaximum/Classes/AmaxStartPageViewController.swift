//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

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
        EV_MOON_SIGN_LARGE,
        EV_SUN_DEGREE_LARGE,
        EV_TITHI,
    ]

    private var mTitleDate: String = ""
    
    private var mHourLabels: [UILabel] = [UILabel]()

    @IBOutlet weak var mVocTime: UILabel!
    @IBOutlet weak var mVcTime: UILabel!

    @IBOutlet weak var mSunEclipse: UILabel!
    @IBOutlet weak var mSunBlock: UIView!
    @IBOutlet weak var mSunDay: UILabel!
    @IBOutlet weak var mSunDegree: UILabel!
    @IBOutlet weak var mSunSign: UILabel!
    @IBOutlet weak var mSunDegreeTime: UILabel!

    @IBOutlet weak var mMoonDayStack: UIStackView!
    
    @IBOutlet weak var mMoonEclipseQuarter: UIView!
    @IBOutlet weak var mMoonEclipse: UILabel!
    @IBOutlet weak var mMoonQuarter: MoonPhaseView!

    @IBOutlet weak var mMoonBlock: UIView!
    @IBOutlet weak var mMoonSign: UILabel!
    @IBOutlet weak var mMoonSignTime: UILabel!

    @IBOutlet weak var mMoonPhase: MoonPhaseView!
    @IBOutlet weak var mTithiStack: UIStackView!
    @IBOutlet weak var mMoonMoveScroll: UIScrollView!
    @IBOutlet weak var mMoonMoveStack: UIStackView!
    @IBOutlet weak var mRetrogradeStack: UIStackView!
    @IBOutlet weak var mPlanetHourDayStack: UIStackView!
    @IBOutlet weak var mPlanetHourNightStack: UIStackView!

    @IBOutlet weak var mSelectedViewTime: UILabel!
    @IBOutlet weak var mCornerTime: UILabel!
    @IBOutlet weak var tvCell: UITableViewCell!

    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?
    var dateSelectController: AmaxDateSelectController?
    
    var selectedView: UIView?
    
    let dimmedColor = ColorCompatibility.systemGray2.cgColor

    //MARK: Init
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

                addBorders(to: label)

                label.textAlignment = .center
                label.isUserInteractionEnabled = true
                (i == 0 ? mPlanetHourDayStack : mPlanetHourNightStack).addArrangedSubview(label)
            }
        }
        mMoonQuarter.whiteBorder = true

        addBorders(to: mSunEclipse)
        addBorders(to: mMoonEclipseQuarter)
        addBorders(to: mMoonPhase)
        addBorders(to: mSunBlock)
        addBorders(to: mMoonBlock)

        // retrograde spacers
        let spacer1 = UIView()
        spacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)
        //spacerButton1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        //spacerButton1.layer.borderWidth = 0.8
        //spacerButton1.layer.borderColor = UIColor.red.cgColor
        mRetrogradeStack.addArrangedSubview(spacer1)
        let spacer2 = UIView()
        spacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        //spacerButton2.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        //spacerButton2.layer.borderWidth = 0.8
        //spacerButton2.layer.borderColor = UIColor.red.cgColor
        mRetrogradeStack.addArrangedSubview(spacer2)
        spacer1.widthAnchor.constraint(equalTo: spacer2.widthAnchor).isActive = true
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
        //TODO: Selection is lost here!
        updateDisplay()
        makeSelected(selectedView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerMoonMoveScroll(flash: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
    	super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
    	super.viewDidDisappear(animated)
    }

    func centerMoonMoveScroll(flash: Bool) {
        mMoonMoveScroll.setNeedsLayout()
        mMoonMoveScroll.layoutIfNeeded()
        let newContentOffsetX = (mMoonMoveScroll.contentSize.width - mMoonMoveScroll.frame.size.width) / 2;
        mMoonMoveScroll.setContentOffset(CGPoint(x: newContentOffsetX, y: 0), animated: false)
        if flash && newContentOffsetX > 0 {
            mMoonMoveScroll.flashScrollIndicators()
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

    func addBorders(to view: UIView) {
        //view.layer.cornerRadius = 10
        //view.layer.masksToBounds = true
        view.layer.borderWidth = 0.8
        view.layer.borderColor = dimmedColor
    }

    // MARK: - Update display
    override func updateDisplay() {
        if let dp = mDataProvider {
            makeSelected(nil)
            title = dp.currentDateString()
            dp.prepareCalculation()
            dp.calculateAll(types: START_PAGE_ITEMS)
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mCornerTime.text = dp.getHighlightTimeString()

            showEvent(label: mVocTime, dataProvider: dp, findType: EV_VOC, interpretationType: EV_VOC, string: { e in
                "VOC " + e.normalizedRangeString(addSpaces: false)
            }, defaultString: "VOC")
            showEvent(label: mVcTime, dataProvider: dp, findType: EV_VIA_COMBUSTA, interpretationType: EV_VIA_COMBUSTA, string: { e in
                "VC " + e.normalizedRangeString(addSpaces: false)
            }, defaultString: "VC")

            mSunEclipse.text = ""
            mSunEclipse.gestureRecognizers = []
            mMoonEclipse.text = ""
            mMoonEclipseQuarter.gestureRecognizers = []
            mMoonQuarter.isHidden = true
            if let eclipse = dp.todayEclipse(date: dp.mStartTime, delta: 3) {
                if eclipse.mPlanet0 == SE_SUN {
                    mSunEclipse.text = String(format: "%c", getSymbol(TYPE_ASPECT, 0))
                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: eclipse, eventType: eclipse.mEvtype)
                    mSunEclipse.addGestureRecognizer(tap)
                }
                else {
                    mMoonEclipse.text = String(format: "%c", getSymbol(TYPE_ASPECT, 180))
                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: eclipse, eventType: eclipse.mEvtype)
                    mMoonEclipseQuarter.addGestureRecognizer(tap)
                }
            }
            else {
                mMoonQuarter.phase = -1
                for ev in dp.mMoonPhases {
                    if ev.isDate(at: 0, between: dp.mStartTime, and: dp.mEndTime) {
                        mMoonQuarter.phase = Float(ev.mPlanet1.rawValue) / 4
                        mMoonQuarter.setNeedsDisplay()
                        mMoonQuarter.isHidden = false
                        let copied = AmaxEvent(ev)
                        copied.setDate(at: 1, value: copied.date(at: 0))
                        copied.mPlanet1 = AmaxPlanet(rawValue: copied.mPlanet0.rawValue + 4)
                        let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: copied, eventType: copied.mEvtype)
                        mMoonEclipseQuarter.addGestureRecognizer(tap)
                        break
                    }
                }
            }
            showEvent(label: mSunDay, dataProvider: dp, findType: EV_SUN_DAY, interpretationType: EV_SUN_DAY, string: { e in
                var day = e.getDegree()
                if day >= 360 {
                    day = -(day - 359)
                }
                return String(format: "%d", day)
            })
            
            showEventBlock(dataProvider: dp, findType: EV_SUN_DEGREE_LARGE, configure: { event, si in
                if let e = event {
                    mSunDegree.text = String(format: "%d\u{00b0} ", e.getDegree() % 30 + 1)
                    AmaxTableCell.setColorOf(label: mSunDegree, si: si, activeEvent: e, byEventMode: e)

                    mSunSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree() / 30)))
                    AmaxTableCell.setColorOf(label: mSunSign, si: si, activeEvent: e, byEventMode: e)

                    mSunDegreeTime.text = dp.isInCurrentDay(date: e.date(at: 0)) ?
                        AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false) : ""
                    AmaxTableCell.setColorOf(label: mSunDegreeTime, si: si, activeEvent: e, byEventMode: e)

                    mSunBlock.gestureRecognizers = []
                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e, eventType: EV_DEGREE_PASS)
                    mSunBlock.addGestureRecognizer(tap)
                }
            })

            showEventBlock(dataProvider: dp, findType: EV_MOON_SIGN_LARGE, configure: { event, si in
                if let e = event {
                    mMoonSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree())))
                    AmaxTableCell.setColorOf(label: mMoonSign, si: si, activeEvent: e, byEventMode: e)

                    mMoonSignTime.text = dp.isInCurrentDay(date: e.date(at: 0)) ?
                        AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false) : ""

                    mMoonBlock.gestureRecognizers = []
                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e, eventType: EV_SIGN_ENTER)
                    mMoonBlock.addGestureRecognizer(tap)
                }
            })

            _ = showEventStack(stack: mMoonDayStack, dataProvider: dp, findType: EV_MOON_DAY, interpretationType: EV_MOON_DAY, string: { e in
                return String(format: "%d", e.getDegree())
            })

            let tithis = showEventStack(stack: mTithiStack, dataProvider: dp, findType: EV_TITHI, interpretationType: EV_TITHI, string: { e in
                return String(format: "%d", e.getDegree())
            }, alignment: .center, xibForLongPress: "TithiCell")

            showMoonPhase(dataProvider: dp, events: tithis)

            showMoonMoveStack(stack: mMoonMoveStack, dataProvider: dp)
            showRetrogradeStack(stack: mRetrogradeStack, dataProvider: dp)
            
            showPlanetHourStack(stack: mPlanetHourDayStack, dataProvider: dp, isDay: true)
            showPlanetHourStack(stack: mPlanetHourNightStack, dataProvider: dp, isDay: false)
            
            centerMoonMoveScroll(flash: false)
            
            makeSelected(selectedView)
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
    
    func showEventBlock(dataProvider: AmaxDataProvider, findType: AmaxEventType, configure: (AmaxEvent?, AmaxSummaryItem) -> Void ) {
        if let si = findInCache(dataProvider: dataProvider, findType: findType) {
            configure(si.mEvents[0], si)
        }
    }
    
    func showEvent(label: UILabel, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType,  string: (AmaxEvent) -> String, defaultString: String = "") {
        addBorders(to: label)
        label.gestureRecognizers = []
        if let si = findInCache(dataProvider: dataProvider, findType: findType) {
            var pos = -1
            var activeEvent: AmaxEvent?
            pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
            activeEvent = (pos == -1) ? nil : si.mEvents[pos]

            if let e = activeEvent {
                label.text = string(e)
                AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: e)

                label.isUserInteractionEnabled = true
                let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e, eventType: interpretationType)
                label.addGestureRecognizer(tap)
                return
            }
        }
        label.text = defaultString
    }

    func showEventStack(stack: UIStackView, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType, string: (AmaxEvent) -> String, alignment: NSTextAlignment = .center, xibForLongPress: String = "") -> [AmaxEvent] {
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

            addBorders(to: label)

            label.textAlignment = alignment
            AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: event)

            label.isUserInteractionEnabled = true
            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: interpretationType)
            label.addGestureRecognizer(tap)

            label.sizeToFit()
            stack.addArrangedSubview(label)
        }
        if alignment == .left {
            let spacer1 = UIView()
            //spacer1.layer.borderWidth = 0.8
            //spacer1.layer.borderColor = UIColor.red.cgColor
            stack.addArrangedSubview(spacer1)
        }
        if !xibForLongPress.isEmpty {
            addLongPressRecognizer(view: stack, summaryItem: si, xib: xibForLongPress)
        }
        return si.mEvents
    }
    
    func showMoonPhase(dataProvider: AmaxDataProvider, events: [AmaxEvent]) {
        mMoonPhase.phase = Float(events[events.count == 3 ? 1 : 0].getDegree() - 1) / 29
        mMoonPhase.setNeedsDisplay()
        mMoonPhase.gestureRecognizers = []
        if let si = findInCache(dataProvider: dataProvider, findType: EV_MOON_PHASE) {
            if si.mEvents.count > 0 {
                let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: si.mEvents[0], eventType: EV_MOON_PHASE)
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
            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: EV_PLANET_HOUR)
            label.addGestureRecognizer(tap)

            counter += 1
        }
        addLongPressRecognizer(view: stack, summaryItem: si, xib: "PlanetHourCell")
    }

    func showMoonMoveStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        //stack.layer.borderWidth = 0.8
        //stack.layer.borderColor = UIColor.gray.cgColor

        var activeEvent: AmaxEvent?
        let si = findInCache(dataProvider: dataProvider, findType: EV_MOON_MOVE)!
        var pos = -1
        pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
        activeEvent = (pos == -1) ? nil : si.mEvents[pos]

        let viewCount = stack.arrangedSubviews.count
        for i in 0 ..< si.mEvents.count {
            let event = si.mEvents[i]
            var v: AmaxMoonMoveView
            if viewCount <= i {
                // create a new view
                v = Bundle.main.loadNibNamed("MoonMoveView", owner: self, options: nil)![0] as! AmaxMoonMoveView
                stack.addArrangedSubview(v)
            }
            else {
                v = stack.arrangedSubviews[i] as! AmaxMoonMoveView
            }
            v.configure(event: event, activeEvent: activeEvent, summaryItem: si)
            v.isHidden = false
            addBorders(to: v)
            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: event.mEvtype)
            v.addGestureRecognizer(tap)

            v.widthAnchor.constraint(equalTo: v.heightAnchor, multiplier: CGFloat(0.5)).isActive = true
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.subviews.count {
            stack.subviews[i].isHidden = true
        }
        addLongPressRecognizer(view: stack, summaryItem: si, xib: "MoonMoveCell")
    }

    func showRetrogradeStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        //stack.layer.borderWidth = 0.8
        //stack.layer.borderColor = UIColor.gray.cgColor

        let si = findInCache(dataProvider: dataProvider, findType: EV_RETROGRADE)!
        let viewCount = stack.arrangedSubviews.count - 2
        for i in 0 ..< si.mEvents.count {
            let event = si.mEvents[i]
            var v: UIView
            if viewCount <= i {
                // create a new view
                let cell = Bundle.main.loadNibNamed("RetrogradeCell", owner: self, options: nil)![0] as! UIView
                v = cell.viewWithTag(3)!
                let planet = v.viewWithTag(1) as! UILabel
                planet.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE))
                addBorders(to: v)
                stack.insertArrangedSubview(v, at: i + 1)
            }
            else {
                v = stack.arrangedSubviews[i + 1]
            }
            let planet = v.viewWithTag(1) as! UILabel
            planet.text = String(format: "%c", getSymbol(TYPE_PLANET, event.mPlanet0.rawValue))

            v.gestureRecognizers = []
            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: event.mEvtype)
            v.addGestureRecognizer(tap)

            //v.sizeToFit()
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.subviews.count - 2 {
            stack.subviews[i + 1].isHidden = true
        }

        addLongPressRecognizer(view: stack, summaryItem: si, xib: "RetrogradeCell")
    }

    @objc func itemTapped(sender: UITapGestureRecognizer) {
        if let tap = sender as? AmaxTapRecognizer {
            //print("itemTapped: \(tap.mEvent.description), type: \(AmaxEvent.EVENT_TYPE_STR[Int(tap.mEventType.rawValue)])")
            if let newView = tap.view {
                if newView == selectedView {
                    showInterpreterFor(event: tap.mEvent, type: tap.mEventType)
                }
                else {
                    makeSelected(newView)
                }
            }
        }
    }

    func makeSelected(_ view: UIView?) {
        if view == nil || view!.window == nil {
            mSelectedViewTime.text = mDataProvider?.locationName()
        }
        if selectedView != view {
            selectedView?.layer.borderColor = dimmedColor
            selectedView = view
            selectedView?.layer.borderColor = ColorCompatibility.label.cgColor
        }
        if let grArray = selectedView?.gestureRecognizers {
            for gr in grArray {
                if let tap = gr as? AmaxTapRecognizer {
                    mSelectedViewTime.text = makeSelectedDateString(tap.mEvent)
                    break
                }
            }
        }
    }

    func makeSelectedDateString(_ e: AmaxEvent) -> String {
        if e.date(at: 0) == e.date(at: 1) {
            return AmaxEvent.long2String(e.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
        }
        return String(format:"%@ - %@",
                AmaxEvent.long2String(e.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false),
                AmaxEvent.long2String(e.date(at: 1), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: true))
    }

    @objc func itemLongPressed(sender: UILongPressGestureRecognizer) {
        if let longPress = sender as? AmaxLongPressRecognizer {
            if longPress.state == .began {
                showEventListFor(si: longPress.mSummaryItem, xib: longPress.mXibName)
            }
        }
    }
    
    func addLongPressRecognizer(view: UIView, summaryItem: AmaxSummaryItem, xib: String) {
        view.gestureRecognizers = []
        let longPress = AmaxLongPressRecognizer(target: self, action: #selector(itemLongPressed), summaryItem: summaryItem, xib: xib)
        view.addGestureRecognizer(longPress)
    }
}
