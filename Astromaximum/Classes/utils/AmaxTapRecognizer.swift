//
//  AmaxMasterViewController.m
//  Astromaximum
//
//  Created by admin on 05.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxTapRecognizer : UITapGestureRecognizer {
    var mEvent: AmaxEvent!
    var mEventType: AmaxEventType!
    
    init(target: Any?, action: Selector?, event: AmaxEvent, eventType: AmaxEventType) {
        super.init(target: target, action: action)
        numberOfTapsRequired = 1
        mEvent = event
        mEventType = eventType
    }
}
