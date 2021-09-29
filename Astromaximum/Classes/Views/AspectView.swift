//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class AspectView: UIView, NibLoadable {
    
    @IBOutlet weak var mAspect: UILabel!

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
        mAspect.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE))
        layer.borderWidth = 0.8
        layer.borderColor = UIColor.red.cgColor
    }
    
    func setData(ev: AmaxEvent) {
        mAspect.text = String(format: "%c %c %c",
                                  getSymbol(TYPE_PLANET, ev.mPlanet0.rawValue),
                                  getSymbol(TYPE_ASPECT, Int32(ev.mDegree)),
                                  getSymbol(TYPE_PLANET, ev.mPlanet1.rawValue))
    }
}
