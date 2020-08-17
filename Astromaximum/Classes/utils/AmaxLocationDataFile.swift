//
//  AmaxLocationDataFile.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

class AmaxLocationDataFile {

    private var customData: String?
    private var transitions: [AmaxTimezoneTransition]?

    var mStartYear: Int
    var mStartMonth: Int
    var mStartDay: Int
    var mMonthCount: Int = 0
    var location = AmaxLocation()

    var mData: AmaxDataInputStream?

    init(data: Data, headerOnly: Bool) {
        let dis = AmaxDataInputStream(data:data)
        dis.skipBytes(4) // signature
        let version = dis.readUnsignedByte()
        mStartYear = Int(dis.readShort())
        mStartMonth = Int(dis.readUnsignedByte() - 1)
        mStartDay = Int(dis.readUnsignedByte())
        if version == 3 {
            mMonthCount = Int(dis.readUnsignedByte())
        }
        else if version == 2 {
            mMonthCount = 12
        }
        else {
            NSLog("Unknown version %d", version)
        }

        location.mCityId = String(format: "%X", dis.readInt()) // city id
        location.mCoords[0] = Int(dis.readShort()) // latitude
        location.mCoords[1] = Int(dis.readShort()) // longitude
        location.mCoords[2] = Int(dis.readShort()) // altitude
        location.mCity = dis.readUTF()! // city
        location.mState = dis.readUTF()! // state
        location.mCountry = dis.readUTF()! // country
        location.mTimezone = dis.readUTF()! // timezone

        if headerOnly == false {
            customData = dis.readUTF() // custom data
            let transitionCount = dis.readUnsignedByte()
            transitions = [AmaxTimezoneTransition]()
            for _ in 0 ..< transitionCount {
                let time = Date(timeIntervalSince1970: TimeInterval(dis.readInt())) // start_date
                let offset = TimeInterval(dis.readShort() * 60) // gmt_ofs_min
                let name = dis.readUTF()! // name
                let transition = AmaxTimezoneTransition(time:time, offset:offset, name:name)
                transitions!.append(transition)
             }
            let bufferLength = dis.availableBytes()
            let data = dis.read(length: bufferLength)
            mData = AmaxDataInputStream(data:data)
        }
    }
}
