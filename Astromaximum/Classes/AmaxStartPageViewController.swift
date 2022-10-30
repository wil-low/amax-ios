//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxStartPageViewController : AmaxSelectionViewController {

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
        EV_ASP_EXACT,
        EV_SEL_DEGREES,
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
    
    @IBOutlet weak var mSunRiseTime: UILabel!
    @IBOutlet weak var mSunSetTime: UILabel!
    @IBOutlet weak var mMoonRiseTime: UILabel!
    @IBOutlet weak var mMoonSetTime: UILabel!

    @IBOutlet weak var mSunRiseSetBlock: UIView!
    @IBOutlet weak var mMoonRiseSetBlock: UIView!

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
    @IBOutlet weak var mSelDegreeStack: UIStackView!
    @IBOutlet weak var mRetrogradeStack: UIStackView!
    @IBOutlet weak var mAspectStack: UIStackView!
    @IBOutlet weak var mPlanetHourDayStack: UIStackView!
    @IBOutlet weak var mPlanetHourNightStack: UIStackView!

    @IBOutlet weak var tvCell: UITableViewCell!

    var eventListViewController: AmaxEventListViewController?
    
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
        addBorders(to: mSunRiseSetBlock)
        addBorders(to: mMoonRiseSetBlock)

        addSpacers(to: mSelDegreeStack, bordered: false)
        addSpacers(to: mRetrogradeStack, bordered: false)
        addSpacers(to: mAspectStack, bordered: false)
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
    
    override func viewDidLayoutSubviews() {
        //print("viewDidLayoutSubviews")
        centerMoonMoveScroll(flash: false)
    }

    func addSpacers(to view: UIStackView, bordered: Bool) {
        let spacer1 = UIView()
        spacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)
        if bordered {
            spacer1.layer.borderWidth = 0.8
            spacer1.layer.borderColor = UIColor.red.cgColor
        }
        view.addArrangedSubview(spacer1)
        let spacer2 = UIView()
        spacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        if bordered {
            spacer2.layer.borderWidth = 0.8
            spacer2.layer.borderColor = UIColor.red.cgColor
        }
        view.addArrangedSubview(spacer2)
        spacer1.widthAnchor.constraint(equalTo: spacer2.widthAnchor).isActive = true
    }

    func centerMoonMoveScroll(flash: Bool) {
        //mMoonMoveScroll.layer.borderWidth = 0.8
        //mMoonMoveScroll.layer.borderColor = UIColor.red.cgColor
        mMoonMoveScroll.setNeedsLayout()
        mMoonMoveScroll.layoutIfNeeded()
        let newContentOffsetX = (mMoonMoveScroll.contentSize.width - mMoonMoveScroll.frame.size.width) / 2;
        //print("centerMoonMoveScroll \(newContentOffsetX) = (\(mMoonMoveScroll.contentSize.width) - \(mMoonMoveScroll.frame.size.width) / 2; \(view.frame.size.width)")
        mMoonMoveScroll.setContentOffset(CGPoint(x: newContentOffsetX, y: 0), animated: false)
        if flash && newContentOffsetX > 0 {
            mMoonMoveScroll.flashScrollIndicators()
        }
    }

    // MARK: - Update display
    override func updateDisplay() -> Bool {
        if !super.updateDisplay() {
            return false
        }
        if let dp = mDataProvider {
            makeSelected(nil)
            if skipUpdate(dp) {
                return false
            }
            title = dp.currentDateString()
            dp.prepareCalculation()
            dp.calculateAll(types: START_PAGE_ITEMS)
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            updateCornerTime()

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

                    mSunSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree() / 30)))

                    mSunDegreeTime.text = dp.isInCurrentDay(date: e.date(at: 0)) ?
                        AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false) : ""
                    AmaxTableCell.setColorOf(label: mSunDegreeTime, si: si, activeEvent: e, byEventMode: e)

                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e, eventType: EV_DEGREE_PASS)
                    mSunBlock.gestureRecognizers = [tap]
                }
            })

            showEventBlock(dataProvider: dp, findType: EV_MOON_SIGN_LARGE, configure: { event, si in
                if let e = event {
                    mMoonSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree())))

                    mMoonSignTime.text = dp.isInCurrentDay(date: e.date(at: 0)) ?
                        AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false) : ""
                    AmaxTableCell.setColorOf(label: mMoonSignTime, si: si, activeEvent: e, byEventMode: e)

                    let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e, eventType: EV_SIGN_ENTER)
                    mMoonBlock.gestureRecognizers = [tap]
                }
            })

            _ = showEventStack(stack: mMoonDayStack, dataProvider: dp, findType: EV_MOON_DAY, interpretationType: EV_MOON_DAY, string: { e in
                return String(format: "%d", e.getDegree())
            })

            showRiseSet(label: [mSunRiseTime, mSunSetTime], dataProvider: dp, planet: SE_SUN)
            showRiseSet(label: [mMoonRiseTime, mMoonSetTime], dataProvider: dp, planet: SE_MOON)

            let tithis = showEventStack(stack: mTithiStack, dataProvider: dp, findType: EV_TITHI, interpretationType: EV_TITHI, string: { e in
                return String(format: "%d", e.getDegree())
            }, alignment: .center, xibForLongPress: "TithiCell")

            showMoonPhase(dataProvider: dp, events: tithis)

            showMoonMoveStack(stack: mMoonMoveStack, dataProvider: dp)

            showSelDegreeStack(stack: mSelDegreeStack, dataProvider: dp)
            showRetrogradeStack(stack: mRetrogradeStack, dataProvider: dp)

            showAspectStack(stack: mAspectStack, dataProvider: dp)

            showPlanetHourStack(stack: mPlanetHourDayStack, dataProvider: dp, isDay: true)
            showPlanetHourStack(stack: mPlanetHourNightStack, dataProvider: dp, isDay: false)
            
            makeSelected(selectedView)
        }
        return true
    }

    func findInCache(dataProvider: AmaxDataProvider, findType: AmaxEventType) -> AmaxSummaryItem? {
        return dataProvider.mEventCache[Int(findType.rawValue)]
    }
    
    func showEventBlock(dataProvider: AmaxDataProvider, findType: AmaxEventType, configure: (AmaxEvent?, AmaxSummaryItem) -> Void ) {
        if let si = findInCache(dataProvider: dataProvider, findType: findType) {
            _ = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
            if !si.mEvents.isEmpty {
                configure(si.mEvents[0], si)
            }
        }
    }
    
    func showEvent(label: UILabel, dataProvider: AmaxDataProvider, findType: AmaxEventType, interpretationType: AmaxEventType,  string: (AmaxEvent) -> String, defaultString: String = "") {
        addBorders(to: label)
        label.gestureRecognizers = []
        label.isUserInteractionEnabled = false
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
        label.textColor = ColorCompatibility.label
    }

    func showRiseSet(label: UILabel, dataProvider: AmaxDataProvider, si: AmaxSummaryItem) {
        var pos = -1
        var activeEvent: AmaxEvent?
        pos = si.activeEventPosition(customTime: mCustomTime, currentTime: mCurrentTime)
        activeEvent = (pos == -1) ? nil : si.mEvents[pos]
        let eventStr = NSLocalizedString(si.mKey == EV_RISE ? "abbr_rise" : "abbr_set", comment: "") + " "
        label.textColor = ColorCompatibility.label
        if let e = activeEvent {
            label.text = eventStr + AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false)
            AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: e)
        }
        else {
            if si.mEvents.count > 0 {
                label.text = eventStr + AmaxEvent.long2String(si.mEvents[0].date(at: 0), format: nil, h24: false)
            }
            else {
                label.text = ""
            }
        }
    }

    func showRiseSet(label: [UILabel], dataProvider: AmaxDataProvider, planet: AmaxPlanet) {
        var events = dataProvider.getEventsOnPeriodFor(eventType: EV_RISE, planet: planet, special: true, from: dataProvider.mStartTime, to: dataProvider.mEndTime, value: 0)
        events.append(contentsOf: dataProvider.getEventsOnPeriodFor(eventType: EV_SET, planet: planet, special: true, from: dataProvider.mStartTime, to: dataProvider.mEndTime, value: 0))
        events.sort(by: <)
        
        for i in 0...events.count - 1 {
            if i < events.count - 1 {
                events[i].mDate[1] = events[i + 1].mDate[0] - AmaxDataProvider.AmaxROUNDING_SEC
            }
            else {
                events[i].mDate[1] = dataProvider.mEndTime  // last event
            }
        }
        
        label[0].text = ""
        label[1].text = ""
        
        var riseFound = false
        var setFound = false
        
        var i = 0
        for e in events {
            if !riseFound && e.mEvtype == EV_RISE {
                showRiseSet(label: label[i], dataProvider: dataProvider, si: AmaxSummaryItem(key: e.mEvtype, events: [e]))
                riseFound = true
                i += 1
            }
            else if !setFound && e.mEvtype == EV_SET {
                showRiseSet(label: label[i], dataProvider: dataProvider, si: AmaxSummaryItem(key: e.mEvtype, events: [e]))
                setFound = true
                i += 1
            }
        }
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
        if events.isEmpty {
            return
        }
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
            
            label.backgroundColor = (event.date(at: 1) > dataProvider.mEndTime) ? ColorCompatibility.systemGray4 : ColorCompatibility.systemBackground
            let color = isDay ? ColorCompatibility.label : ColorCompatibility.systemIndigo
            AmaxTableCell.setColorOf(label: label, si: si, activeEvent: activeEvent, byEventMode: event, defaultColor: color)

            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: EV_PLANET_HOUR)
            label.gestureRecognizers = [tap]

            counter += 1
        }
        addLongPressRecognizer(view: stack, summaryItem: si, xib: "PlanetHourCell")
    }

    func showMoonMoveStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
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
            v.gestureRecognizers = [tap]

            v.widthAnchor.constraint(equalTo: v.heightAnchor, multiplier: CGFloat(0.5)).isActive = true
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.arrangedSubviews.count {
            stack.arrangedSubviews[i].isHidden = true
        }
        addLongPressRecognizer(view: stack, summaryItem: si, xib: "MoonMoveCell")
    }

    func showSelDegreeStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        let si = findInCache(dataProvider: dataProvider, findType: EV_SEL_DEGREES)!
        let viewCount = stack.arrangedSubviews.count - 2
        for i in 0 ..< si.mEvents.count {
            let event = si.mEvents[i]
            var v: SelDegreeView
            if viewCount <= i {
                // create a new view
                v = SelDegreeView()
                addBorders(to: v)
                stack.insertArrangedSubview(v, at: i + 1)
            }
            else {
                v = stack.arrangedSubviews[i + 1] as! SelDegreeView
            }
            v.setData(ev: event)

            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: EV_DEGREE_PASS)
            v.gestureRecognizers = [tap]

            v.isHidden = false
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.arrangedSubviews.count - 2 {
            stack.arrangedSubviews[i + 1].isHidden = true
        }

        addLongPressRecognizer(view: stack, summaryItem: si, xib: "SelDegreeCell")
    }

    func showRetrogradeStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        let si = findInCache(dataProvider: dataProvider, findType: EV_RETROGRADE)!
        let viewCount = stack.arrangedSubviews.count - 2
        for i in 0 ..< si.mEvents.count {
            let event = si.mEvents[i]
            var v: RetrogradeView
            if viewCount <= i {
                // create a new view
                v = RetrogradeView()
                addBorders(to: v)
                stack.insertArrangedSubview(v, at: i + 1)
            }
            else {
                v = stack.arrangedSubviews[i + 1] as! RetrogradeView
            }
            v.mPlanet.text = String(format: "%c", getSymbol(TYPE_PLANET, event.mPlanet0.rawValue))

            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: event.mEvtype)
            v.gestureRecognizers = [tap]

            v.isHidden = false
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.arrangedSubviews.count - 2 {
            stack.arrangedSubviews[i + 1].isHidden = true
        }

        addLongPressRecognizer(view: stack, summaryItem: si, xib: "RetrogradeCell")
    }

    func showAspectStack(stack: UIStackView, dataProvider: AmaxDataProvider) {
        let si = findInCache(dataProvider: dataProvider, findType: EV_ASP_EXACT)!
        let viewCount = stack.arrangedSubviews.count - 2
        for i in 0 ..< si.mEvents.count {
            let event = si.mEvents[i]
            var v: AspectView
            if viewCount <= i {
                // create a new view
                v = AspectView()
                addBorders(to: v)
                stack.insertArrangedSubview(v, at: i + 1)
            }
            else {
                v = stack.arrangedSubviews[i + 1] as! AspectView
            }
            v.setData(ev: event)

            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: event, eventType: event.mEvtype)
            v.gestureRecognizers = [tap]

            v.isHidden = false
        }
        // hide extra views
        for i in si.mEvents.count ..< stack.arrangedSubviews.count - 2 {
            stack.arrangedSubviews[i + 1].isHidden = true
        }
        stack.isHidden = si.mEvents.count == 0
        addLongPressRecognizer(view: stack, summaryItem: si, xib: "AspectCell")
    }

}
