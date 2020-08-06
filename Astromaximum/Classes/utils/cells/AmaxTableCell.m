//
//  AmaxTableCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

#import "AmaxTableCell.h"
#import "AmaxBaseViewController.h"

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
    summaryItem = si;

    [timeLabel setText:nil];

    if ([[si mEvents]count] > 0) {
        timeLabel.text = [NSString stringWithUTF8String:EVENT_TYPE_STR[[si mKey]]];
    }
    else {
        NSString* textId = [NSString string];
        switch ([si mKey]) {
        case EV_VOC:
            textId = @"no_voc";
            break;
        case EV_VIA_COMBUSTA:
            textId = @"no_vc";
            break;
        case EV_ASP_EXACT:
            textId = @"no_aspects";
            break;
        case EV_RETROGRADE:
            textId = @"no_retrograde";
            break;
        case EV_MOON_SIGN:
            textId = @"no_moon_sign";
            break;
        case EV_MOON_MOVE:
            textId = @"no_moon_move";
            break;
        case EV_PLANET_HOUR:
            textId = @"no_planet_hours";
            break;
        case EV_TITHI:
            textId = @"no_tithi";
            break;
        case EV_SUN_DEGREE:
            textId = @"no_sun_degree";
            break;
        default:
            break;
        }
        eventLabel.text = NSLocalizedString(textId, "");
    }
}

- (void)updateInfoButtonWith:(AmaxSummaryItem *)si
{
    
}

- (void)setColorOf:(UILabel *)label byEventMode:(AmaxEvent *)e
{

}

@end
