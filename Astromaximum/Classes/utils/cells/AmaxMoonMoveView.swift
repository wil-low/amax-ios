//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxMoonMoveView : UIView {

    var arrowLabel: UILabel?
    var signLabel: UILabel?
    var stackView: UIStackView?
    var planetLabel: UILabel?
    var aspectLabel: UILabel?
    var mDataProvider: AmaxDataProvider?

    override func awakeFromNib() {
        super.awakeFromNib()
        arrowLabel = (self.viewWithTag(1) as! UILabel)
        signLabel = (self.viewWithTag(2) as! UILabel)
        stackView = (self.viewWithTag(3) as! UIStackView)
        planetLabel = (self.viewWithTag(4) as! UILabel)
        aspectLabel = (self.viewWithTag(5) as! UILabel)
        
        arrowLabel?.text = NSLocalizedString("norm_range_arrow", comment: "")
        arrowLabel?.font = UIFont(name: "Astronom", size: CGFloat(5))

        mDataProvider = AmaxDataProvider.sharedInstance
    }
    
    func configure(event e: AmaxEvent, activeEvent: AmaxEvent?, summaryItem si: AmaxSummaryItem) {
        switch (e.mEvtype) {
            case EV_MOON_MOVE:
                signLabel?.isHidden = true
                stackView?.isHidden = true
                arrowLabel?.isHidden = false
                AmaxTableCell.setColorOf(label: arrowLabel, si: si, activeEvent: activeEvent, byEventMode: e)
                break
            case EV_ASP_EXACT_MOON:
                signLabel?.isHidden = true
                arrowLabel?.isHidden = true
                stackView?.isHidden = false
                planetLabel?.text = String(format: "%c", getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
                aspectLabel?.text = String(format: "%c", getSymbol(TYPE_ASPECT, Int32(e.mDegree)))
                let inCurrentDay = e.isDate(at: 0, between: e.mPeriod0, and: e.mPeriod1)
                backgroundColor = inCurrentDay ? ColorCompatibility.systemBackground : ColorCompatibility.systemGray6
                break
            case EV_SIGN_ENTER:
                arrowLabel?.isHidden = true
                stackView?.isHidden = true
                signLabel?.isHidden = false
                signLabel?.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.mDegree)))
                let inCurrentDay = e.isDate(at: 0, between: e.mPeriod0, and: e.mPeriod1)
                backgroundColor = inCurrentDay ? ColorCompatibility.systemBackground : ColorCompatibility.systemGray6
                break
            default:
                break
        }
    }
}
