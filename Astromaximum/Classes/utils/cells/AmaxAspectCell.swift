//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxAspectCell.h"
//#import "Astromaximum-Swift.h"

class AmaxAspectCell : AmaxTableCell {

    private var mDataProvider: AmaxDataProvider?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mDataProvider = AmaxDataProvider.sharedInstance
    }

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if let e = si.mActiveEvent {
            eventLabel?.text = String(format: "%c %c %c",
                                      getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                      getSymbol(TYPE_ASPECT, Int32(e.mDegree)),
                                      getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
            timeLabel?.text = AmaxEvent.long2String(e.date(at: 0), format: nil, h24: false)
        }
        self.updateInfoButtonWith(si)
    }
}
