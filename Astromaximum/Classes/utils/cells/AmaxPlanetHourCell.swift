//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxPlanetHourCell.h"
//#import "Astromaximum-Swift.h"

@objcMembers class AmaxPlanetHourCell : AmaxTableCell {

    private var hourLabel: UILabel?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hourLabel = (self.viewWithTag(3) as! UILabel)
        hourLabel?.text = NSLocalizedString("hour_of", comment: "Planet hour event caption")
    }

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            timeLabel?.text = e.normalizedRangeString()
            eventLabel?.text = String(format: "%c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
            self.setColorOf(label: eventLabel!, byEventMode: e)
        }
        self.updateInfoButtonWith(si)
    }
}
