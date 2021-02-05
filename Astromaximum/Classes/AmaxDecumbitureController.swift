//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxDecumbitureController : AmaxTableViewController {

    let decumbAspects = [45, 15, 30, 30, 15, 45, 45, 15, 30, 30, 15, 45]
    let decumbKeys = [0, 1, 2, 3, 2, 1, 3, 1, 2, 3, 2, 1, 4]

    private var mTitleDate: String = ""

    var eventListViewController: AmaxEventListViewController?
    var settingsController: AmaxSettingsController?
    @IBOutlet weak var mSelectDateButton: UIButton!

    @IBOutlet weak  var tvCell: AmaxTableCell!

    override init(nibName:String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        mDataProvider = AmaxDataProvider.sharedInstance
        let hourLabel = (self.view.viewWithTag(3) as! UILabel)
        hourLabel.text = NSLocalizedString("hour_of", comment: "Planet hour event caption")
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if updateDisplay() {
        }
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

    func numberOfSections(in: UITableView!) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    // Customize the appearance of table view cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DecumbitureCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)
            cell = tvCell
            tvCell = nil
            (cell as! AmaxTableCell).controller = self
        }
        
        if indexPath.row >= mDataProvider!.mEventCache.count {
            return cell!
        }
        let si = mDataProvider!.mEventCache[indexPath.row]

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
            //showEventListFor(si: si, xib: xibNames[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let c = tableView.cellForRow(at: indexPath) as! AmaxTableCell
        if let e = c.getActiveEvent() {
            showInterpreterFor(event: e, type: e.mEvtype)
        }
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
            let SECINDAY = 3600 * 24
            let p0 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: -2, isTrailing: false) - SECINDAY / 2
            let p1 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: 16, isTrailing: true)
            
            var moonSign = dp.getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: SE_MOON, special: false, from: p0, to: p1, value: 0)
            var e0: AmaxEvent!, e1: AmaxEvent!
            print("moonSign=\(moonSign.count)")
            var index = 0
            while index < moonSign.count {
                e0 = moonSign[index]
                if dp.mStartTime >= e0.date(at: 0) && dp.mStartTime <= e0.date(at: 1) {
                    e1 = moonSign[index + 1]
                    break
                }
                index += 1
            }
            let itemPhase = AmaxSummaryItem(key: EV_MOON_PHASE, events: [AmaxEvent]())
            var i = dp.mMoonPhases.count - 1
            while i >= 0 {
                let ph = dp.mMoonPhases[i]
                if ph.date(at: 0) <= dp.mStartTime {
                    itemPhase.mEvents = [ph]
                    break
                }
                i -= 1
            }
            var ddegree = e1.mDegree - e0.mDegree
            if ddegree < 0 {
                ddegree += 12
            }
            ddegree *= 30
            var dgr = (dp.mStartTime - e0.date(at: 0)) * Int(ddegree) / (e1.date(at: 0) - e0.date(at: 0))
            dgr += Int(e0.mDegree) * 30
            print("dgr = \(dgr)")
            var decumb = Array<Int>(repeating: 0, count: 13)
            decumb[0] = dp.mStartTime
            for asp in decumbAspects {
                dgr += asp
            }
            while index < moonSign.count {
                e0 = moonSign[index - 1]
                e1 = moonSign[index]
                if e0.mDegree == (dgr % 360 / 30) {
                    ddegree = e1.mDegree - e0.mDegree
                    if ddegree < 0 {
                        ddegree += 12
                    }
                    ddegree *= 30
                    var d = (dgr % 360) - Int(e0.mDegree) * 30
                    d *= (e1.date(at: 0) - e0.date(at: 0))
                    decumb[i + 1] = d / Int(ddegree) + e0.date(at: 0)
                }
                index += 1
            }
            let itemEvents = Array<AmaxSummaryItem>(repeating: AmaxSummaryItem(key: EV_LAST, events: [AmaxEvent]()), count: decumbAspects.count)
            let itemAspects = [AmaxSummaryItem]()
            for i in 0 ..< decumbAspects.count {
                itemEvents[i].mEvents = [AmaxEvent(date: decumb[i], planet: AmaxPlanet(Int32(i)))]
                let delta = SECINDAY / ((i == 0 || i == decumbAspects.count) ? 1 : 2)
                moonSign = dp.getAspectsOnPeriodFor(planet: SE_MOON, from: decumb[i] - delta, to: decumb[i] + delta)
                var j = 0
                while j < moonSign.count { // do not optimize
                    e0 = moonSign[j]
                    dgr = Int(e0.mPlanet1.rawValue)
                    if dgr > SE_SATURN.rawValue || dgr == SE_MERCURY.rawValue {
                        moonSign.remove(at: j)
                        j -= 1
                    }
                }
                itemAspects[i].mEvents = moonSign
            }
            var asi = [AmaxEvent]()
            var si = AmaxSummaryItem(key: EV_LAST, events: [])  //getItem(Event.EV_MOON_DAY);
            si.recalcSelection(time: dp.mStartTime, isCustom: true);
            asi.append(si.getCusSelEvent()!)
            //si = getItem(EV_DAY_HOURS)
            si.recalcSelection(time: dp.mStartTime, isCustom: true)
            var ev = si.getCusSelEvent()
            if (ev == nil) {
                //si = getItem(Event.EV_NIGHT_HOURS)
                si.recalcSelection(time: dp.mStartTime, isCustom: true)
                ev = si.getCusSelEvent()
                if (ev == nil) {
                    let pp0 = dp.shiftDate(alignedDate: dp.mStartTime, byAdding: .day, value: -1, isTrailing: false)
                    let pp1 = dp.shiftDate(alignedDate: dp.mEndTime, byAdding: .day, value: -1, isTrailing: true)
                    ev = dp.getEventOnPeriod(eventType: EV_RISE, planet: SE_SUN, special: true, from: pp0, to: pp1)
                    ev?.setDate(at: 1, value: dp.getEventOnPeriod(eventType: EV_SET, planet: SE_SUN, special: false, from: pp0, to: pp1)!.date(at: 0))
    //        ev.dump();
                    let weekDay = 5 //getItem(Event.EV_TOP_DAY).events[1].planet0 + 5;
                    let aev = [AmaxEvent]()
                    //dp.getPlanetaryHours(into: &aev, currentSunRise: <#T##AmaxEvent#>, nextSunRise: <#T##AmaxEvent!#>, dayOfWeek: <#T##Int#>, withTomorrow: <#T##Bool#>) (ev, getItem(Event.EV_SUN_RISE).events[0], weekStartHour[weekDay % 7]);
                    //si = new SummItem(Event.EV_LAST);
                    //si.setEvents(aev);
                    //si.recalcSelection(startDate, true);
    //        si.dump();
                    //ev = si.getCusSelEvent();
                }
            }
            /*asi.addElement(ev);
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
*/
            //si.recalcSelection()
            
/*
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
            makeSelected(selectedView)*/
        }
        return true
    }
    
    @IBAction func selectDatePressed(_ sender: AnyObject?) {
        let dpd = DatePickerDialog()
        dpd.show(  NSLocalizedString("date_picker_title", comment:"")
                 , doneButtonTitle: NSLocalizedString("date_picker_done", comment:"")
                 , cancelButtonTitle: NSLocalizedString("date_picker_cancel", comment:"")
                 , defaultDate: mDataProvider!.currentDate()
                 , datePickerMode: .dateAndTime) { date in
            if let dt = date {
            }
        }
    }
}
