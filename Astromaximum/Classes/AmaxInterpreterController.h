//
//  AmaxInterpreterController.h
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AmaxEvent;

@interface AmaxInterpreterController : UIViewController
{
    
}
- (NSString *)makeTitleFromEvent:(AmaxEvent *)ev;
- (NSString *)makeDateRangeFromEvent:(AmaxEvent *)ev;

@property (strong, nonatomic) NSString *interpreterText;
@property (strong, nonatomic) AmaxEvent *interpreterEvent;

@property (strong, nonatomic) IBOutlet UIWebView *interpreterTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateRangeView;
@end
