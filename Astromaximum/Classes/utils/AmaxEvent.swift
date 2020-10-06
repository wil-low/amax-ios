//
//  AmaxEvent.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 13.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

class AmaxEvent : NSObject, NSCopying, Comparable {
    static func < (lhs: AmaxEvent, rhs: AmaxEvent) -> Bool {
        if lhs.date(at: 0) == rhs.date(at: 0) {
            return lhs.mPlanet0.rawValue < rhs.mPlanet0.rawValue
        }
        return lhs.date(at: 0) < rhs.date(at: 0)
    }

    convenience required init(_ with: AmaxEvent) {
        self.init(date: with.date(at: 0), planet: with.mPlanet0)
        self.mEvtype = with.mEvtype
        self.mDegree = with.mDegree
        self.mPlanet1 = with.mPlanet1
        self.setDate(at: 1, value: with.date(at: 1))
    }

    func copy(with zone: NSZone? = nil) -> Any
    {
        return type(of:self).init(self)
    }

    var mDate = [Int](repeating: 0, count: 2)

    var mPlanet0: AmaxPlanet
    var mPlanet1: AmaxPlanet
    var mEvtype: AmaxEventType
    var mDegree: Int16 = 0
    static var mCalendar:Calendar?
    var mPeriod0: Int = 0
    var mPeriod1: Int = 0
    static let DEFAULT_DATE_FORMAT = "%02d-%02d %02d:%02d"
    static var mMonthAbbrDayDateFormatter:DateFormatter?
    
    let USE_EXACT_RANGE = false

    static func initStatic() {
        mMonthAbbrDayDateFormatter = DateFormatter.init()
        mMonthAbbrDayDateFormatter!.dateFormat = NSLocalizedString("month_abbr_day_date_format", comment: "")
    }

    override init() {
        mEvtype = EV_VOC
        mPlanet0 = SE_UNDEFINED
        mPlanet1 = SE_UNDEFINED
        mDate = [0, 0]
        mDegree = 127
    }

    init(date: Int, planet: AmaxPlanet) {
        mEvtype = EV_VOC
        mPlanet0 = planet
        mPlanet1 = SE_MOON
        mDate = [date, date]
        mDegree = 127
    }
    
    class func setTimeZone(_ timezone: String) {
        mCalendar = Calendar.current
        mCalendar!.timeZone = TimeZone(identifier: timezone)!
    }

    class func long2String(_ date0: Int, format dateFormatter: DateFormatter?, h24: Bool) -> String {

        let date = Date(timeIntervalSince1970: TimeInterval(date0))
        let comps = mCalendar!.dateComponents([.year, .month, .day, .hour, .minute,.weekday], from: date)
   
        var result = ""
        
        if let formatter = dateFormatter {
            formatter.calendar = mCalendar
            result += formatter.string(from: date)
            result += " "
        }
        
        var hh = comps.hour!
        let mm = comps.minute!
        
        if h24 && (hh + mm == 0) {
            hh = 24
        }
        result += String(format: "%02d:%02d", hh, mm)
        return result
    }

    func setTimeRange(from date0: Int, to date1: Int) {
        mPeriod0 = date0
        mPeriod1 = date1
    }

    class func monthAbbrDayDateFormatter() -> DateFormatter? {
        return mMonthAbbrDayDateFormatter
    }

    func isDate(at index: Int, between start: Int, and end: Int) -> Bool {
        let dat = mDate[index]
        return start <= dat && dat < end
    }
    
    override var description : String {
        let result = String(format: "%s %@ - %@ p %d/%d dgr %d",
            "",  //EVENT_TYPE_STR[mEvtype],
            AmaxEvent.long2String(mDate[0], format:AmaxEvent.mMonthAbbrDayDateFormatter, h24:true),
            AmaxEvent.long2String(mDate[1], format:AmaxEvent.mMonthAbbrDayDateFormatter, h24:true),
            mPlanet0 as! CVarArg, mPlanet1 as! CVarArg, mDegree)
        return result
    }

    func normalizedRangeString() -> String {
        var date0 = mDate[0]
        var date1 = mDate[1]
        if USE_EXACT_RANGE {
            if date0 < mPeriod0 {
                date0 = mPeriod0
            }
            if date1 > mPeriod1 {
                date1 = mPeriod1
            }
            return String.init(format: "%@ - %@", AmaxEvent.long2String(date0, format: nil, h24: false), AmaxEvent.long2String(date1, format: nil, h24: true))
        }
        let isTillRequired = date0 < mPeriod0
        let isSinceRequired = date1 > mPeriod1
        
        if isTillRequired && isSinceRequired {
            return NSLocalizedString("norm_range_whole_day", comment: "")
        }
        if (isTillRequired) {
            let s1 = NSLocalizedString("norm_range_arrow", comment:"")
            let s2 = AmaxEvent.long2String(date1, format: nil, h24: true)
            return String(format: "%@ %@", s1, s2)
        }
        if isSinceRequired {
            return String(format: "%@ %@", AmaxEvent.long2String(date0, format: nil, h24: false), NSLocalizedString("norm_range_arrow", comment:""))
        }
        return String(format: "%@ - %@", AmaxEvent.long2String(date0, format: nil, h24: false), AmaxEvent.long2String(date1, format: nil, h24: true))
    }

    func getDegree() -> Int {
        return Int(mDegree & 0x3ff);
    }

    func setDate(at index: Int, value date: Int) {
        mDate[index] = date
    }

    func date(at index: Int) -> Int {
        return mDate[index]
    }

    func isInPeriod(from start: Int, to end: Int, special: Bool) -> Bool {
        if mDate[0] == 0 {
            return false
        }
        let f = dateBetween(mDate[0], start, end) + dateBetween(mDate[1], start, end)
        if (f == 2) || (f == -2) {
            return false
        }
        if special {
            if f == -1 {
                return false
            }
        }
        return true
    }
}
