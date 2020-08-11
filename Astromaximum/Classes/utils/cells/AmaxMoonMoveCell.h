//
//  AmaxMoonSignCell.h
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxTableCell.h"

@class AmaxDataProvider;

@interface AmaxMoonMoveCell : AmaxTableCell
{
    UILabel *transitionSignLabel;
    AmaxDataProvider* mDataProvider;
}

@end
