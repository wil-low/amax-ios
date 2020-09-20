//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

class AmaxTithiCell : AmaxTableCell {

    override func configure(_ si: AmaxSummaryItem, _ extRangeMode: Bool) {
        super.configure(si, extRangeMode)
        if let e = si.mActiveEvent {
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
            eventLabel?.text = String(format: "%@ %d",
                                     NSLocalizedString("tithi", comment: "Tithi"),
                                 e.getDegree())
            self.setColorOf(label: eventLabel!, byEventMode: e)
        }
        self.updateInfoButtonWith(si)
    }
}
