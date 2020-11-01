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
        font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE) /*font.pointSize*/)
        textColor = ColorCompatibility.label
    }

}
