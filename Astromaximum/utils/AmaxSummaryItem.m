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

- (id)initWithKey:(AmaxEventType)key events:(NSMutableArray *)events
{
    _mKey = key;
    _mEvents = events;
    return self;
}

- (AmaxEvent *)activeEvent
{
    if ([_mEvents count] > 0)
        return [_mEvents objectAtIndex:0];
    return nil;
}

@end
