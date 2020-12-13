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
    @IBOutlet weak  var mToolbar: UIToolbar!

    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?
    var dateSelectController: AmaxDateSelectController?

    override init(nibName:String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
        for i in 1 ... 9 {
            let pa = view.viewWithTag(i + 200) as! PlanetAxisView
            pa.setPlanet(AmaxPlanet(Int32(i - 1)))
            addBorders(to: pa.mPasses)
            mPlanetAxis.append(pa)
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

    override func updateDisplay() {
        if let dp = mDataProvider {
            title = dp.currentDateString()
            dp.prepareCalculation()
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            mCornerTime.text = dp.getHighlightTimeString()
            //******* COMMON RISES & SETS
            let pp0 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: -1, isTrailing: false)
            let pp1 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: 2, isTrailing: true)
            for i in SE_SUN.rawValue ... SE_SATURN.rawValue /* SE_WHITE_MOON */{
                var passes: [AmaxEvent]
                if i == SE_MOON.rawValue {
                    passes = dp.getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                else {
                    passes = dp.getEventsOnPeriodFor(eventType: EV_DEGREE_PASS, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                /*for ev in passes {
                    print("DEG_2ND \(i): " + ev.description)
                }*/
                if (i > SE_SATURN.rawValue) {
                    continue
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
                /*for ev in passes {
                    print("PASS \(i): " + ev.description)
                }*/
                mPlanetAxis[Int(i)].setData(passes: passes, axis: tmp, passCallback: {_,_ in }, axisCallback: { view, e in
                    if e != nil {
                        let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e!, eventType: EV_RISE)
                        view.gestureRecognizers = [tap]
                    }
                    else {
                        view.gestureRecognizers = []
                    }
                })
            }
            makeSelected(selectedView)
        }
    }
}
