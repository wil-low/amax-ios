//
//  AmaxLocationDataFile.m
//  Astromaximum
//
//  Created by admin on 14.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

@objcMembers class AmaxLocationDataFile : NSObject {
    private var coords: [Int] = [0, 0, 0]
    private var customData: String?
    private var transitions: [AmaxTimezoneTransition]?

    private var _mStartYear:Int
    var mStartYear:Int {
        get { return _mStartYear }
    }
    private var _mStartMonth:Int
    var mStartMonth:Int {
        get { return _mStartMonth }
    }
    private var _mStartDay:Int
    var mStartDay:Int {
        get { return _mStartDay }
    }
    private var _mDayCount:Int = 0
    var mDayCount:Int {
        get { return _mDayCount }
    }
    private var _mMonthCount:Int = 0
    var mMonthCount:Int {
        get { return _mMonthCount }
    }
    private var _mCityId:Int
    var mCityId:Int {
        get { return _mCityId }
    }
    private var _mCity:String!
    var mCity:String! {
        get { return _mCity }
    }
    private var _mState:String!
    var mState:String! {
        get { return _mState }
    }
    private var _mCountry:String!
    var mCountry:String! {
        get { return _mCountry }
    }
    private var _mTimezone:String!
    var mTimezone:String! {
        get { return _mTimezone }
    }
    private var _mData:AmaxDataInputStream!
    var mData:AmaxDataInputStream! {
        get { return _mData }
    }

    init(data: Data, headerOnly:Bool) {
        let dis = AmaxDataInputStream(data:data)
        dis.skipBytes(4) // signature
        let version = dis.readUnsignedByte()
        _mStartYear = Int(dis.readShort())
        _mStartMonth = Int(dis.readUnsignedByte() - 1)
        _mStartDay = Int(dis.readUnsignedByte())
        if version == 3 {
            _mMonthCount = Int(dis.readUnsignedByte())
            _mDayCount = 365
        }
        else if version == 2 {
            _mDayCount = Int(dis.readShort())
            _mMonthCount = 12
        }
        else {
            NSLog("Unknown version %d", version)
        }
        _mCityId = dis.readInt() // city id
        coords[0] = Int(dis.readShort()) // latitude
        coords[1] = Int(dis.readShort()) // longitude
        coords[2] = Int(dis.readShort()) // altitude
        _mCity = dis.readUTF() // city
        _mState = dis.readUTF() // state
        _mCountry = dis.readUTF() // country
        _mTimezone = dis.readUTF() // timezone
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
            _mData = AmaxDataInputStream(data:data)
        }
    }
}
