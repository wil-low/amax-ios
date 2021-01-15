//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class PlanetPassView: UIStackView, NibLoadable {
    
    @IBOutlet weak var mPlanet: AmaxAstroLabel!
    @IBOutlet weak var mPasses: UIStackView!
    @IBOutlet weak var mSign: AmaxAstroLabel!

    var isMoon: Bool!
    
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
    }
    
    func setPlanet(_ planet: AmaxPlanet) {
        isMoon = planet == SE_MOON
        mPlanet.text = String(format: "%c", getSymbol(TYPE_PLANET, planet.rawValue))
        if isMoon {
            mSign.isHidden = true
        }
        else {
            mSign.widthAnchor.constraint(equalTo: mPlanet.widthAnchor, multiplier: 1).isActive = true
        }
    }
    
    func setData(passes: [AmaxEvent], passCallback: (UIView, AmaxEvent?) -> Void) {
        for view in mPasses.subviews {
            view.removeFromSuperview()
        }

        for e in passes {
            if isMoon {
                let pass = AmaxAstroLabel()
                pass.adjustsFontForContentSizeCategory = true
                pass.awakeFromNib()
                pass.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree() % 30)))
                pass.textAlignment = .center
                pass.isUserInteractionEnabled = true
                passCallback(pass, e)
                addBorders(to: pass)
                mPasses.addArrangedSubview(pass)
            }
            else {
                let pass = UILabel()
                pass.text = String(format: "%d", e.getDegree() % 30 + 1)
                pass.font = UIFont.preferredFont(forTextStyle: .body)
                pass.adjustsFontForContentSizeCategory = true
                pass.textAlignment = .center
                pass.isUserInteractionEnabled = true
                passCallback(pass, e)
                addBorders(to: pass)
                mPasses.addArrangedSubview(pass)
            }
        }
        if !isMoon {
            mSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(passes[passes.count - 1].getDegree() / 30)))
        }
    }
}
