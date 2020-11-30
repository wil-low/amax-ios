//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxLongPressRecognizer : UILongPressGestureRecognizer {
    var mSummaryItem: AmaxSummaryItem!
    var mXibName: String!
    
    init(target: Any?, action: Selector?, summaryItem: AmaxSummaryItem, xib xibName: String) {
        super.init(target: target, action: action)
        mSummaryItem = summaryItem
        mXibName = xibName
    }
}
