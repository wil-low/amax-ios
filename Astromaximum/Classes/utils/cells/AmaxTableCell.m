//
//  AmaxTableCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxTableCell.h"

@implementation AmaxTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    eventLabel = (UILabel *)[self viewWithTag:1];
    timeLabel = (UILabel *)[self viewWithTag:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configure:(AmaxSummaryItem *)si
{
    [timeLabel setText:nil];
    [eventLabel setText:nil];

    if ([[si mEvents]count] > 0)
        timeLabel.text = [NSString stringWithUTF8String:EVENT_TYPE_STR[[si mKey]]];//[[[si mEvents]objectAtIndex:0] description];
    else
        eventLabel.text = [NSString stringWithFormat:@"%c %c" ];
}

- (void)updateInfoButtonWith:(AmaxSummaryItem *)si
{
    
}

- (void)setColorOf:(UILabel *)label byEventMode:(AmaxEvent *)e
{

}

@end
