//
//  main.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AmaxAppDelegate.h"

int main(int argc, char *argv[])
{
    // http://stackoverflow.com/questions/4726269/sigabrt-on-main-function
    int retVal = 0;
    @autoreleasepool {
        NSString *classString = NSStringFromClass([AmaxAppDelegate class]);
        @try {
            retVal = UIApplicationMain(argc, argv, nil, classString);
        }
        @catch (NSException *exception) {
            NSLog(@"Exception - %@", exception);
            NSLog(@"%@", [exception callStackSymbols]);
            exit(EXIT_FAILURE);
        }
        return retVal;
    }
}
