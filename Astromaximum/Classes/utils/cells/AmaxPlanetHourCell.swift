//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxPlanetHourCell : AmaxTableCell {

    private var hourLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        hourLabel = (self.viewWithTag(3) as! UILabel)
        hourLabel?.text = NSLocalizedString("hour_of", comment: "Planet hour event caption")
    }

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)
        if let e = getActiveEvent() {
            if extRangeMode {
                timeLabel?.numberOfLines = 2
                timeLabel?.text =
                    AmaxEvent.long2String(e.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
                    + "\n"
                    + AmaxEvent.long2String(e.date(at: 1), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
            }
            else {
                timeLabel?.numberOfLines = 1
                timeLabel?.text = e.normalizedRangeString()
            }
            eventLabel?.text = String(format: "%c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
            setColorOf(label: timeLabel, byEventMode: e)
        }
    }
}
