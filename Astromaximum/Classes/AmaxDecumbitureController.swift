//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxDecumbitureController : AmaxSelectionViewController {

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
/*
     void calcDecumbiture() {
         Interpreter.topic = Interpreter.T_DECUMB;
         long startDate = Astromaximum.customTime.decumbDate;
         gatherSummary(Astromaximum.getMidnight(startDate));
         Vector moonSign = new Vector();
         long p0 = startDate - 5 * Astromaximum.MSECINDAY / 2, p1 = startDate + 32 * Astromaximum.MSECINDAY;
         Astromaximum.dataFile.getEventsOnPeriod(moonSign, Event.EV_SIGN_ENTER, Event.SE_MOON,
                 false, p0, p1, 0);
         Event e0 = null, e1 = null;
         int index;
         int mslen = moonSign.size();
         for (index = 0; index < mslen; index++) {
             e0 = Astromaximum.evAt(moonSign, index);
             if (SummItem.contains(e0, startDate)) {
                 e1 = Astromaximum.evAt(moonSign, index + 1);
                 break;
             }
         }
         period1 = period0 + Astromaximum.MSECINDAY - 1;
         for (int i = moonPhaseCount - 1; i >= 0; i--) {
             Event ph = aMoonPhase[i];
             if (ph.getDate0() <= startDate) {
                 getItem(Event.EV_MOON_PHASE, 1).events[0] = ph;
                 break;
             }
         }
         int ddegree = e1.getDegree() - e0.getDegree();
         if (ddegree < 0) {
             ddegree += 12;
         }
         ddegree *= 30;
         int dgr = (int) ((startDate - e0.getDate0()) * ddegree / (e1.getDate0() - e0.getDate0()) +
                 e0.getDegree() * 30);
 //    System.out.println(dgr);
         long[] decumb = new long[13];
         decumb[0] = startDate;
         for (int i = 0; i < decumbAspects.length; i++) {
             dgr += decumbAspects[i];
 //      System.out.println("***");
 //      System.out.println(dgr);
             mslen = moonSign.size();
             for (; index < mslen; index++) {
                 e0 = Astromaximum.evAt(moonSign, index - 1);
                 e1 = Astromaximum.evAt(moonSign, index);
                 if (e0.getDegree() == dgr % 360 / 30) {
 //          e0.dump();
 //          e1.dump();
                     ddegree = e1.getDegree() - e0.getDegree();
                     if (ddegree < 0) {
                         ddegree += 12;
                     }
                     ddegree *= 30;
                     decumb[i + 1] = (dgr % 360 - e0.getDegree() * 30) * (e1.getDate0() - e0.getDate0()) /
                             ddegree + e0.getDate0();
 //          System.out.println(Event.long2String(decumb[i+1],false,false));
                     break;
                 }
             }
         }
         for (int i = 0; i <= decumbAspects.length; i++) {
             getItem(Event.EV_DECUMBITURE, i).setEvents(0, new Event(decumb[i], i));
             long delta = Astromaximum.MSECINDAY / ((i == 0 || i == decumbAspects.length) ? 1 : 2);
             moonSign.removeAllElements();
             Astromaximum.dataFile.getAspectsOnPeriod(moonSign, Event.SE_MOON, decumb[i] - delta,
                     decumb[i] + delta);
 //      Astromaximum.evDump(moonSign);
             for (int j = 0; j < moonSign.size(); j++) { // do not optimize
                 e0 = Astromaximum.evAt(moonSign, j);
                 dgr = e0.planet1;
                 if (dgr > Event.SE_SATURN || dgr == Event.SE_MERCURY) {
                     moonSign.removeElementAt(j--);
                 }
             }
             getItem(Event.EV_DECUMB_ASPECT, i).setEvents(moonSign);
         }

         Vector asi = new Vector();
         SummItem si = getItem(Event.EV_MOON_DAY);
         si.recalcSelection(startDate, true);
         asi.addElement(si.getCusSelEvent());
         si = getItem(Event.EV_DAY_HOURS);
         si.recalcSelection(startDate, true);
         Event ev = si.getCusSelEvent();
         if (ev == null) {
             si = getItem(Event.EV_NIGHT_HOURS);
             si.recalcSelection(startDate, true);
             ev = si.getCusSelEvent();
             if (ev == null) {
                 long pp0 = period0 - Astromaximum.MSECINDAY, pp1 = period1 - Astromaximum.MSECINDAY;
                 ev = Astromaximum.dataFile.getEventOnPeriod(Event.EV_RISE, Event.SE_SUN, true,
                         pp0, pp1);
                 ev.setDate1(Astromaximum.dataFile.getEventOnPeriod(Event.EV_SET, Event.SE_SUN, false, pp0, pp1).getDate0());
 //        ev.dump();
                 int weekDay = getItem(Event.EV_TOP_DAY).events[1].planet0 + 5;
                 Event[] aev = calcPlanetHours(ev, getItem(Event.EV_SUN_RISE).events[0], weekStartHour[weekDay % 7]);
                 si = new SummItem(Event.EV_LAST);
                 si.setEvents(aev);
                 si.recalcSelection(startDate, true);
 //        si.dump();
                 ev = si.getCusSelEvent();
             }
         }
         asi.addElement(ev);
 //    setCurPage(PAGE_SUMMARY+1);
         for (int plt = Event.SE_VENUS; plt <= Event.SE_SATURN; plt++) {
             si = getItem(Event.EV_RISE, plt);
             si.recalcSelection(startDate, true);
 //      si.dump();
             ev = si.getCusSelEvent();
             if (ev != null /*&& ev.getDegree()%2==0*/) {
                 asi.addElement(ev);
             }
         }
 //    Astromaximum.evDump(asi);

         getItem(Event.EV_DECUMB_BEGIN).setEvents(asi);
         setCurPage(PAGE_DECUMB);
         recreateCommands();
     }
     */
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
            mParent!.mCornerTime.textColor = dp.mUseCustomTime ? UIColor.systemBlue : UIColor.systemRed
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
                    mPlanetPass[Int(i - SE_SATURN.rawValue - 1)].setData(
                        passes: passes,
                        currentTime: mCurrentTime,
                        customTime: mCustomTime,
                        useCustomTime: dp.mUseCustomTime,
                        passCallback: {view, e in
                            let tap = AmaxTapRecognizer(target: self, action: #selector(itemTapped), event: e!, eventType: e!.mEvtype)
                            view.gestureRecognizers = [tap]
                    })
                    continue
                }
                else {
                    mPlanetAxis[Int(i)].mPlanetPass.setData(
                        passes: passes,
                        currentTime: mCurrentTime,
                        customTime: mCustomTime,
                        useCustomTime: dp.mUseCustomTime,
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
                    currentTime: mCurrentTime,
                    customTime: mCustomTime,
                    useCustomTime: dp.mUseCustomTime,
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
