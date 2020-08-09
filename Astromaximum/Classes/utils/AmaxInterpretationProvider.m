//
//  AmaxInterpretationProvider.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxInterpretationProvider.h"
#import "Astromaximum-Swift.h"

@implementation AmaxInterpretationProvider

static NSMutableDictionary* ASPECT_GOODNESS = nil;

+ (AmaxInterpretationProvider *)sharedInstance
{
    static AmaxInterpretationProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmaxInterpretationProvider alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"interpret" ofType:@"dat"];
        NSData *fullData = [NSData dataWithContentsOfFile:filePath];
        sharedInstance->mTexts = [[AmaxDataInputStream alloc] initWithData:fullData];
        ASPECT_GOODNESS = [[NSMutableDictionary alloc]init];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:0] forKey:@"0"];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:1] forKey:@"180"];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:2] forKey:@"120"];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:1] forKey:@"90"];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:2] forKey:@"60"];
        [ASPECT_GOODNESS setValue:[NSNumber numberWithInt:2] forKey:@"45"];
    });
    return (AmaxInterpretationProvider *)sharedInstance;
}

- (NSString *)getTextForEvent:(AmaxEvent*)e
{
    if (e == nil)
        return nil;
    int params[4];
    [self makeInterpreterCode:e into:params];
    NSLog(@"type: %s (%d), params: %d, %d, %d, %d", EVENT_TYPE_STR[e.mEvtype], e.mEvtype,
          params[0], params[1], params[2], params[3]);
    int tempParams[4];
    [mTexts reset];
    [mTexts skipBytes:4];
    int sectionCount = [mTexts readUnsignedShort];
    int eventCount = 0;
    for (int i = 0; i < sectionCount; ++i) {
        if (e.mEvtype == [mTexts readByte]) {
            int offset = [mTexts readInt];
            eventCount = [mTexts readUnsignedShort];
            [mTexts reset];
            [mTexts skipBytes:offset];
            break;
        }
        else {
            [mTexts skipBytes:6];
        }
    }
    for (int i = 0; i < eventCount; ++i) {
        tempParams[0] = [mTexts readByte];
        for (int j = 0; j < 3; ++j)
            tempParams[j + 1] = [mTexts readShort];
        bool isEqual = YES;
        for (int j = 0; j < 3; ++j) {
            if (params[j] != tempParams[j]) {
                isEqual = NO;
                break;
            }
        }
        if (isEqual) {
            return [NSString stringWithFormat:@"%@%@%@", @"<html><head><style type=\"text/css\">body{font-family: '-apple-system','HelveticaNeue';font-size:17;}</style></head><body>", [mTexts readUTF], @"</body></html"];
        }
        else {
            int len = [mTexts readUnsignedShort];
            [mTexts skipBytes:len];
        }
    }
    return nil;
}

- (void)makeInterpreterCode:(AmaxEvent *)ev into:(int*)params
{
    int planet = -1;
    int param0 = -1, param1 = -1, param2 = -1;
    switch (ev.mEvtype) {
		case EV_ASP_EXACT_MOON:
			planet = ev.mPlanet0;
			param0 = ev.mPlanet1;
			param1 = [[ASPECT_GOODNESS objectForKey:[NSString stringWithFormat:@"%d", [ev getDegree]]] integerValue];
			break;
		case EV_ASP_EXACT:
			param0 = ev.mPlanet0;
			param1 = ev.mPlanet1;
			param2 = [[ASPECT_GOODNESS objectForKey:[NSString stringWithFormat:@"%d", [ev getDegree]]] integerValue];
			break;
		case EV_DEGREE_PASS:
			param0 = [ev getDegree];
			break;
		case EV_TITHI:
		case EV_SIGN_ENTER:
			planet = ev.mPlanet0;
			param0 = [ev getDegree];
			break;
		case EV_VOC:
		case EV_VIA_COMBUSTA:
			planet = ev.mPlanet0;
			param0 = 0;
			break;
		case EV_RETROGRADE:
		case EV_PLANET_HOUR:
			param0 = ev.mPlanet0;
			break;
		case EV_MOON_MOVE:
			planet = SE_MOON;
			if (ev.mPlanet1 == -1) {
				param0 = 255;
				param1 = SE_MOON;
			} else {
				if (ev.mPlanet0 == -1)
					param0 = SE_MOON;
				else
					param0 = ev.mPlanet0;
				param1 = ev.mPlanet1;
			}
        default:
            break;
    }
    params[0] = planet;
    params[1] = param0;
    params[2] = param1;
    params[3] = param2;
}

@end
