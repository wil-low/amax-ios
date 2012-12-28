//
//  AmaxDateSelectController.h
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmaxDateSelectController : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)didSelectDate:(id)sender;

@end
