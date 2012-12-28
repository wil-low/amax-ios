//
//  AmaxInterpretationProvider.h
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AmaxDataInputStream, AmaxEvent;

@interface AmaxInterpretationProvider : NSObject
{
    AmaxDataInputStream* mTexts;
}

+ (AmaxInterpretationProvider *)sharedInstance;
- (NSString *)getTextForEvent:(AmaxEvent*)e;
- (void)makeInterpreterCode:(AmaxEvent *)e into:(int*)params;

@end
