//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxViaCombustaCell.h"
//#import "Astromaximum-Swift.h"

class AmaxViaCombustaCell : AmaxTableCell {

    override func configure(_ si: AmaxSummaryItem, _ extRangeMode: Bool) {
        super.configure(si, extRangeMode)
        if let e = si.mActiveEvent {
            eventLabel?.text = "VC"
            timeLabel?.text = e.normalizedRangeString()
        }
        self.updateInfoButtonWith(si)
    }
}
