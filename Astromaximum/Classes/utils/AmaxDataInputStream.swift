//
//  AmaxDataInputStream.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 12.07.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

import Foundation

class AmaxDataInputStream {

    var position: Int = 0
    var dataLength: Int = 0
    var data: Data

    init(bytes: UnsafeRawPointer, length: Int) {
        dataLength = length
        data = Data.init(bytes: bytes, count: length)
    }

    init(data rawData: Data) {
        dataLength = rawData.count
        data = rawData
    }

    func reset() {
        position = 0
    }

    func skipBytes(_ byteCount: Int) {
        position += byteCount
    }

    func reachedEOF() -> Bool {
        return position >= dataLength
    }

    func readShort() -> Int16 {
        var res = Int16(data[position])
        position += 1
        res <<= 8
        res += Int16(data[position])
        position += 1
        return res
    }

    func readUnsignedByte() -> UInt8 {
        let result = UInt8(data[position])
        position += 1
        return result
    }

    func readByte() -> Int8 {
        let result = Int8(bitPattern: data[position])
        position += 1
        return result
    }

    func readUnsignedShort() -> UInt16 {
        let n0 = UInt16(data[position])
        position += 1
        let n1 = UInt16(data[position])
        position += 1
        return UInt16((n0 << 8) + n1)
    }

    func readInt() -> Int {
        var res = Int(data[position])
        position += 1
        res <<= 8
        res += Int(data[position])
        position += 1
        res <<= 8
        res += Int(data[position])
        position += 1
        res <<= 8
        res += Int(data[position])
        position += 1
        return Int(res)
    }

    func availableBytes() -> Int {
        return dataLength - position
    }

    func read(length byteCount: Int) -> Data {
        let range = position ..< (position + byteCount)
        let buffer = data.subdata(in: range)
        position += byteCount
        return buffer
    }

    func readUTF() -> String? {
        let stringLength = Int(readUnsignedShort())
        let range = position ..< (position + stringLength)
        let buffer = data.subdata(in: range)
        let s = String.init(data: buffer, encoding: .utf8)
        position += stringLength
        return s
    }
}
