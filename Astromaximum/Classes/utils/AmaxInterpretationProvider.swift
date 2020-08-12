//
//  AmaxInterpretationProvider.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

//#import "AmaxInterpretationProvider.h"
//#import "Astromaximum-Swift.h"

@objcMembers class AmaxInterpretationProvider : NSObject {

    private var mTexts:AmaxDataInputStream!

    let ASPECT_GOODNESS = [
        0: 0,
        180: 1,
        120: 2,
        90: 1,
        60: 2,
        45: 2
    ]
    
    static let sharedInstance = AmaxInterpretationProvider()

    override init() {
        let filePath = Bundle.main.path(forResource: "interpret", ofType: "dat")
        guard let fullData = (NSData(contentsOfFile: filePath!) as Data?) else {
            print("AmaxCommonDataFile: failed to open \(filePath!)")
            return;
        }
        mTexts = AmaxDataInputStream(data: fullData)
    }

    func getTextFor(event ev: AmaxEvent?) -> String? {
        guard let e = ev else {
            return nil
        }
        let params = makeInterpreterCode(event: e)
        //NSLog("type: %s (%d), params: %d, %d, %d, %d", EVENT_TYPE_STR[Int(e.mEvtype.rawValue)], Int(e.mEvtype.rawValue),
        //      params[0], params[1], params[2], params[3])
        var tempParams = [0, 0, 0, 0]
        mTexts.reset()
        mTexts.skipBytes(4)
        let sectionCount = mTexts.readUnsignedShort()
        var eventCount = 0
        for _ in 0 ..< sectionCount {
            if Int8(e.mEvtype.rawValue) == mTexts.readByte() {
                let offset = mTexts.readInt()
                eventCount = Int(mTexts.readUnsignedShort())
                mTexts.reset()
                mTexts.skipBytes(offset)
                break
            }
            else {
                mTexts.skipBytes(6)
            }
         }
        for _ in 0 ..< eventCount {
            tempParams[0] = Int(mTexts.readByte())
            for j in 0 ..< 3 {
                tempParams[j + 1] = Int(mTexts.readShort())
            }
            var isEqual = true
            for j in 0 ..< 3 {
                if params[j] != tempParams[j] {
                    isEqual = false
                    break
                }
             }
            if isEqual {
                return String(format:"%@%@%@", "<html><head><style type=\"text/css\">body{font-family: '-apple-system','HelveticaNeue';font-size:17;}</style></head><body>", mTexts.readUTF()!, "</body></html")
            }
            else {
                let len = mTexts.readUnsignedShort()
                mTexts.skipBytes(Int(len))
            }
         }
        return nil
    }

    func makeInterpreterCode(event ev: AmaxEvent) -> [Int] {
        var planet = -1
        var param0 = -1, param1 = -1, param2 = -1
        switch (ev.mEvtype) { 
    		case EV_ASP_EXACT_MOON:
                planet = Int(ev.mPlanet0.rawValue)
                param0 = Int(ev.mPlanet1.rawValue)
                param1 = ASPECT_GOODNESS[ev.getDegree()]!
    			break
    		case EV_ASP_EXACT:
                param0 = Int(ev.mPlanet0.rawValue)
                param1 = Int(ev.mPlanet1.rawValue)
    			param2 = ASPECT_GOODNESS[ev.getDegree()]!
    			break
    		case EV_DEGREE_PASS:
    			param0 = ev.getDegree()
    			break
    		case EV_TITHI,
    		     EV_SIGN_ENTER:
                planet = Int(ev.mPlanet0.rawValue)
    			param0 = ev.getDegree()
    			break
    		case EV_VOC,
    		     EV_VIA_COMBUSTA:
                planet = Int(ev.mPlanet0.rawValue)
    			param0 = 0
    			break
    		case EV_RETROGRADE,
    		     EV_PLANET_HOUR:
                param0 = Int(ev.mPlanet0.rawValue)
    			break
    		case EV_MOON_MOVE:
                planet = Int(SE_MOON.rawValue)
    			if ev.mPlanet1 == SE_UNDEFINED {
    				param0 = 255
                    param1 = Int(SE_MOON.rawValue)
    			} else {
                    if ev.mPlanet0 == SE_UNDEFINED {
                        param0 = Int(SE_MOON.rawValue)
                    }
                    else {
                        param0 = Int(ev.mPlanet0.rawValue)
                    }
                    param1 = Int(ev.mPlanet1.rawValue)
    			}
            default:
                break
        }
        return [planet, param0, param1, param2]
    }
}
