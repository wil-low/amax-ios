//
//  AmaxEventListViewController.h
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxSummaryItem;

@interface AmaxEventListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}
- (void)setDetailItem:(AmaxSummaryItem *)newDetailItem;
- (void)configureView;

@property (strong, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) AmaxSummaryItem *detailItem;
@end
