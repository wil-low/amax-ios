//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxMoonMoveCell : AmaxTableCell {

    // -> is eventLabel
    private var planetLabel0: UILabel?
    private var planetLabel1: UILabel?
    private var signLabel: UILabel?
    private var mDataProvider: AmaxDataProvider?

    override func awakeFromNib() {
        super.awakeFromNib()
        eventLabel?.text = NSLocalizedString("norm_range_arrow", comment: "")
        planetLabel0 = (self.viewWithTag(3) as! UILabel)
        planetLabel1 = (self.viewWithTag(4) as! UILabel)
        signLabel = (self.viewWithTag(5) as! UILabel)
        mDataProvider = AmaxDataProvider.sharedInstance
    }

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)
        eventLabel?.font = UIFont(name: "Astronom", size: CGFloat(17))
        if let e = getActiveEvent() {
            //mText0.setTextColor(mDefaultTextColor);
            let date0 = e.date(at: 0)
            switch (e.mEvtype) { 
                case EV_MOON_MOVE:
                    timeLabel?.text = e.normalizedRangeString()
                    if summaryMode && activeEventPosition != -1 {
                        let prevEvent = summaryItem!.mEvents[activeEventPosition - 1]
                        let nextEvent = summaryItem!.mEvents[activeEventPosition + 1]
                        planetLabel0?.text = composeEventLabel(prevEvent)
                        eventLabel?.text = NSLocalizedString("norm_range_arrow", comment: "")
                        planetLabel1?.text = composeEventLabel(nextEvent)
                    }
                    else {
                        planetLabel0?.text = ""
                        eventLabel?.text = NSLocalizedString("norm_range_arrow", comment: "")
                        planetLabel1?.text = ""
                    }

                    signLabel?.text = ""
                    //setColorByEventMode(mText0, e);
                    break
                case EV_ASP_EXACT_MOON:
                    timeLabel?.text = AmaxEvent.long2String(date0, format: (mDataProvider?.isInCurrentDay(date: date0))! ? nil : AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
                    
                    planetLabel0?.text = String(format: "%c", getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
                    signLabel?.text = String(format: "%c", getSymbol(TYPE_ASPECT, Int32(e.mDegree)))
                    planetLabel1?.text = String(format: "%c", getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
                    
                    eventLabel?.text = ""
                    break
                case EV_SIGN_ENTER:
                    timeLabel?.text = AmaxEvent.long2String(date0, format: (mDataProvider?.isInCurrentDay(date: date0))! ? nil : AmaxEvent.monthAbbrDayDateFormatter(), h24: true)

                    planetLabel0?.text = ""
                    signLabel?.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.mDegree)))
                    planetLabel1?.text = ""
 
                    eventLabel?.text = ""
                    break
                default:
                    break
            }
            setColorOf(label: timeLabel, byEventMode: e)
        }
        else {
            planetLabel0?.text = ""
            signLabel?.text = ""
            planetLabel1?.text = ""

            eventLabel?.text = ""
        }
    }
    
    func composeEventLabel(_ event: AmaxEvent?) -> String {
        if let e = event {
            if e.mPlanet1.rawValue == -1 {
                // sign enter
                return String(format: "%c",
                              getSymbol(TYPE_ZODIAC, Int32(e.mDegree)))
            }
            else {
                return String(format: "%c %c",
                              getSymbol(TYPE_ASPECT, Int32(e.mDegree)),
                              getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
            }
        }
        return ""
    }
}
