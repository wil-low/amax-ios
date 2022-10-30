//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxSunDegreeCell : AmaxTableCell {

    private var degreeLabel:UILabel!
    private var zodiacLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        degreeLabel = (self.viewWithTag(3) as! UILabel)
        zodiacLabel = (self.viewWithTag(4) as! UILabel)
    }

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)
        if let events = summaryItem?.mEvents {
            if events.isEmpty {
                return
            }
            let e = events[0]
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
            degreeLabel.text = String(format: "%d\u{00b0}",
                                 e.getDegree() % 30 + 1)
            zodiacLabel.text = String(format: "%c",
                                      getSymbol(TYPE_ZODIAC, Int32(e.getDegree() / 30)))
            setColorOf(label: timeLabel, byEventMode: e)
        }
    }
}
