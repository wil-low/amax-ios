//
//  AmaxTimezoneTransition.h
//  Astromaximum
//
//  Created by admin on 15.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmaxTimezoneTransition : NSObject
{
    NSDate *time;
	NSTimeInterval offset;
	NSString *name;
}

- (id)initWithTime:(NSDate *)time offset:(NSTimeInterval)offset name:(NSString *)name;

@end
