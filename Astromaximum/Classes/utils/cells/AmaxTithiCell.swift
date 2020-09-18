//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

class AmaxTithiCell : AmaxTableCell {

    override func configure(_ si: AmaxSummaryItem, _ isYearMode: Bool) {
        super.configure(si, isYearMode)
        if let e = si.mActiveEvent {
            timeLabel?.text = e.normalizedRangeString()
            eventLabel?.text = String(format: "%@ %d",
                                     NSLocalizedString("tithi", comment: "Tithi"),
                                 e.getDegree())
            self.setColorOf(label: eventLabel!, byEventMode: e)
        }
        self.updateInfoButtonWith(si)
    }
}
