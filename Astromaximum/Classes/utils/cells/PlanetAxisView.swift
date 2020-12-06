//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class PlanetAxisView: UIStackView, NibLoadable {
    
    var mAxisNames = [UILabel]()
    var mAxisTimes = [UILabel]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func initialize() {
        setupFromNib()
        for i in 0 ..< 4 {
            mAxisNames.append(viewWithTag(i * 2 + 1) as! UILabel)
            mAxisTimes.append(viewWithTag(i * 2 + 2) as! UILabel)
        }
    }
    
    func setData(events: [AmaxEvent]) {
        for i in 0 ..< 4 {
            mAxisNames[i].text = "Asc"
            mAxisTimes[i].text = "11:23"
        }

    }
}
