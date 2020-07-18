//
//  SummaryItem.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSummaryItem.h"


@implementation AmaxSummaryItem
@synthesize mEvents = _mEvents;
@synthesize mKey = _mKey;
@synthesize mEventMode = _mEventMode;
@synthesize mActiveEvent = _activeEvent;

enum {
    EVENT_MODE_NONE = 0,
    EVENT_MODE_CURRENT_TIME = 1,
    EVENT_MODE_CUSTOM_TIME = 2
};

- (id)initWithKey:(AmaxEventType)key events:(NSMutableArray *)events
{
    _mKey = key;
    _mEvents = events;
    _mEventMode = EVENT_MODE_NONE;
    return self;
}

- (int)activeEventPositionWithCustomTime:(long)customTime currentTime:(long)currentTime
{
    int index = 0;
    int prev = -1;
    switch (_mKey) {
		case EV_MOON_MOVE:
			for (AmaxEvent *e in _mEvents) {
				if (e.mEvtype == EV_MOON_MOVE) {
					if (dateBetween(currentTime, [e dateAt:0], [e dateAt:1]) == 0) {
						_mEventMode = EVENT_MODE_CURRENT_TIME;
						return index;
					} else if (dateBetween(customTime, [e dateAt:0], [e dateAt:1]) == 0) {
						_mEventMode = currentTime == 0 ? EVENT_MODE_CUSTOM_TIME : EVENT_MODE_NONE;
						return index;
					}
				}
				++index;
			}
			break;
		case EV_VOC:
		case EV_VIA_COMBUSTA:
			for (AmaxEvent *e in _mEvents) {
				int between = dateBetween(currentTime, [e dateAt:0], [e dateAt:1]);
				if (between == 0) {
					_mEventMode = EVENT_MODE_CURRENT_TIME;
					return index;
				} else if (dateBetween(customTime, [e dateAt:0], [e dateAt:1]) == 0) {
					_mEventMode = currentTime == 0 ? EVENT_MODE_CUSTOM_TIME : EVENT_MODE_NONE;
					return index;
				} else if (between == 1) {
					_mEventMode = EVENT_MODE_NONE;
					return index;
				}
				prev = index;
				++index;
			}
			return prev;
		default:
			for (AmaxEvent *e in _mEvents) {
				if (dateBetween(currentTime, [e dateAt:0], [e dateAt:1]) == 0) {
					_mEventMode = EVENT_MODE_CURRENT_TIME;
					return index;
				} else if (dateBetween(customTime, [e dateAt:0], [e dateAt:1]) == 0) {
					_mEventMode = currentTime == 0 ? EVENT_MODE_CUSTOM_TIME : EVENT_MODE_NONE;
					return index;
				}
				++index;
			}
			break;
    }
    return -1;    
}

- (void)calculateActiveEventWithCustomTime:(long)customTime currentTime:(long)currentTime
{
    int pos = [self activeEventPositionWithCustomTime:customTime currentTime:currentTime];
//    _activeEvent = (pos == -1) ? nil : [_mEvents objectAtIndex:0];
    _activeEvent = [_mEvents count] == 0 ? nil : [_mEvents objectAtIndex:0];
}

@end
