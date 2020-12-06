//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxPlanetAxisController : AmaxBaseViewController {

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
            mPlanetAxis.append(view.viewWithTag(i + 100) as! PlanetAxisView)
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

    override func updateDisplay() {
        if let dp = mDataProvider {
            title = dp.currentDateString()
            dp.prepareCalculation()
            self.mCurrentTime = dp.getCurrentTime()
            self.mCustomTime = dp.getCustomTime()
            //******* COMMON RISES & SETS
            let pp0 = 0, pp1 = 0
            for i in SE_SUN.rawValue ... SE_SATURN.rawValue /* SE_WHITE_MOON */{
                var tmp2: [AmaxEvent]
                if i == SE_MOON.rawValue {
                    tmp2 = dp.getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                else {
                    tmp2 = dp.getEventsOnPeriodFor(eventType: EV_DEGREE_PASS, planet: AmaxPlanet(i), special: false, from: dp.mStartTime, to: dp.mEndTime, value: 0)
                }
                //getItem(Event.EV_DEG_2ND, i).setEvents(tmp2);
                if (i > SE_SATURN.rawValue) {
                    continue
                }
                tmp2 = []
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
    //      System.out.println("Astrorise");
    //      Astromaximum.evDump(tmp);
    //      if(pp0>0)
    //        continue;
                tmp = dp.getEventsOnPeriodFor(eventType: EV_ASTROSET, planet: AmaxPlanet(i), special: false, from: pp0, to: pp1, value: 3);
                dp.mergeEvents(dest: &tmp2, add: tmp, isSort: true);
    //      Astromaximum.evDump(tmp2);
                tmp = []
                for j in 0 ..< tmp2.count - 1 {
                    let ev = tmp2[j]
                    let enew = AmaxEvent(date: (tmp2[j + 1].date(at: 0) + ev.date(at: 0)) / 2, planet: AmaxPlanet(rawValue: i))
                    enew.mDegree = ev.mDegree == 1 ? 2 : 4
                    tmp2.append(enew);
                }
    //      Astromaximum.evDump(tmp2);
                dp.mergeEvents(dest: &tmp, add: tmp2, isSort: true);
    //      Astromaximum.evDump(tmp);
    //      break;
                tmp = tmp.filter({ ev in return ev.mDegree != 200 })
                tmp2 = evInCurrentDay(new Vector(), tmp);
                getItem(Event.EV_RISE, i).setEvents(tmp2);
    //#if logger
          Astromaximum.instance.logger(" other risesets");
    //#endif
    //      System.out.println("EvDump:");
    //      Astromaximum.evDump(tmp2);
            }
            for i in 0 ..< 9 {
                mPlanetAxis[i].setData(events: [])
            }
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
