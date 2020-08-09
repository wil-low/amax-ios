//
//  AmaxTimezoneTransition.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 12.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

@objcMembers class AmaxTimezoneTransition : NSObject {
    var time:Date
    var offset:TimeInterval
    var name:String
    
    init(time:Date, offset:TimeInterval, name:String) {
        self.time = time
        self.offset = offset
        self.name = name
    }
}
