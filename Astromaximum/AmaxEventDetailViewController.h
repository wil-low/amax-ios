//
//  AmaxDetailViewController.h
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AmaxSummaryItem;

@interface AmaxEventDetailViewController : UIViewController
{
    
}

@property (strong, nonatomic) AmaxSummaryItem *detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
