//
//  AmaxTimezoneTransition.h
//  Astromaximum
//
//  Created by admin on 15.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxTimezoneTransition.h"

@implementation AmaxTimezoneTransition

- (id)initWithTime:(NSDate *)aTime offset:(NSTimeInterval)aOffset name:(NSString *)aName
{
    time = aTime;
    offset = aOffset;
    name = aName;
    return self;
}

@end


