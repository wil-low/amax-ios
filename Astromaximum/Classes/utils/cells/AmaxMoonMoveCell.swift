//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxMoonMoveCell : AmaxTableCell {

    private var transitionSignLabel: UILabel?
    private var mDataProvider: AmaxDataProvider?

    override func awakeFromNib() {
        super.awakeFromNib()
        transitionSignLabel = (self.viewWithTag(3) as! UILabel)
        transitionSignLabel?.text = NSLocalizedString("norm_range_arrow", comment: "")
        mDataProvider = AmaxDataProvider.sharedInstance
    }

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)
        if let e = getActiveEvent() {
            //mText0.setTextColor(mDefaultTextColor);
            let date0 = e.date(at: 0)
            switch (e.mEvtype) { 
                case EV_MOON_MOVE:
                    timeLabel?.text = e.normalizedRangeString()
                    eventLabel?.isHidden = true
                    transitionSignLabel?.isHidden = false
                    //setColorByEventMode(mText0, e);
                    break
                case EV_ASP_EXACT_MOON:
                    eventLabel?.text = String(format: "%c %c %c",
                                              getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                              getSymbol(TYPE_ASPECT, Int32(e.mDegree)),
                                              getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
                    timeLabel?.text = AmaxEvent.long2String(date0, format: (mDataProvider?.isInCurrentDay(date: date0))! ? nil : AmaxEvent.monthAbbrDayDateFormatter(), h24: true)
                    eventLabel?.isHidden = false
                    transitionSignLabel?.isHidden = true
                    break
                case EV_SIGN_ENTER:
                    eventLabel?.text = String(format: "%c",
                                              getSymbol(TYPE_ZODIAC, Int32(e.mDegree)))
                    eventLabel?.isHidden = false
                    timeLabel?.text = AmaxEvent.long2String(date0, format: (mDataProvider?.isInCurrentDay(date: date0))! ? nil : AmaxEvent.monthAbbrDayDateFormatter(), h24: true)
                    transitionSignLabel?.isHidden = true
                    break
                default:
                    break
            }
            setColorOf(label: timeLabel, byEventMode: e)
        }
        else {
            eventLabel?.text = ""
            eventLabel?.isHidden = true
            transitionSignLabel?.isHidden = false
        }
    }
}
