//
//  AmaxAstroLabel.m
//  Astromaximum
//
//  Created by admin on 04.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxAstroLabel.h"

@objcMembers class AmaxAstroLabel : UILabel {
    /*override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont(name: "Astronom", size: font.pointSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/

    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: "Astronom", size: font.pointSize)
    }

}
