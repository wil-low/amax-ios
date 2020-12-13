//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class PlanetAxisView: UIStackView, NibLoadable {
    
    @IBOutlet weak var mPlanet: AmaxAstroLabel!
    @IBOutlet weak var mPasses: UIStackView!
    @IBOutlet weak var mSign: AmaxAstroLabel!

    var isMoon: Bool!
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
            (viewWithTag(i * 2 + 2) as! UILabel).layer.borderWidth = 0.8
            (viewWithTag(i * 2 + 2) as! UILabel).layer.borderColor = ColorCompatibility.systemIndigo.cgColor
        }
    }
    
    func setPlanet(_ planet: AmaxPlanet) {
        isMoon = planet == SE_MOON
        mPlanet.text = String(format: "%c", getSymbol(TYPE_PLANET, planet.rawValue))
    }
    
    func setData(passes: [AmaxEvent], axis: [AmaxEvent]) {
        for view in mPasses.subviews {
            view.removeFromSuperview()
        }

        for e in passes {
            if isMoon {
                let pass = AmaxAstroLabel()
                pass.awakeFromNib()
                pass.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(e.getDegree() % 30)))
                //pass.adjustsFontForContentSizeCategory = true
                pass.textAlignment = .center
                mPasses.addArrangedSubview(pass)
            }
            else {
                let pass = UILabel()
                pass.text = String(format: "%d", e.getDegree() % 30 + 1)
                pass.font = UIFont.preferredFont(forTextStyle: .body)
                pass.adjustsFontForContentSizeCategory = true
                pass.textAlignment = .center
                mPasses.addArrangedSubview(pass)
            }
        }
        if !isMoon {
            mSign.text = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(passes[passes.count - 1].getDegree() / 30)))
        }
        for i in 0 ..< 4 {
            if i >= axis.count {
                mAxisNames[i].text = ""
                mAxisTimes[i].text = ""
            }
            else {
                mAxisNames[i].text = ["asc", "mc", "dsc", "ic"][Int(axis[i].mDegree - 1)]
                mAxisTimes[i].text = AmaxEvent.long2String(axis[i].date(at: 0), format: nil, h24: false)
            }
        }
    }
}
