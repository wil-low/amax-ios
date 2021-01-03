//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class DataMissingView: UIStackView, NibLoadable {
    
    @IBOutlet weak var mNoDataLabel: UILabel!
    @IBOutlet weak var mBuyButton: UIButton!

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
        mNoDataLabel.text = NSLocalizedString("no_data", comment: "")
    }
    
    func setBuyButtonText(year: Int) {
        mBuyButton.setTitle(String(format: "%@ \"%d\"", NSLocalizedString("buy_period", comment: ""), year),
                            for: .normal)
    }
}
