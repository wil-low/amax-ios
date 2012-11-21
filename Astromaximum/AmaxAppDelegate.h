//
//  AmaxAppDelegate.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmaxDataProvider.h"

@interface AmaxAppDelegate : UIResponder <UIApplicationDelegate>
{
    AmaxDataProvider * dataProvider;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@end
