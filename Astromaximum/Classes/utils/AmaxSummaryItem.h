//
//  SummaryItem.h
//  Astromaximum
//
//  Created by admin on 13.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxTypes.h"
#import "AmaxEvent.h"

@interface AmaxSummaryItem : NSObject
{
}
- (id)initWithKey:(AmaxEventType)key events:(NSMutableArray *)events;
- (AmaxEvent *)activeEvent;

@property (strong, nonatomic) NSMutableArray * mEvents;
@property AmaxEventType mKey;
@end
