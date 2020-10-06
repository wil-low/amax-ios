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

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)
        if let e = getActiveEvent() {
            eventLabel?.text = "VOC"
            timeLabel?.text = e.normalizedRangeString()
            setColorOf(label: timeLabel, byEventMode: e)
        }
    }
}
