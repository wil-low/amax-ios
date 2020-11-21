//
//  AmaxDataProvider.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

class AmaxDataProvider {

    private var mCommonDataFile: AmaxCommonDataFile
    var mLocationDataFile: AmaxLocationDataFile?
    private var documentsDirectory: URL
    private var mEvents = [AmaxEvent].init(repeating: AmaxEvent(), count: 1000)
    private var mCalendar = Calendar.current
    private var mCurrentDateComponents = DateComponents()
    
    private var mNavroz = [AmaxEvent].init(repeating: AmaxEvent(), count: 2)
    
    private let AmaxROUNDING_SEC = 60

    private var _mStartTime = 0
    var mStartTime: Int {
        get { return _mStartTime }
    }
    private var _mEndTime = 0
    var mEndTime: Int {
        get { return _mEndTime }
    }

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
    private var _mLocations = [String: AmaxLocation]()
    var mLocations: [String: AmaxLocation] {
        get { return _mLocations }
        set { _mLocations = newValue }
    }
    private var _mSortedLocationKeys = [(String, AmaxLocation)]()
    var mSortedLocationKeys: [(String, AmaxLocation)] {
        get { return _mSortedLocationKeys }
        set { _mSortedLocationKeys = newValue }
    }

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
    
    init() {
        AmaxEvent.initStatic()
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
            mCalendar.timeZone = TimeZone(identifier: mLocationDataFile!.location.mTimezone)!
            var comp = DateComponents()
            comp.year = mLocationDataFile!.mStartYear
            comp.month = mLocationDataFile!.mStartMonth
            comp.day = mLocationDataFile!.mStartDay
            let date1 = mCalendar.date(from: comp)
            mStartJD = Int(date1!.timeIntervalSince1970)
            comp.month! += mLocationDataFile!.mMonthCount
            let date2 = mCalendar.date(from: comp)
            mFinalJD = Int(date2!.timeIntervalSince1970) - AmaxROUNDING_SEC
            AmaxEvent.setTimeZone(mLocationDataFile!.location.mTimezone)
            let count = getEventsFor(eventType: EV_NAVROZ, planet: SE_SUN, from: 0, to: mFinalJD)
            if count != 2 {
                NSLog("NAVROZ count = %d!", count)
            }
            else {
                mNavroz[0] = mEvents[0]
                mNavroz[1] = mEvents[1]
            }
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
        var locationDictionary = [String: AmaxLocation]()
        for _ in 0 ..< locBundle.recordLengths.count {
            let data = locBundle.extractLocation(by: index)
            let datafile = AmaxLocationDataFile(data: data, headerOnly: true)
            lastLocationId = String(format:"%08X", datafile.location.mCityId)
            NSLog("%d: %@ %@", index, lastLocationId, datafile.location.mCity)
            let locFile = locationFileById(locationId: lastLocationId)
            do {
                try data.write(to: locFile!)
                locationDictionary[lastLocationId] = datafile.location
            }
            catch {
            }
            index += 1
        }
        var locationSaver = [String: String]()
        for item in locationDictionary {
            let stream = item.value.serialize()
            locationSaver[item.key] = stream
        }
        userDefaults.set(locationSaver, forKey:AMAX_PREFS_KEY_LOCATION_LIST)
        NSLog("unbundled")
        for item in locationDictionary {
            NSLog("Location %@ : %@", item.key, item.value.mCity)
         }
        return lastLocationId
    }

    func restoreSavedState() {
        let userDefaults = UserDefaults.standard
        _mLocations.removeAll()
        var locations = getLocations()
        if locations != nil {
            let locs = locations as! [String: String]
            for item in locs {
                var loc = AmaxLocation()
                loc.deserialize(stream: item.value)
                NSLog("Location %@ : %@, %@", item.key, loc.mCity, loc.mCountry)
                _mLocations[item.key] = loc
            }
            _mSortedLocationKeys = _mLocations.sorted { $0.value.mCity < $1.value.mCity }
        }
        var locationId = userDefaults.string(forKey: AMAX_PREFS_KEY_LOCATION_ID)
        if locationId == nil {
            locationId = unbundleLocationAsset()
            locations = getLocations()
            if locations != nil {
                let locs = locations as! [String: String]
                for item in locs {
                    var loc = AmaxLocation()
                    loc.deserialize(stream: item.value)
                    NSLog("Location %@ : %@", item.key, loc.mCity)
                    _mLocations[item.key] = loc
                }
                _mSortedLocationKeys = _mLocations.sorted { return $0.value.mCity < $1.value.mCity }
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

    func readSubDataFrom(stream: AmaxDataInputStream, eventType evtype: AmaxEventType, planet: AmaxPlanet, isCommon: Bool, dayStart: Int, dayEnd: Int) -> Int {
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
                /*if !isCommon {
                    print(String(format: "readSubData(%u) evt: %u, skipOff %d", evtype.rawValue, rub, skipOff))
                }*/
                stream.skipBytes(skipOff)
                if stream.reachedEOF() {
                    return 0
                }
                _ = stream.readUnsignedByte()
                rub = stream.readUnsignedByte()
                if stream.reachedEOF() {
                    return 0
                }
            }
            skipOff = Int(stream.readShort())
            flag = stream.readShort()
            if planet.rawValue == stream.readByte() {
                break
            }
            else {
                stream.skipBytes(skipOff - 6)
            }
            if stream.reachedEOF() {
                return 0
            }
        }
        /*if !isCommon {
            print(String(format: "readSubData(%u) evt found", evtype.rawValue))
        }*/
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
                last.setDate(at: 1, value: (mydate0 - AmaxROUNDING_SEC))
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
        var month = "\(mCurrentDateComponents.month!)"
        month = NSLocalizedString(month, tableName: "Months", comment: "")
        return String(format: NSLocalizedString("fmt_current_date", comment: ""),
                      weekday, mCurrentDateComponents.year!, month, mCurrentDateComponents.day!)
    }

    func getEventsOnPeriodFor(eventType: AmaxEventType, planet: AmaxPlanet, special: Bool, from dayStart: Int, to dayEnd: Int, value: Int) -> [AmaxEvent] {
        var flag = false
        var result = [AmaxEvent]()
        let cnt = getEventsFor(eventType: eventType, planet: planet, from: dayStart, to: dayEnd)
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

    func getEventsFor(eventType: AmaxEventType, planet: AmaxPlanet, from dayStart: Int, to dayEnd: Int) -> Int {
        switch (eventType) { 
    		case EV_ASTRORISE,
    		     EV_ASTROSET,
    		     EV_RISE,
    		     EV_SET,
                 EV_NAVROZ,
    		     EV_ASCAPHETICS:
                return readSubDataFrom(stream: mLocationDataFile!.mData!, eventType:eventType, planet:planet, isCommon:false, dayStart:dayStart, dayEnd:dayEnd)
    		default:
                return readSubDataFrom(stream: mCommonDataFile.data!, eventType: eventType, planet: planet, isCommon:true, dayStart: dayStart, dayEnd: dayEnd)
        }
    }

    func calculateVOCs() -> [AmaxEvent] {
        return getEventsOnPeriodFor(eventType: EV_VOC, planet: SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
    }

    func calculateVC() -> [AmaxEvent] {
        return getEventsOnPeriodFor(eventType:  EV_VIA_COMBUSTA, planet: SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
    }

    func calculateSunDegree(singleEvent: Bool) -> [AmaxEvent] {
        if singleEvent {
            if let e = getEventOnPeriod(eventType:  EV_DEGREE_PASS, planet: SE_SUN, special: true, from: _mStartTime, to: _mEndTime) {
                return [e]
            }
            else {
                return []
            }
        }
        return getEventsOnPeriodFor(eventType:  EV_DEGREE_PASS, planet: SE_SUN, special: false, from: _mStartTime, to: _mEndTime, value: 0)
    }

    func calculateMoonSign(singleEvent: Bool) -> [AmaxEvent] {
        if singleEvent {
            if let e = getEventOnPeriod(eventType: EV_SIGN_ENTER, planet: SE_MOON, special: true, from: _mStartTime, to: _mEndTime) {
                return [e]
            }
            else {
                return []
            }
        }
        return getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
    }

    func calculateTithis() -> [AmaxEvent] {
        return getEventsOnPeriodFor(eventType: EV_TITHI, planet:  SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
    }

    func getPlanetaryHours(into: inout [AmaxEvent], currentSunRise: AmaxEvent, nextSunRise: AmaxEvent!, dayOfWeek: Int, withTomorrow: Bool) {
        var startHour = WEEK_START_HOUR[dayOfWeek]
        let dayHour: Int = (currentSunRise.date(at: 1) - currentSunRise.date(at: 0)) / 12
        let nightHour: Int = (nextSunRise.date(at: 0) - currentSunRise.date(at: 1)) / 12
        //NSLog("getPlanetaryHours: %ld, %ld", dayHour, nightHour)
        let endTime = withTomorrow ? _mEndTime + 60 * 60 * 12 : _mEndTime
        var st = currentSunRise.date(at: 0)
        for i in 0 ..< 24 {
            let ev:AmaxEvent! = AmaxEvent(date: (st - (st % AmaxROUNDING_SEC)), planet: PLANET_HOUR_SEQUENCE[startHour % 7])
            ev.mEvtype = EV_PLANET_HOUR
            st += i < 12 ? dayHour : nightHour
            var date1 = st - AmaxROUNDING_SEC // exclude last minute
            date1 -= (date1 % AmaxROUNDING_SEC)
            ev.setDate(at: 1, value: date1)
            ev.mDegree = Int16(i)
            if ev.isInPeriod(from: _mStartTime, to: endTime, special: false) {
                into.append(ev)
            }
            startHour += 1
         }
    }

    func calculatePlanetaryHours(withTomorrow: Bool) -> [AmaxEvent] {
        let start = shiftDate(alignedDate: _mStartTime, byAdding: .day, value: -1, isTrailing: false)
        let end = shiftDate(alignedDate: _mEndTime, byAdding: .day, value: 1, isTrailing: false)
        let sunRises = getEventsOnPeriodFor(eventType: EV_RISE, planet: SE_SUN, special: true, from: start, to: end, value: 0)
        let sunSets = getEventsOnPeriodFor(eventType: EV_SET, planet: SE_SUN, special: true, from: start, to: end, value:0)

        var result = [AmaxEvent]()
        if sunRises.count < 3 || sunRises.count != sunSets.count {
            return result
        }
        for i in 0 ..< sunRises.count {
            sunRises[i].setDate(at: 1, value: sunSets[i].date(at: 0))
        }

        let newDate = Date(timeIntervalSince1970: TimeInterval(_mStartTime))
        mCurrentDateComponents = mCalendar.dateComponents([.year, .month, .day, .weekday], from: newDate)

        var dayOfWeek:Int = mCurrentDateComponents.weekday! - 1
        if dayOfWeek < 1 {
            dayOfWeek = 6
        }
        else {
            dayOfWeek -= 1
        }
        for i in 0 ..< sunRises.count - 1 {
            getPlanetaryHours(into: &result, currentSunRise: sunRises[i], nextSunRise: sunRises[i + 1], dayOfWeek: dayOfWeek, withTomorrow: withTomorrow)
            dayOfWeek = (dayOfWeek + 1) % 7
        }
        return result
    }

    func getAspectsOnPeriodFor(planet: AmaxPlanet, from startTime: Int, to endTime: Int) -> [AmaxEvent] {
        var result = [AmaxEvent]()
        var flag = false
        let cnt = getEventsFor(eventType: EV_ASP_EXACT, planet: (planet == SE_MOON ? SE_MOON : SE_UNDEFINED), from: startTime, to: endTime)
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
        var start = shiftDate(alignedDate: _mStartTime, byAdding: .day, value: -2, isTrailing: false)
        var end = shiftDate(alignedDate: _mEndTime, byAdding: .day, value: 4, isTrailing: false)
        var asp = getEventsOnPeriodFor(eventType: EV_SIGN_ENTER, planet: SE_MOON, special: true, from: start, to: end, value: 0)

        start = shiftDate(alignedDate: _mStartTime, byAdding: .day, value: -2, isTrailing: false)
        end = shiftDate(alignedDate: _mEndTime, byAdding: .day, value: 2, isTrailing: false)
        var moonMoveVec = getAspectsOnPeriodFor(planet: SE_MOON, from: start, to: end)

        mergeEvents(dest: &moonMoveVec, add: asp, isSort: true)
        asp.removeAll()
        mergeEvents(dest: &asp, add: moonMoveVec, isSort: false)
        
        // time range to filter events afterwards
        var aspTime1 = -1
        var aspTime2 = -1

        for ev in asp {
            let dat = ev.date(at: 0)
            if dat < _mStartTime {
                aspTime1 = dat
            }
            if aspTime2 == -1 && dat >= _mEndTime {
                aspTime2 = dat
            }
        }

        var sz = moonMoveVec.count - 1
        var idx = 1
        for _ in 0 ..< sz {
            let evprev = moonMoveVec[idx - 1]
            let dd = evprev.date(at: (evprev.mEvtype == EV_SIGN_ENTER ? 0 : 1))
            let ev = AmaxEvent(date: dd, planet: SE_UNDEFINED)
            ev.mEvtype = EV_MOON_MOVE
            ev.setDate(at: 1, value: (moonMoveVec[idx].date(at: 0) - AmaxROUNDING_SEC))
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
                        let planet = prev.mPlanet1
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
        /*
        for e in moonMoveVec {
            print("MoonMove1: " + e.description)
        }
        print("aspTimes: " +
                AmaxEvent.long2String(aspTime1, format: AmaxEvent.mMonthAbbrDayDateFormatter, h24: true) +
                " - " +
                AmaxEvent.long2String(aspTime2, format: AmaxEvent.mMonthAbbrDayDateFormatter, h24: true) +
                String(format: " (%d / %d)", aspTime1, aspTime2))
        */
        moonMoveVec.removeAll(where: { (e) -> Bool in
            let date = e.date(at: 0)
            return date < aspTime1 || date > aspTime2 || (date == aspTime2 && e.mEvtype == EV_MOON_MOVE)
        })
        /*
        for e in moonMoveVec {
            print("MoonMove2: " + e.description)
        }
        */
        return moonMoveVec
    }

    func calculateRetrogrades() -> [AmaxEvent] {
        var result = [AmaxEvent]()
        for planet in SE_MERCURY.rawValue ... SE_PLUTO.rawValue {
            let v = getEventsOnPeriodFor(eventType: EV_RETROGRADE, planet: AmaxPlanet(rawValue: planet), special: false, from: _mStartTime, to: _mEndTime, value: 0)
            if v.count > 0 {
                result.append(contentsOf: v)
            }
        }
        result.sort(by: <)
        return result
    }

    func calculateSunDay() -> [AmaxEvent] {
        var result = [AmaxEvent]()
        if let sunriseEvent = getEventOnPeriod(eventType: EV_RISE, planet: SE_SUN, special: true, from: _mStartTime, to: _mEndTime) {
            var navroz = mNavroz[1].date(at: 0)
            //print("Navroz: " + mNavroz[1].description)
            let sunrise = sunriseEvent.date(at: 0)
            if sunrise < navroz {
                navroz = mNavroz[0].date(at: 0)
            }
            //print("sunrise: " + String(format: "%d", sunrise - navroz))
            var pltDaySun: Int = ((sunrise - navroz) * 1000 / (60 * 60 * 24) + 500) / 1000
            if pltDaySun < 360 {
                pltDaySun = pltDaySun % 30 + 1
            }
            sunriseEvent.mDegree = Int16(pltDaySun)
            //print("sunrise: " + sunriseEvent.description)
            result.append(sunriseEvent)
        }
        return result
    }

    func calculateMoonPhase() -> [AmaxEvent] {
        var result = [AmaxEvent]()
        result = getEventsOnPeriodFor(eventType: EV_MOON_PHASE, planet: SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
        return result
    }

    func calculateMoonDay() -> [AmaxEvent] {
        var result = [AmaxEvent]()
        result = getEventsOnPeriodFor(eventType: EV_RISE, planet: SE_MOON, special: false, from: _mStartTime, to: _mEndTime, value: 0)
        return result
    }

    func calculateMoonRise() -> [AmaxEvent] {
        let result = [AmaxEvent]()
        /*
        for planet in SE_MERCURY.rawValue ... SE_PLUTO.rawValue {
            let v = getEventsOnPeriodFor(eventType: EV_RETROGRADE, planet: AmaxPlanet(rawValue: planet), special: false, from: _mStartTime, to: _mEndTime, value: 0)
            if v.count > 0 {
                result.append(contentsOf: v)
            }
        }
        result.sort(by: <) */
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
    
    func getEventOnPeriod(eventType: AmaxEventType, planet: AmaxPlanet, special: Bool, from: Int, to: Int) -> AmaxEvent? {
        let events = getEventsOnPeriodFor(eventType: eventType, planet: planet, special: false, from: from, to: to, value: 0)
        for e in events {
            if (e.isInPeriod(from: from, to: to, special: special)) {
                return e;
            }
        }
        if special && events.count > 0 {
            return events[0]
        }
        return nil;
    }

    func calculateAspects() -> [AmaxEvent] {
        return getAspectsOnPeriodFor(planet: SE_UNDEFINED, from: _mStartTime, to: _mEndTime)
    }

    func calculateFor(eventType: AmaxEventType, extRange: Bool) -> AmaxSummaryItem? {
        var events: [AmaxEvent]
        switch (eventType) { 
    		case EV_VOC:
    			events = calculateVOCs()
    			break
    		case EV_VIA_COMBUSTA:
    			events = calculateVC()
    			break
    		case EV_SUN_DEGREE:
    			events = calculateSunDegree(singleEvent: false)
    			break
            case EV_SUN_DEGREE_LARGE:
                events = calculateSunDegree(singleEvent: true)
                break
    		case EV_MOON_SIGN:
    			events = calculateMoonSign(singleEvent: false)
    			break
            case EV_MOON_SIGN_LARGE:
                events = calculateMoonSign(singleEvent: true)
                break
    		case EV_PLANET_HOUR:
                events = calculatePlanetaryHours(withTomorrow: false)
    			break
            case EV_PLANET_HOUR_EXT:
                events = calculatePlanetaryHours(withTomorrow: true)
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
            case EV_SUN_DAY:
                events = calculateSunDay()
                break
            case EV_MOON_DAY:
                events = calculateMoonDay()
                break
            case EV_MOON_RISE:
                events = calculateMoonRise()
                break
            case EV_MOON_PHASE:
                events = calculateMoonPhase()
                break
    		default:
    			return nil
        }
        for e in events {
            e.setTimeRange(from: _mStartTime, to: _mEndTime)
        }
        let si = AmaxSummaryItem(key: eventType, events: events)
        _mEventCache.append(si)
        return si
    }

    func prepareCalculation() {
        _mEventCache.removeAll()
        _mStartTime = Int(currentDate().timeIntervalSince1970)
        _ = changeDate(deltaDays: 0)
    }

    func calculateAll(types: [AmaxEventType]) {
        for item in types {
            _ = calculateFor(eventType: item, extRange: false)
         }
    }

    func locationName() -> String! {
        return mLocationDataFile!.location.mCity
    }

    func getHighlightTimeString() -> String! {
        if _mUseCustomTime
            {return String(format:"%02ld:%02ld", _mCustomHour, _mCustomMinute)}
        return String(format:"%02ld:%02ld", _mCurrentHour, _mCurrentMinute)
    }

    func alignDate(_ date: Int) -> Int {
        var dc = mCalendar.dateComponents([.year, .month, .day, .weekday], from: Date(timeIntervalSince1970: TimeInterval(date)))
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        let aligned = mCalendar.date(from: dc)!
        return Int(aligned.timeIntervalSince1970)
    }

    func changeDate(deltaDays: Int) -> Bool {
        let AmaxSECONDS_IN_DAY = 24 * 60 * 60;
        let newStart = alignDate(_mStartTime + AmaxSECONDS_IN_DAY * deltaDays + AmaxSECONDS_IN_DAY / 2)
        if newStart < mStartJD || newStart >= mFinalJD {
            return false
        }
        let newStartAligned = Date(timeIntervalSince1970: TimeInterval(newStart))
        mCurrentDateComponents = mCalendar.dateComponents([.year, .month, .day, .weekday], from: newStartAligned)

        let newEnd = shiftDate(alignedDate: newStart, byAdding: .day, value: 1, isTrailing: true)
        setRange(from: newStart, to: newEnd)
/*
        let startPrint = Date(timeIntervalSince1970: TimeInterval(_mStartTime))
        let endPrint = Date(timeIntervalSince1970: TimeInterval(_mEndTime))
        print("changeDate: " + startPrint.description + ", " + endPrint.description + "; " + (newEnd - newStart).description)
        print("mStartTime: " + AmaxEvent.long2String(_mStartTime, format: AmaxEvent.mMonthAbbrDayDateFormatter, h24: true) + " (" + String(format: "%d", _mStartTime) + ")")
        print("mEndTime: " + AmaxEvent.long2String(_mEndTime, format: AmaxEvent.mMonthAbbrDayDateFormatter, h24: true) + " (" + String(format: "%d", _mEndTime) + ")")
 */
        return true
    }

    func currentDate() -> Date {
        return mCalendar.date(from: mCurrentDateComponents)!
    }

    func getCustomTime() -> Int {
        let comp = mCurrentDateComponents
        let date = Date()
        var comp2 = mCalendar.dateComponents([.year, .month, .hour, .minute], from: date)
        if _mUseCustomTime {
            comp2.year = comp.year
            comp2.month = comp.month
            comp2.day = comp.day
            comp2.hour = mCustomHour
            comp2.minute = mCustomMinute
        }
        else {
            comp2.year = comp.year
            comp2.month = comp.month
            comp2.day = comp.day
            _mCurrentHour = comp2.hour!
            _mCurrentMinute = comp2.minute!
        }
        let date2 = mCalendar.date(from: comp2)!
        return Int(date2.timeIntervalSince1970)
    }

    func getCurrentTime() -> Int {
        if !_mUseCustomTime {
            let date = Date()
            let comp2 = mCalendar.dateComponents([.hour, .minute], from: date)
            _mCurrentHour = comp2.hour!
            _mCurrentMinute = comp2.minute!
            return Int(date.timeIntervalSince1970)
        }
        return 0
    }

    func isInCurrentDay(date: Int) -> Bool {
        return dateBetween(date, _mStartTime, _mEndTime) == 0
    }
    
    func setRange(from: Int, to: Int) {
        _mStartTime = from
        _mEndTime = to
        _mEventCache.removeAll()
    }

    func shiftDate(alignedDate date: Int, byAdding component: Calendar.Component, value val: Int, isTrailing: Bool) -> Int {
        let newAligned = mCalendar.date(byAdding: component, value: val, to: Date(timeIntervalSince1970: TimeInterval(date)), wrappingComponents: false)
        var result = Int(newAligned!.timeIntervalSince1970)
        if isTrailing {
            result -= AmaxROUNDING_SEC
        }
        return result
    }

    func setExtRange(mode: AmaxSummaryItem.ExtendedRangeMode, provider: AmaxDataProvider) {
        var from = 0, to = 0
        switch mode {
        case .oneDay:
            from = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: -1, isTrailing: false)
            to = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: 2, isTrailing: true)
        case .twoDays:
            from = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: -2, isTrailing: false)
            to = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: 3, isTrailing: true)
        case .month:
            from = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: -30, isTrailing: false)
            to = shiftDate(alignedDate: provider.mStartTime, byAdding: .day, value: 31, isTrailing: true)
        case .year:
            from = provider.mStartJD
            to = provider.mFinalJD
        default:
            return
        }
        if from < provider.mStartJD {
            from = provider.mStartJD
        }
        if to > provider.mFinalJD {
            to = provider.mFinalJD
        }
        _mStartTime = from
        _mEndTime = to
        _mEventCache.removeAll()
    }
}
