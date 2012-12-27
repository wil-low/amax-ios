//
//  AmaxEventListViewController.h
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxSummaryItem, AmaxTableCell;

@interface AmaxEventListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}
- (void)setDetailItem:(AmaxSummaryItem *)newDetailItem;
- (void)configureView;

@property (strong, nonatomic) NSString *cellNibName;
@property (strong, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) AmaxSummaryItem *detailItem;
@property (nonatomic, assign) IBOutlet AmaxTableCell *tvCell;
@end
