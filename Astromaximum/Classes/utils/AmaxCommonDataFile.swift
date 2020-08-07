//
//  AmaxCommonDataFile.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 12.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

struct AmaxCommonDataFile {
    var startYear:Int = 0
    var startMonth:Int = 0
    var startDay:Int = 0
    var dayCount:Int = 0
    var customData:Data?
    var data:AmaxDataInputStream?

    init(filePath: String) {
        /*guard let fullData = (NSData(contentsOfFile: filePath) as Data?) else {
            print("AmaxCommonDataFile: failed to open \(filePath)")
            return;
        }
        guard let ais = AmaxDataInputStream(data: fullData) else {
                print("AmaxCommonDataFile creation failed")
                return;
        }
        startYear = Int(ais.readShort())
        startMonth = Int(ais.readUnsignedByte())
        startDay = Int(ais.readUnsignedByte())

        let customDataLen = Int(ais.readUnsignedShort()) // customData length
        dayCount = Int(ais.readShort())
        if customDataLen > 0 {
            customData = Data.init(count: customDataLen)
            ais.read(toBuffer: customData, length: customDataLen)
        }
        let bufferLength = ais.availableBytes()
        var buffer = ais.read(length: bufferLength)
        data = AmaxDataInputStream(bytes: &buffer, length: Int(bufferLength))*/
    }
}
