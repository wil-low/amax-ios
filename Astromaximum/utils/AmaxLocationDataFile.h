//
//  AmaxLocationDataFile.h
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmaxDataInputStream.h"
#import "AmaxTimezoneTransition.h"

@interface AmaxLocationDataFile : NSObject
{
	int startYear;
	int startMonth;
	int startDay;
	int dayCount;
	int cityId;
	int coords[3];
	NSString *city;
	NSString *state;
	NSString *country;
	NSString *timezone;
	NSString *customData;
	NSMutableArray *transitions;
	AmaxDataInputStream *data;
}

- (id)initWithFilePath:(NSString *)filePath;

@end
