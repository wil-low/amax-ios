//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

@IBDesignable class PlanetAxisView: UIStackView, NibLoadable {
    
    @IBOutlet weak var mPlanetPass: PlanetPassView!

    var isMoon: Bool!
    var mAxisBlocks = [UIView]()
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
            let v = viewWithTag(i * 10 + 100)!
            addBorders(to: v)
            mAxisBlocks.append(v)
            mAxisNames.append(viewWithTag(i * 10 + 101) as! UILabel)
            mAxisTimes.append(viewWithTag(i * 10 + 102) as! UILabel)
        }
    }
    
    func setData(axis: [AmaxEvent], axisCallback: (UIView, AmaxEvent?) -> Void) {
        for i in 0 ..< 4 {
            if i >= axis.count {
                mAxisNames[i].text = ""
                mAxisTimes[i].text = ""
                mAxisBlocks[i].gestureRecognizers = []
            }
            else {
                mAxisNames[i].text = ["asc", "mc", "dsc", "ic"][Int(axis[i].mDegree - 1)]
                mAxisTimes[i].text = AmaxEvent.long2String(axis[i].date(at: 0), format: nil, h24: false)
                axisCallback(mAxisBlocks[i], axis[i])
            }
        }
    }
}
