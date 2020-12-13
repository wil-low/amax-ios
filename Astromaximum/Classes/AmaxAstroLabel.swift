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
        let customFont = UIFont(name: "Astronom", size: UIFont.labelFontSize)
        font = UIFontMetrics.default.scaledFont(for: customFont!)
        textColor = ColorCompatibility.label
    }

}
