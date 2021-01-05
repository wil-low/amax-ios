//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class RetrogradeView: UIView, NibLoadable {
    
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
    }
    
    func setData(axis: [AmaxEvent], axisCallback: (UIView, AmaxEvent?) -> Void) {
    }
}
