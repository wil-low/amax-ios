//
//  AmaxMasterViewController.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxDetailViewController;

@interface AmaxMasterViewController : UITableViewController

@property (strong, nonatomic) AmaxDetailViewController *detailViewController;

@end
