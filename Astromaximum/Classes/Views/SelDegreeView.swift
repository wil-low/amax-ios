//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class SelDegreeView: UIView, NibLoadable {
    
    @IBOutlet weak var mPlanet: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func initialize() {
        setupFromNib()
        mPlanet.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE))
        mPlanet.backgroundColor = ColorCompatibility.systemGray4
    }
    
    func setData(ev: AmaxEvent) {
        mPlanet.text = String(format: "%c", getSymbol(TYPE_PLANET, ev.mPlanet0.rawValue))
        switch ev.getDegType() {
        case 0:
            mPlanet.textColor = .orange
        case 1:
            mPlanet.textColor = .black
        case 2:
            mPlanet.textColor = .white
        default:
            mPlanet.textColor = .black
        }
        //print("getDegType=" + String(ev.getDegType()))
    }
}
