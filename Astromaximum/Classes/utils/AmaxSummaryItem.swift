//
//  SummaryItem.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

class AmaxSummaryItem {

    private var _mEvents = [AmaxEvent]()
    var mEvents: [AmaxEvent] {
        get { return _mEvents }
        set { _mEvents = newValue }
    }
    private var _mActiveEvent: AmaxEvent?
    var mActiveEvent: AmaxEvent? {
        get { return _mActiveEvent }
        set { _mActiveEvent = newValue }
    }

    private var _mKey: AmaxEventType
    var mKey: AmaxEventType {
        get { return _mKey }
        set { _mKey = newValue }
    }

    enum EventMode: Int {
        case none = 0
        case currentTime = 1
        case customTime = 2
    }

    private var _mEventMode: EventMode
    var mEventMode: EventMode {
        get { return _mEventMode }
        set { _mEventMode = newValue }
    }

    init(key: AmaxEventType, events: [AmaxEvent]) {
        _mKey = key
        _mEvents = events
        _mEventMode = .none
    }

    func activeEventPosition(customTime: Int, currentTime: Int) -> Int {
        var index = 0
        var prev = -1
        switch _mKey {
    		case EV_MOON_MOVE:
    			for e in _mEvents {
    				if e.mEvtype == EV_MOON_MOVE {
                        if dateBetween(currentTime, e.date(at: 0), e.date(at: 1)) == 0 {
                            _mEventMode = .currentTime
    						return index
    					}
                        else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
                            _mEventMode = currentTime == 0 ? .customTime : .none
    						return index
    					}
    				}
    				index += 1
    			 }
    		case EV_VOC, EV_VIA_COMBUSTA:
    			for e in _mEvents {
                    let between = dateBetween(currentTime, e.date(at: 0), e.date(at: 1))
    				if between == 0 {
                        _mEventMode = .currentTime
    					return index
    				}
                    else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
    					_mEventMode = currentTime == 0 ? .customTime : .none
    					return index
    				}
                    else if between == 1 {
                        _mEventMode = .none
    					return index
    				}
    				prev = index
    				index += 1
    			 }
    			return prev
            case EV_ASP_EXACT:
                for e in _mEvents {
                    if currentTime < e.date(at: 0) {
                        return index - 1
                    }
                    else {
                        index += 1
                    }
                }
    		default:
    			for e in _mEvents {
    				if dateBetween(currentTime, e.date(at: 0), e.date(at: 1)) == 0 {
                        _mEventMode = .currentTime
    					return index
    				}
                    else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
    					_mEventMode = currentTime == 0 ? .customTime : .none
    					return index
    				}
    				index += 1
    			 }
        }
        return -1    
    }

    func calculateActiveEvent(customTime: Int, currentTime: Int) {
        let pos = activeEventPosition(customTime: customTime, currentTime: currentTime)
        _mActiveEvent = (pos == -1) ? nil : _mEvents[pos]
    }
    
    enum ExtendedRangeMode {
        case none
        case oneDay
        case twoDays
        case month
        case year
    }
    
    func extendedRangeMode() -> ExtendedRangeMode {
        switch _mKey {
        case EV_MOON_MOVE:
            return .twoDays
        case EV_PLANET_HOUR:
            return .oneDay
        case EV_MOON_SIGN:
            return .month
        case EV_RETROGRADE, EV_ASP_EXACT, EV_SUN_DEGREE, EV_TITHI:
            return .year
        case EV_VOC, EV_VIA_COMBUSTA:
            return .none
        default:
            return .none
        }
    }

}
