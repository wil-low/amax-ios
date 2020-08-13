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

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            timeLabel?.text = e.normalizedRangeString()
        }
        self.updateInfoButtonWith(si)
    }
}
