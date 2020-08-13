//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxMoonSignCell.h"
//#import "Astromaximum-Swift.h"

class AmaxMoonSignCell : AmaxTableCell {

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            timeLabel?.text = e.normalizedRangeString()
            eventLabel?.text = String(format: "%c %c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                      getSymbol(TYPE_ZODIAC, Int32(e.getDegree())))
            setColorOf(label: eventLabel!, byEventMode: e)
        }
        self.updateInfoButtonWith(si)
    }
}
