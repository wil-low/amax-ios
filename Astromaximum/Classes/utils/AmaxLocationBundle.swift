//
//  AmaxLocationBundle.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 12.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

@objcMembers class AmaxLocationBundle : NSObject {
    var recordLengths = [Int]()
    var locStream: AmaxDataInputStream

    init(filePath: String?) {
        let fullData = (NSData(contentsOfFile: filePath ?? "") as Data?)!
        let ais = AmaxDataInputStream(data: fullData)
        _ = ais.readShort() // skip year
        let recordCount = Int(ais.readUnsignedShort())
        for _ in 0..<recordCount {
            recordLengths.append(Int(ais.readUnsignedShort()))
        }
        let bufferLength = ais.availableBytes()
        let buffer = ais.read(length: bufferLength)
        locStream = AmaxDataInputStream(data: buffer)
    }

    func extractLocation(by index: Int) -> Data {
        locStream.reset()
        var offset = 0
        for i in 0 ..< index {
            offset += recordLengths[i]
        }
        let length = recordLengths[index]
        locStream.skipBytes(offset)
        let data = locStream.read(length: length)
        return data
    }
}
