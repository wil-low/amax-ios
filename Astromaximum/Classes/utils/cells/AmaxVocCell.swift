//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxVocCell.h"
//#import "Astromaximum-Swift.h"

class AmaxVocCell : AmaxTableCell {

    override func configure(_ si: AmaxSummaryItem, _ isYearMode: Bool) {
        super.configure(si, isYearMode)
        if let e = si.mActiveEvent {
            eventLabel?.text = "VOC"
            if isYearMode {
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
        }
        self.updateInfoButtonWith(si)
    }
}
