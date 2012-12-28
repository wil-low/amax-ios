//
//  AmaxInterpreterController.h
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmaxInterpreterController : UIViewController
{
    
}
@property (strong, nonatomic) NSString *interpreterText;

@property (strong, nonatomic) IBOutlet UILabel *dateRangeView;
@property (strong, nonatomic) IBOutlet UITextView *interpreterTextView;
@end
