//
//  SummaryItem.m
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxSummaryItem.h"


@implementation AmaxSummaryItem
@synthesize events = _events;
@synthesize key = _key;

- (id)initWithKey:(AmaxEventType)key events:(NSMutableArray *)events
{
    _key = key;
    _events = events;
    return self;
}

@end
