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

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            timeLabel?.text = e.normalizedRangeString()
            eventLabel?.text = String(format: "%c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
            degreeLabel.text = String(format: "%d\u{00b0}",
                                 e.getDegree() % 30 + 1)
            zodiacLabel.text = String(format: "%c",
                                      getSymbol(TYPE_ZODIAC, Int32(e.getDegree() / 30)))
            self.setColorOf(label: eventLabel!, byEventMode: e)
        }
        self.updateInfoButtonWith(si)
    }
}
