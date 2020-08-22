//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxAspectCell.h"
//#import "Astromaximum-Swift.h"

class AmaxRetrogradeCell : AmaxTableCell {

    private var mDataProvider: AmaxDataProvider?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mDataProvider = AmaxDataProvider.sharedInstance
    }

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            eventLabel?.text = String(format: "%c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
            timeLabel?.text = AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false)
        }
        self.updateInfoButtonWith(si)
    }
}
