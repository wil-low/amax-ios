//
//  AmaxCommonDataFile.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 12.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

class AmaxCommonDataFile {

    var startYear:Int = 0
    var startMonth:Int = 0
    var startDay:Int = 0
    var dayCount:Int = 0
    var monthCount:Int = 0
    var customData:Data?
    var data:AmaxDataInputStream?

    init(filePath: String) {
        let isLegacy = false;
        guard let fullData = (NSData(contentsOfFile: filePath) as Data?) else {
            print("AmaxCommonDataFile: failed to open \(filePath)")
            return;
        }
        let ais = AmaxDataInputStream(data: fullData)
        startYear = Int(ais.readShort())
        startMonth = Int(ais.readUnsignedByte())
        startDay = Int(ais.readUnsignedByte())

        let customDataLen = Int(ais.readUnsignedShort()) // customData length
        if isLegacy {
            dayCount = Int(ais.readShort())
        }
        else {
            monthCount = Int(ais.readUnsignedByte())
        }
        if customDataLen > 0 {
            customData = ais.read(length: customDataLen)
        }
        let bufferLength = ais.availableBytes()
        data = AmaxDataInputStream(data: ais.read(length: bufferLength))
    }
}
