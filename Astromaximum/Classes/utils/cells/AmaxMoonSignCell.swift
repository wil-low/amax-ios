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
            eventLabel?.text = String(format: "%c %c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                      getSymbol(TYPE_ZODIAC, Int32(e.getDegree())))
            setColorOf(label: timeLabel, byEventMode: e)
        }
        else {
            eventLabel?.text = "111"
        }
    }
}
