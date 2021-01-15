//
//  AmaxAstroLabel.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxAstroLabel : UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        if adjustsFontForContentSizeCategory {
            let customFont = UIFont(name: "Astronom", size: UIFont.labelFontSize)
            font = UIFontMetrics.default.scaledFont(for: customFont!)
        }
        else {
            font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE) /*font.pointSize*/)
        }
        textColor = ColorCompatibility.label
    }

}
