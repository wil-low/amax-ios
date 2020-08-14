//
//  AmaxTableCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxTableCell : UITableViewCell {

    var eventLabel: UILabel?
    var timeLabel: UILabel?
    var summaryItem: AmaxSummaryItem?
    var controller: AmaxBaseViewController?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let v = viewWithTag(1) {
            eventLabel = v as? UILabel
        }
        if let v = viewWithTag(2) {
            timeLabel = v as? UILabel
        }
    }

    func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ si: AmaxSummaryItem) {
        summaryItem = si

        timeLabel?.text = nil

        if si.mEvents.count > 0 {
            //TODO: timeLabel.text = String(UTF8String:EVENT_TYPE_STR[si.mKey()])
        }
        else {
            var textId = ""
            switch (si.mKey) {
            case EV_VOC:
                textId = "no_voc"
                break
            case EV_VIA_COMBUSTA:
                textId = "no_vc"
                break
            case EV_ASP_EXACT:
                textId = "no_aspects"
                break
            case EV_RETROGRADE:
                textId = "no_retrograde"
                break
            case EV_MOON_SIGN:
                textId = "no_moon_sign"
                break
            case EV_MOON_MOVE:
                textId = "no_moon_move"
                break
            case EV_PLANET_HOUR:
                textId = "no_planet_hours"
                break
            case EV_TITHI:
                textId = "no_tithi"
                break
            case EV_SUN_DEGREE:
                textId = "no_sun_degree"
                break
            default:
                break
            }
            eventLabel?.text = NSLocalizedString(textId, comment: "")
        }
    }

    func updateInfoButtonWith(_ si: AmaxSummaryItem!) {

    }

    func setColorOf(label: UILabel, byEventMode e: AmaxEvent!) {

    }
}
