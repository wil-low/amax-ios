//
//  SummaryItem.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

class AmaxSummaryItem {

    var mEvents = [AmaxEvent]()
    var mKey: AmaxEventType
    var mCusSelection = 0

    enum EventMode: Int {
        case none = 0
        case currentTime = 1
        case customTime = 2
    }

    var mEventMode: EventMode

    init(key: AmaxEventType, events: [AmaxEvent]) {
        mKey = key
        mEvents = events
        mEventMode = .none
    }

    func activeEventPosition(customTime: Int, currentTime: Int) -> Int {
        var index = 0
        var prev = -1
        switch mKey {
    		case EV_MOON_MOVE:
    			for e in mEvents {
    				if e.mEvtype == EV_MOON_MOVE {
                        if dateBetween(currentTime, e.date(at: 0), e.date(at: 1)) == 0 {
                            mEventMode = .currentTime
    						return index
    					}
                        else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
                            mEventMode = currentTime == 0 ? .customTime : .none
    						return index
    					}
    				}
    				index += 1
    			 }
    		case EV_VOC, EV_VIA_COMBUSTA:
    			for e in mEvents {
                    let between = dateBetween(currentTime, e.date(at: 0), e.date(at: 1))
    				if between == 0 {
                        mEventMode = .currentTime
    					return index
    				}
                    else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
    					mEventMode = currentTime == 0 ? .customTime : .none
    					return index
    				}
                    else if between == 1 {
                        mEventMode = .none
    					return index
    				}
    				prev = index
    				index += 1
    			 }
    			return prev
            case EV_ASP_EXACT:
                for e in mEvents {
                    if currentTime < e.date(at: 0) {
                        return index - 1
                    }
                    else {
                        index += 1
                    }
                }
            case EV_SUN_DAY:
                return index
    		default:
    			for e in mEvents {
    				if dateBetween(currentTime, e.date(at: 0), e.date(at: 1)) == 0 {
                        mEventMode = .currentTime
    					return index
    				}
                    else if dateBetween(customTime, e.date(at: 0), e.date(at: 1)) == 0 {
    					mEventMode = currentTime == 0 ? .customTime : .none
    					return index
    				}
    				index += 1
    			 }
        }
        return -1    
    }

    enum ExtendedRangeMode {
        case none
        case oneDay
        case twoDays
        case month
        case year
    }
    
    func extendedRangeMode() -> ExtendedRangeMode {
        switch mKey {
        case EV_MOON_MOVE:
            return .twoDays
        case EV_PLANET_HOUR, EV_PLANET_HOUR_EXT:
            return .oneDay
        case EV_MOON_SIGN:
            return .month
        case EV_RETROGRADE, EV_ASP_EXACT, EV_SUN_DEGREE, EV_TITHI:
            return .year
        default:
            return .none
        }
    }
    
    func getCusSelEvent() -> AmaxEvent? {
        return mEvents[mCusSelection]
    }

    func recalcSelection(time: Int, isCustom: Bool) {
        return
        /*if (events == null) {
            return;
        }
        if (isCustom) {
            cusSelection = -1;
        } else {
            nowSelection = -1;
        }
//    if(!isCustom /*&& !Summary.isCurrentDay*/) {
//      return;
//    }
        if (type == Event.EV_TATTVAS) {
            long date = events[0].getDate0();
            for (int i = 0; i < Astromaximum.TATTVAS_IN_DAY; ++i) {
                if ((time >= date) && (time < date + Astromaximum.MSECINTATTVA)) {
                    if (isCustom) {
                        cusSelection = i;
                    } else {
                        nowSelection = i;
                    }
                    break;
                }
                date += Astromaximum.MSECINTATTVA;
            }
            return;
        }

        for (int i = 0; i < events.length; i++) {
            boolean flg = false;
            Event ev = events[i];
            if (ev != null) {
                if (type == Event.EV_RISE) {
                    long delta = time - ev.getDate0();
                    flg = (delta > DEGREE_DELTA_MSEC1) && (delta < DEGREE_DELTA_MSEC2);
                }
                else {
                    if (!(type == Event.EV_MOON_MOVE && ev.degree != 200)) {
                        flg = contains(events[i], time);
                    }
                }
                if (!flg) {
                    continue;
                }
                if (isCustom) {
                    cusSelection = i;
                } else {
                    nowSelection = i;
                }
                break;
            }
        }*/
    }
}
