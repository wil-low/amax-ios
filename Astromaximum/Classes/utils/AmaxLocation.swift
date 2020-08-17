//
//  AmaxLocation.swift
//  Astromaximum2
//
//  Created by Andrei Ivushkin on 14.08.2020.
//  Copyright © 2020 S&W Axis. All rights reserved.
//

struct AmaxLocation {
    var mCityId = ""
    var mCity = ""
    var mState = ""
    var mCountry = ""
    var mCoords: [Int] = [0, 0, 0]
    var mTimezone = ""
    
    let SEP = ";"

    func serialize() -> String {
        var result = "\(mCityId)" + SEP;
        result += "\(mCity)" + SEP
        result += "\(mState)" + SEP
        result += "\(mCountry)" + SEP
        result += "\(mCoords[0])" + SEP
        result += "\(mCoords[1])" + SEP
        result += "\(mCoords[2])" + SEP
        result += "\(mTimezone)" + SEP
        
        return result
    }
    
    mutating func deserialize(stream: String) {
        let separator = Character(SEP)
        let arr = stream.split(separator: separator, omittingEmptySubsequences: false).map { String($0) }
        mCityId = arr[0]
        mCity = arr[1]
        mState = arr[2]
        mCountry = arr[3]
        mCoords[0] = Int(arr[4]) ?? 0
        mCoords[1] = Int(arr[5]) ?? 0
        mCoords[2] = Int(arr[6]) ?? 0
        mTimezone = arr[7]
    }
}
