//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxPlanetAxisController : AmaxSelectionViewController {

    private var mTitleDate: String = ""

    var mPlanetAxis = [PlanetAxisView]()
    var mPlanetPass = [PlanetPassView]()
    @IBOutlet weak  var mToolbar: UIToolbar!

    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?

    override init(nibName:String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
        for i in 0 ... 6 {
            let pa = view.viewWithTag(i + 200) as! PlanetAxisView
            pa.mPlanetPass.setPlanet(AmaxPlanet(Int32(i)))
            mPlanetAxis.append(pa)
        }
        for i in 7 ... 12 {
            let pa = view.viewWithTag(i + 200) as! PlanetPassView
            pa.setPlanet(AmaxPlanet(Int32(i)))
            mPlanetPass.append(pa)
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
        AmaxBaseViewController.interpreterController!.view.layoutSubviews()
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

    override func updateDisplay() -> Bool {
        if !super.updateDisplay() {
            return false
        }
        if let dp = mDataProvider {
            if skipUpdate(dp) {
                return false
            }
            title = dp.currentDateString()
            dp.prepareCalculation()
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mParent!.mCornerTime.text = dp.getHighlightTimeString()
            mParent!.mCornerTime.textColor = dp.mUseCustomTime ? UIColor.systemBlue : ColorCompatibility.label
            //******* COMMON RISES & SETS
            let pp0 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: -1, isTrailing: false)
            let pp1 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: 2, isTrailing: true)
            for i in SE_SUN.rawValue ... SE_WHITE_MOON.rawValue {
                var passes: [AmaxEvent]
                if i == SE_MOON.rawValue {
                    passes = dp.getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                else {
                    passes = dp.getEventsOnPeriodFor(eventType: EV_DEGREE_PASS, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                if (i > SE_SATURN.rawValue) {
                    mPlanetPass[Int(i - SE_SATURN.rawValue - 1)].setData(passes: passes,
                        passCallback: {view, e in
                            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e!, eventType: e!.mEvtype)
                            view.gestureRecognizers = [tap]
                    })
                    continue
                }
                else {
                    mPlanetAxis[Int(i)].mPlanetPass.setData(passes: passes,
                        passCallback: {view, e in
                            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e!, eventType: e!.mEvtype)
                            view.gestureRecognizers = [tap]
                        }
                    )
                }
                var tmp2 = [AmaxEvent]()
                var tmp = dp.getEventsOnPeriodFor(eventType: EV_ASTRORISE, planet: AmaxPlanet(i), special: false, from: pp0, to: pp1, value: 0)
                var j = 0
                while j < tmp.count {
                    let ev = tmp[j]
                    if (i == SE_MOON.rawValue && ev.getDegree() == 1) {
                        tmp.remove(at: j)
                        j -= 1;
                    }
                    else {
                        ev.setDate(at: 1, value: ev.date(at: 0))
                        ev.mDegree = 1
                        j += 1
                    }
                }
                tmp.append(contentsOf: dp.getEventsOnPeriodFor(eventType: EV_ASTROSET, planet: AmaxPlanet(i), special: false, from: pp0, to: pp1, value: 3))
                dp.mergeEvents(dest: &tmp2, add: tmp, isSort: true)
                tmp = []
                for j in 0 ..< tmp2.count - 1 {
                    let ev = tmp2[j]
                    let enew = AmaxEvent(date: (tmp2[j + 1].date(at: 0) + ev.date(at: 0)) / 2, planet: AmaxPlanet(rawValue: i))
                    enew.mDegree = ev.mDegree == 1 ? 2 : 4
                    tmp2.append(enew);
                }
                dp.mergeEvents(dest: &tmp, add: tmp2, isSort: true)
                tmp = tmp.filter({ ev in
                    return ev.mDegree != 200 && dp.isInCurrentDay(date: ev.date(at: 0))
                })
                mPlanetAxis[Int(i)].setData(axis: tmp,
                    axisCallback: { view, e in
                        if e != nil {
                            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e!, eventType: EV_RISE)
                            view.gestureRecognizers = [tap]
                        }
                        else {
                            view.gestureRecognizers = []
                        }
                    }
                )
            }
            makeSelected(selectedView)
        }
        return true
    }
}
