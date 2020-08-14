//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

class AmaxDataProvider : NSObject {

    private var mCommonDataFile: AmaxCommonDataFile
    private var mLocationDataFile: AmaxLocationDataFile?
    private var documentsDirectory: URL
    private var mEvents = [AmaxEvent].init(repeating: AmaxEvent(), count: 100)
    private var mCalendar = Calendar.current
    private var mCurrentDateComponents = DateComponents()
    private var mStartTime = 0
    private var mEndTime = 0

    private var _mEventCache = [AmaxSummaryItem]()
    var mEventCache: [AmaxSummaryItem] {
        get { return _mEventCache }
    }
    private var _mLocationId: String!
    var mLocationId: String! {
        get { return _mLocationId }
        set { _mLocationId = newValue }
    }
    private var _mStartJD = 0
    var mStartJD: Int {
        get { return _mStartJD }
        set { _mStartJD = newValue }
    }
    private var _mFinalJD = 0
    var mFinalJD: Int {
        get { return _mFinalJD }
        set { _mFinalJD = newValue }
    }
    private var _mCurrentHour = 0
    var mCurrentHour: Int {
        get { return _mCurrentHour }
        set { _mCurrentHour = newValue }
    }
    private var _mCurrentMinute = 0
    var mCurrentMinute: Int {
        get { return _mCurrentMinute }
        set { _mCurrentMinute = newValue }
    }
    private var _mCustomHour = 0
    var mCustomHour: Int {
        get { return _mCustomHour }
        set { _mCustomHour = newValue }
    }
    private var _mCustomMinute = 0
    var mCustomMinute: Int {
        get { return _mCustomMinute }
        set { _mCustomMinute = newValue }
    }
    private var _mUseCustomTime = false
    var mUseCustomTime: Bool {
        get { return _mUseCustomTime }
        set { _mUseCustomTime = newValue }
    }
    private var _mLocations = [String: String]()
    var mLocations: [String: String] {
        get { return _mLocations }
        set { _mLocations = newValue }
    }
    private var _mSortedLocationKeys = [String]()
    var mSortedLocationKeys: [String] {
        get { return _mSortedLocationKeys }
        set { _mSortedLocationKeys = newValue }
    }

    let START_PAGE_ITEM_SEQ = [
        EV_VOC,
        EV_MOON_MOVE,
        EV_PLANET_HOUR,
        EV_MOON_SIGN,
        EV_RETROGRADE,
        EV_ASP_EXACT,
        EV_VIA_COMBUSTA,
        EV_SUN_DEGREE,
        EV_TITHI,
    ]

    let WEEK_START_HOUR = [ 0, 3, 6, 2, 5, 1, 4 ]
    let PLANET_HOUR_SEQUENCE = [
        SE_SUN, SE_VENUS, SE_MERCURY, SE_MOON, SE_SATURN, SE_JUPITER, SE_MARS
    ]

    class func getDocumentsDirectory() -> URL? {
        let fileManager = FileManager.default

        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentDirectory = urls.first as URL? {
            return documentDirectory
        }
        else {
            print("Cannot get document directory")
        }
        return nil
    }

    static let sharedInstance = AmaxDataProvider()
    
    override init() {
        let filePath = Bundle.main.path(forResource: "common", ofType:"dat")
        mCommonDataFile = AmaxCommonDataFile(filePath:filePath!)
        documentsDirectory = AmaxDataProvider.getDocumentsDirectory()!
        _mUseCustomTime = false
    }

    func locationFileById(locationId: String) -> URL? {
        return documentsDirectory.appendingPathComponent("\(locationId).dat")
        //return String(format:"%@/%@.dat", documentsDirectory, locationId)
    }

    func loadLocationById(locationId: String) {
        var filePath = locationFileById(locationId: locationId)
        if filePath == nil {
            _ = getLocations()
            filePath = locationFileById(locationId: locationId) //TODO: use first key
        }
        do {
            let fullData = try Data(contentsOf: filePath!)

            mLocationDataFile = AmaxLocationDataFile(data: fullData, headerOnly:false)
            let userDefaults = UserDefaults.standard
            userDefaults.set(locationId, forKey:AMAX_PREFS_KEY_LOCATION_ID)
            _mLocationId = locationId
            mCalendar = Calendar.current
            mCalendar.timeZone = TimeZone(identifier: mLocationDataFile!.mTimezone)!
            var comp = DateComponents()
            comp.year = mLocationDataFile!.mStartYear
            comp.month = mLocationDataFile!.mStartMonth
            comp.day = mLocationDataFile!.mStartDay
            let date = mCalendar.date(from: comp)
            mStartJD = Int(date!.timeIntervalSince1970)
            mFinalJD = mStartJD + mLocationDataFile!.mDayCount * Int(AmaxSECONDS_IN_DAY)
            AmaxEvent.setTimeZone(mLocationDataFile!.mTimezone)
            NSLog("loadLocationById: %@ %@", _mLocationId, locationName())
        }
        catch {
            NSLog("loadLocationById failed")
        }
    }

    func saveCurrentState() {
        let userDefaults = UserDefaults.standard
        let date = mCalendar.date(from: mCurrentDateComponents)
        userDefaults.set(date, forKey: AMAX_PREFS_KEY_CURRENT_DATE)
    }

    func unbundleLocationAsset() -> String! {
        var lastLocationId:String! = nil
        let filePath = Bundle.main.path(forResource: "locations", ofType: "dat")
        let locBundle = AmaxLocationBundle(filePath: filePath)
        var index = 0

        let userDefaults = UserDefaults.standard
        var locationDictionary = [String: String]()
        for _ in 0 ..< locBundle.recordLengths.count {
            let data = locBundle.extractLocation(by: index)
            let datafile = AmaxLocationDataFile(data: data, headerOnly: true)
            lastLocationId = String(format:"%08X", datafile.mCityId)
            NSLog("%d: %@ %@", index, lastLocationId, datafile.mCity)
            let locFile = locationFileById(locationId: lastLocationId)
            do {
                try data.write(to: locFile!)
                locationDictionary[lastLocationId] = datafile.mCity
            }
            catch {
            }
            index += 1
         }
        userDefaults.set(locationDictionary, forKey:AMAX_PREFS_KEY_LOCATION_LIST)
        NSLog("unbundled")
        for item in locationDictionary {
            NSLog("Location %@ : %@", item.key, item.value)
         }
        return lastLocationId
    }

    func restoreSavedState() {
        let userDefaults = UserDefaults.standard
        var locations = getLocations()
        if locations != nil {
            _mLocations = locations as! [String: String]
            for item in _mLocations {
                NSLog("Location %@ : %@", item.key, item.value)
             }
            _mSortedLocationKeys = ((mLocations as NSDictionary).keysSortedByValue(using: #selector(NSString.compare(_:))) as! [String])
        }
        var locationId = userDefaults.string(forKey: AMAX_PREFS_KEY_LOCATION_ID)
        if locationId == nil {
            locationId = unbundleLocationAsset()
            locations = getLocations()
            if locations != nil {
                _mLocations = locations as! [String: String]
                for item in _mLocations {
                    NSLog("Location %@ : %@", item.key, item.value)
                }
                _mSortedLocationKeys = ((mLocations as NSDictionary).keysSortedByValue(using: #selector(NSString.compare(_:))) as! [String])
            }
        }
        loadLocationById(locationId: locationId!)
        if let date = userDefaults.object(forKey: AMAX_PREFS_KEY_CURRENT_DATE) {
            setDate(from: (date as? Date)!)
        }
        else {
            setTodayDate()
        }
    }

    func setDate(from date: Date) {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .weekday]
        mCurrentDateComponents = mCalendar.dateComponents(unitFlags, from:date)
    }

    func setTodayDate() {
        setDate(from: Date())
    }

    func readSubDataFromStream(stream: AmaxDataInputStream, type evtype: AmaxEventType, planet: AmaxPlanet, isCommon: Bool, dayStart: Int, dayEnd: Int) -> Int {
    	let EF_DATE:Int16 = 0x1 // contains 2nd date - 4b
    	let EF_PLANET1:Int16 = 0x2 // contains 1nd planet - 1b
    	let EF_PLANET2:Int16 = 0x4 // contains 2nd planet - 1b
    	let EF_DEGREE:Int16 = 0x8 // contains degree or angle - 2b
    	let EF_CUMUL_DATE_B:Int16 = 0x10 // date are cumulative from 1st 4b - 1b
    	let EF_CUMUL_DATE_W:Int16 = 0x20 // date are cumulative from 1st 4b - 2b
    	let EF_SHORT_DEGREE:Int16 = 0x40 // contains angle 0..180 - 1b
    	let EF_NEXT_DATE2:Int16 = 0x80 // 2nd date is 1st in next event

        stream.reset()
        var eventsCount = 0
        var flag:Int16 = 0
        var skipOff:Int
        let last = AmaxEvent(date: 0, planet: SE_SUN)
        last.mEvtype = evtype
        var fnext_date2:Int16
        let PERIOD:Int = (evtype == EV_ASCAPHETICS) ? 2 * 60 : 24 * 60
        while true {
            _ = stream.readUnsignedByte()
            var rub = stream.readUnsignedByte()
            while evtype.rawValue != rub {
                skipOff = Int(stream.readShort() - 3)
                stream.skipBytes(skipOff)
                _ = stream.readUnsignedByte()
                rub = stream.readUnsignedByte()
                if stream.reachedEOF()
                    {return 0}
            }
            skipOff = Int(stream.readShort())
            flag = stream.readShort()
            if planet.rawValue == stream.readByte() {
                break
            } else {
                stream.skipBytes(skipOff - 6)
            }
            if stream.reachedEOF()
                {return 0}
        }
        let count = stream.readShort()
        let fcumul_date_b = (flag & EF_CUMUL_DATE_B)
        let fcumul_date_w = (flag & EF_CUMUL_DATE_W)
        let fdate = (flag & EF_DATE)
        let fplanet1 = (flag & EF_PLANET1)
        let fplanet2 = (flag & EF_PLANET2)
        let fdegree = (flag & EF_DEGREE)
        let fshort_degree = (flag & EF_SHORT_DEGREE)
        fnext_date2 = (flag & EF_NEXT_DATE2)

        var myplanet0 = planet, myplanet1 = SE_UNDEFINED
        var mydgr = 127
        var mydate0, mydate1: Int
        var cumul: Int
        var date = 0
        for i in 0 ..< count {
            if fcumul_date_b != 0 {
                if i != 0 {
                    cumul = Int(stream.readByte())
                    date += (cumul + PERIOD) * 60
                } else {
                    date = stream.readInt()
                }
            } else if fcumul_date_w != 0 {
                if i != 0 {
                    cumul = Int(stream.readShort())
                    date += (cumul + PERIOD) * 60
                } else {
                    date = stream.readInt()
                }
            } else {
                date = stream.readInt()
            }

            mydate0 = date
            if fdate != 0 {
                mydate1 = stream.readInt() - 1
            } else {
                mydate1 = mydate0
            }
            if fplanet1 != 0 {
                myplanet0 = AmaxPlanet(rawValue: AmaxPlanet.RawValue(stream.readByte()))
            }
            if fplanet2 != 0 {
                myplanet1 = AmaxPlanet(rawValue: AmaxPlanet.RawValue(stream.readByte()))
            }
            if fdegree != 0 {
                if fshort_degree != 0 {
                    mydgr = Int(stream.readUnsignedByte())
                } else {
                    mydgr = Int(stream.readShort())
                }
            }
            if fnext_date2 != 0 {
                last.setDate(at: 1, value:(mydate0 - Int(AmaxROUNDING_SEC)))
                mydate1 = _mFinalJD
            }
            if last.isInPeriod(from: dayStart, to: dayEnd, special: false) {
                mEvents[eventsCount] = last.copy() as! AmaxEvent
                eventsCount += 1
            } else {
                if eventsCount > 0 {
                    break
                }
            }
            last.mPlanet0 = myplanet0
            last.mPlanet1 = myplanet1
            last.mDegree = Int16(mydgr)
            last.setDate(at: 0, value: mydate0)
            last.setDate(at: 1, value: mydate1)
         }
        if last.isInPeriod(from: dayStart, to: dayEnd, special: false) {
            mEvents[eventsCount] = last.copy() as! AmaxEvent
            eventsCount += 1
        }
        return eventsCount
    }

    func currentDateString() -> String! {
        var weekday = "\(mCurrentDateComponents.weekday!)"
        weekday = NSLocalizedString(weekday, tableName: "WeekDays", comment: "")
        return String(format:"%@ %02ld.%02ld %04ld",
                      weekday, mCurrentDateComponents.month!, mCurrentDateComponents.day!, mCurrentDateComponents.year!)
    }

    func getEventsOnPeriodForEvent(evtype: AmaxEventType, planet: AmaxPlanet, special: Bool, from dayStart: Int, to dayEnd: Int, value: Int) -> [AmaxEvent] {
        var flag = false
        var result = [AmaxEvent]()
        let cnt = getEventsForType(evtype: evtype, planet: planet, from: dayStart, to: dayEnd)
        for i in 0 ..< cnt {
            let ev = mEvents[i]
            if ev.isInPeriod(from: dayStart, to:dayEnd, special: special) {
                flag = true
                if value > 0 {
                    ev.mDegree = Int16(value)
                }
                result.append(ev)
            }
            else if flag {
                break
            }
         }
        return result
    }

    func getEventsForType(evtype: AmaxEventType, planet: AmaxPlanet, from dayStart: Int, to dayEnd: Int) -> Int {
        switch (evtype) { 
    		case EV_ASTRORISE,
    		     EV_ASTROSET,
    		     EV_RISE,
    		     EV_SET,
    		     EV_ASCAPHETICS:
                return readSubDataFromStream(stream: mLocationDataFile!.mData, type:evtype, planet:planet, isCommon:false, dayStart:dayStart, dayEnd:dayEnd)
    		default:
                return readSubDataFromStream(stream: mCommonDataFile.data!, type: evtype, planet: planet, isCommon:true, dayStart: dayStart, dayEnd: dayEnd)
        }
    }

    func calculateVOCs() -> [AmaxEvent] {
        return getEventsOnPeriodForEvent(evtype: EV_VOC, planet: SE_MOON, special: false, from: mStartTime, to: mEndTime, value: 0)
    }

    func calculateVC() -> [AmaxEvent] {
        return getEventsOnPeriodForEvent(evtype:  EV_VIA_COMBUSTA, planet: SE_MOON, special: false, from: mStartTime, to: mEndTime, value: 0)
    }

    func calculateSunDegree() -> [AmaxEvent] {
        return getEventsOnPeriodForEvent(evtype:  EV_DEGREE_PASS, planet: SE_SUN, special: false, from: mStartTime, to: mEndTime, value: 0)
    }

    func calculateMoonSign() -> [AmaxEvent] {
        return getEventsOnPeriodForEvent(evtype: EV_SIGN_ENTER, planet: SE_MOON, special: false, from: mStartTime, to: mEndTime, value: 0)
    }

    func calculateTithis() -> [AmaxEvent] {
        return getEventsOnPeriodForEvent(evtype: EV_TITHI, planet:  SE_MOON, special: false, from: mStartTime, to: mEndTime, value: 0)
    }

    func getPlanetaryHoursInto( result: inout [AmaxEvent], currentSunRise: AmaxEvent, nextSunRise: AmaxEvent!, dayOfWeek: Int) {
        var startHour = WEEK_START_HOUR[dayOfWeek]
        let dayHour: Int = (currentSunRise.date(at: 1) - currentSunRise.date(at: 0)) / 12
        let nightHour: Int = (nextSunRise.date(at: 0) - currentSunRise.date(at: 1)) / 12
        NSLog("getPlanetaryHoursInto: %ld, %ld", dayHour, nightHour)
        var st = currentSunRise.date(at: 0)
        for i in 0 ..< 24 {
            let ev:AmaxEvent! = AmaxEvent(date:(st - (st % Int(AmaxROUNDING_SEC))), planet:PLANET_HOUR_SEQUENCE[startHour % 7])
            ev.mEvtype = EV_PLANET_HOUR
            st += i < 12 ? dayHour : nightHour
            var date1:Int = st - Int(AmaxROUNDING_SEC) // exclude last minute
            date1 -= (date1 % Int(AmaxROUNDING_SEC))
            ev.setDate(at: 1, value: date1)
            if ev.isInPeriod(from: mStartTime, to: mEndTime, special: false) {
                result.append(ev)
            }
            startHour += 1
         }
    }

    func calculatePlanetaryHours() -> [AmaxEvent] {
        let sunRises = getEventsOnPeriodForEvent(evtype: EV_RISE, planet: SE_SUN, special: true, from: (mStartTime - Int(AmaxSECONDS_IN_DAY)), to: (mEndTime + Int(AmaxSECONDS_IN_DAY)), value: 0)
        let sunSets = getEventsOnPeriodForEvent(evtype: EV_SET, planet: SE_SUN, special: true, from: (mStartTime - Int(AmaxSECONDS_IN_DAY)), to: (mEndTime + Int(AmaxSECONDS_IN_DAY)), value:0)
        var result = [AmaxEvent]()
        if sunRises.count < 3 || sunRises.count != sunSets.count {
            return result
        }
        for i in 0 ..< sunRises.count {
            sunRises[i].setDate(at: 1, value: sunSets[i].date(at: 0))
        }
        var dayOfWeek:Int = mCurrentDateComponents.weekday! - 1
        if dayOfWeek < 1 {
            dayOfWeek = 6
        }
        else {
            dayOfWeek -= 1
        }
        getPlanetaryHoursInto(result: &result, currentSunRise: sunRises[0], nextSunRise: sunRises[1], dayOfWeek: dayOfWeek)
        dayOfWeek = (dayOfWeek + 1) % 7
        getPlanetaryHoursInto(result: &result, currentSunRise: sunRises[1], nextSunRise: sunRises[2], dayOfWeek: dayOfWeek)
        return result
    }

    func getAspectsOnPeriodForPlanet(planet: AmaxPlanet, from startTime: Int, to endTime: Int) -> [AmaxEvent] {
        var result = [AmaxEvent]()
        var flag = false
        let cnt = getEventsForType(evtype: EV_ASP_EXACT, planet: (planet == SE_MOON ? SE_MOON : SE_UNDEFINED), from: startTime, to: endTime)
        for i in 0 ..< cnt {
            let ev = mEvents[i]
            if planet == SE_UNDEFINED || ev.mPlanet0 == planet || ev.mPlanet1 == planet {
                if ev.isDate(at: 0, between: startTime, and: endTime) {
                    flag = true
                    result.append(ev)
                }
            } else if flag {
                break
            }
         }
        return result
    }

    func mergeEvents(dest: inout [AmaxEvent], add: [AmaxEvent], isSort: Bool)
    {
        for ev in add {
            if isSort {
                var idx = 0
                let dat = ev.date(at: 0)
                let sz = dest.count
                while idx < sz && dat > dest[idx].date(at: 0) {
                    idx += 1
                }
                dest.insert(ev, at: idx)
            }
            else {
                dest.append(ev)
            }
         }
    }

    func calculateMoonMove() -> [AmaxEvent] {
        var asp = getEventsOnPeriodForEvent(evtype: EV_SIGN_ENTER, planet: SE_MOON, special: true, from: (mStartTime - Int(AmaxSECONDS_IN_DAY) * 2), to: (mEndTime + Int(AmaxSECONDS_IN_DAY) * 4), value: 0)
        var moonMoveVec = getAspectsOnPeriodForPlanet(planet: SE_MOON, from: (mStartTime - Int(AmaxSECONDS_IN_DAY) * 2), to: (mEndTime + Int(AmaxSECONDS_IN_DAY) * 2))

        mergeEvents(dest: &moonMoveVec, add: asp, isSort: true)
        asp.removeAll()
        mergeEvents(dest: &asp, add: moonMoveVec, isSort: false)
        var id1 = -1
        var id2 = -1
        var counter = 0
        for ev in asp {
            let dat = ev.date(at: 0)
            if dat < mStartTime {
                id1 = counter
            }
            if id2 == -1 && dat >= mEndTime {
                id2 = counter
            }
            counter += 1
         }
        moonMoveVec.removeAll()
        if id1 != -1 && id2 != -1 {
            for i in id1 ... id2 {
                moonMoveVec.append(asp[i])
            }
        }

        var sz = moonMoveVec.count - 1
        var idx = 1
        for _ in 0 ..< sz {
            let evprev = moonMoveVec[idx - 1]
            let dd = evprev.date(at: (evprev.mEvtype == EV_SIGN_ENTER ? 0 : 1))
            let ev = AmaxEvent(date: dd, planet: SE_UNDEFINED)
            ev.mEvtype = EV_MOON_MOVE
            ev.setDate(at: 1, value: (moonMoveVec[idx].date(at: 0) - Int(AmaxROUNDING_SEC)))
            ev.mPlanet0 = evprev.mPlanet1
            ev.mPlanet1 = moonMoveVec[idx].mPlanet1
            moonMoveVec.insert(ev, at: idx)
            idx += 2
         }
        sz = moonMoveVec.count
        for i in 0 ..< sz {
            let e = moonMoveVec[i]
            if e.mEvtype == EV_MOON_MOVE {
                var j = i - 1
                while j >= 0 {
                    let prev = moonMoveVec[j]
                    if prev.mEvtype != EV_MOON_MOVE {
                        let planet:AmaxPlanet = prev.mPlanet1
                        if planet.rawValue <= SE_SATURN.rawValue {
                            e.mPlanet0 = planet
                            break
                        }
                    }
                    j -= 1
                }
                j = i + 1
                while j < sz {
                    let next = moonMoveVec[j]
                    if next.mEvtype != EV_MOON_MOVE {
                        let planet = next.mPlanet1
                        if planet.rawValue <= SE_SATURN.rawValue {
                            e.mPlanet1 = planet
                            break
                        }
                    }
                    j += 1
                }
            }
            else if e.mEvtype == EV_ASP_EXACT {
                e.mEvtype = EV_ASP_EXACT_MOON
            }
         }
        return moonMoveVec
    }

    func calculateRetrogrades() -> [AmaxEvent] {
        var result = [AmaxEvent]()
        for planet in SE_MERCURY.rawValue ... SE_PLUTO.rawValue {
            let v = getEventsOnPeriodForEvent(evtype: EV_RETROGRADE, planet: AmaxPlanet(rawValue: planet), special: false, from: mStartTime, to: mEndTime, value: 0)
            if v.count > 0 {
                result.append(contentsOf: v)
            }
         }
        return result
    }

    func getRiseSetForPlanet(planet: AmaxPlanet, from startTime: Int, to endTime: Int) -> [AmaxEvent]? {
        /*
        ArrayList<Event> result = new ArrayList<Event>();
        Event eop = getEventOnPeriod(Event.EV_RISE, planet, true, startTime,
                                     endTime);
        if (eop == null || eop.mDate[0] < startTime) {
            eop = new Event(0, planet);
        }
        Event eop1 = getEventOnPeriod(Event.EV_SET, planet, false, startTime,
                                      mEndTime);
        if (eop1 == null || eop1.mDate[0] < startTime) {
            eop1 = new Event(0, planet);
        }
        eop.mDate[1] = eop1.mDate[0];
        result.add(eop);
        return result;
         */
        return nil
    }
    /*
    private Event getEventOnPeriod(int evType, int planet, boolean special,
                                   long startTime, long endTime) {
        int cnt = getEvents(evType, planet, startTime, endTime);
        if (evType == Event.EV_RISE && planet == Event.SE_SUN) {
            Event dummy = new Event(startTime, 0);
            dummy.mDate[1] = endTime;
            MyLog.d("dummy", dummy.toString());
            for (int i = 0; i < cnt; i++) {
                MyLog.d("getEventOnPeriod", mEvents[i].toString());
            }
        }
        for (int i = 0; i < cnt; i++) {
            final Event ev = mEvents[i];
            if (ev.isInPeriod(startTime, endTime, special)) {
                return ev;
            }
        }
        return null;
    }
    */

    func calculateAspects() -> [AmaxEvent] {
        return getAspectsOnPeriodForPlanet(planet: SE_UNDEFINED, from: mStartTime, to: mEndTime)
    }

    func calculateForKey(key: AmaxEventType) -> AmaxSummaryItem? {
        var events: [AmaxEvent]
        switch (key) { 
    		case EV_VOC:
    			events = calculateVOCs()
    			break
    		case EV_VIA_COMBUSTA:
    			events = calculateVC()
    			break
    		case EV_SUN_DEGREE:
    			events = calculateSunDegree()
    			break
    		case EV_MOON_SIGN:
    			events = calculateMoonSign()
    			break
    		case EV_PLANET_HOUR:
    			events = calculatePlanetaryHours()
    			break
    		case EV_ASP_EXACT:
    			events = calculateAspects()
    			break
    		case EV_MOON_MOVE:
    			events = calculateMoonMove()
    			break
    		case EV_TITHI:
    			events = calculateTithis()
    			break
    		case EV_RETROGRADE:
    			events = calculateRetrogrades()
    			break
    		default:
    			return nil
        }
        let si = AmaxSummaryItem(key:key, events: events)
        _mEventCache.append(si)
        return si
    }

    func prepareCalculation() {
        let date = mCalendar.date(from: mCurrentDateComponents)
        mStartTime = Int(date!.timeIntervalSince1970)
        mEndTime = Int(Int32(mStartTime) + AmaxSECONDS_IN_DAY - AmaxROUNDING_SEC)
        AmaxEvent.setTimeRange(from: mStartTime, to: mEndTime)
        _mEventCache.removeAll()

    }

    func calculateAll() {
        for item in START_PAGE_ITEM_SEQ {
            _ = calculateForKey(key: item)
         }
    }

    func locationName() -> String! {
        return mLocationDataFile!.mCity
    }

    func getHighlightTimeString() -> String! {
        if _mUseCustomTime
            {return String(format:"%02ld:%02ld", _mCustomHour, _mCustomMinute)}
        return String(format:"%02ld:%02ld", _mCurrentHour, _mCurrentMinute)
    }

    func changeDate(deltaDays: Int) {
        _mEventCache.removeAll()
        mStartTime += Int(AmaxSECONDS_IN_DAY) * deltaDays + Int(AmaxSECONDS_IN_DAY) / 2
        let newDate = Date(timeIntervalSince1970: TimeInterval(mStartTime))
        mCurrentDateComponents = mCalendar.dateComponents([.year, .month, .day, .weekday], from: newDate)
    }

    func currentDate() -> Date {
        return mCalendar.date(from: mCurrentDateComponents)!
    }

    func getCustomTime() -> Int {
    /*
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
        mCurrentDateComponents = [mCalendar components:unitFlags fromDate:date];

        Calendar calendar = Calendar.getInstance(mCalendar.getTimeZone());
        if (mUseCustomTime) {
            calendar.set(mYear, mMonth, mDay, mCustomHour, mCustomMinute);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
        } else {
            calendar.set(Calendar.YEAR, mYear);
            calendar.set(Calendar.MONTH, mMonth);
            calendar.set(Calendar.DAY_OF_MONTH, mDay);
            mCurrentHour = calendar.get(Calendar.HOUR_OF_DAY);
            mCurrentMinute = calendar.get(Calendar.MINUTE);
        }
        MyLog.d("getCustomTime",
                (String) DateFormat.format("dd MMMM yyyy, kk:mm:ss", calendar));
        return calendar.getTimeInMillis();
     */
        return 0
    }

    func getCurrentTime() -> Int {
        if !_mUseCustomTime {
            var comp = mCurrentDateComponents
            var date = Date()
            let comp2 = mCalendar.dateComponents([.hour, .minute], from: date)
            _mCurrentHour = comp2.hour!
            _mCurrentMinute = comp2.minute!
            comp.hour = _mCurrentHour
            comp.minute = _mCurrentMinute
            date = mCalendar.date(from: comp)!
            return Int(date.timeIntervalSince1970)
        }
        return 0
    }

    func isInCurrentDay(date: Int) -> Bool {
        return dateBetween(date, mStartTime, mEndTime) == 0
    }
}
