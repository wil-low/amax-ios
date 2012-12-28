//
//  AmaxSettingsController.h
//  Astromaximum
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxLocationListController;

@interface AmaxSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (strong, nonatomic) AmaxLocationListController *locationListController;

@end
