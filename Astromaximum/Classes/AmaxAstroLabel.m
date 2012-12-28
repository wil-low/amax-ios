//
//  AmaxAstroLabel.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxAstroLabel.h"

@implementation AmaxAstroLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Astronom" size:self.font.pointSize];
}

@end
