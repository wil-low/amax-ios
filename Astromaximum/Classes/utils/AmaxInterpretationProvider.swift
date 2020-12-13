//
//  AmaxInterpretationProvider.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import Foundation

class AmaxInterpretationProvider {

    private var mTexts: AmaxDataInputStream!

    let ASPECT_GOODNESS = [
        0: 0,
        180: 1,
        120: 2,
        90: 1,
        60: 2,
        45: 2
    ]
    
    static let sharedInstance = AmaxInterpretationProvider()

    init() {
        let filePath = Bundle.main.path(forResource: "interpret", ofType: "dat")
        guard let fullData = (NSData(contentsOfFile: filePath!) as Data?) else {
            print("AmaxCommonDataFile: failed to open \(filePath!)")
            return;
        }
        mTexts = AmaxDataInputStream(data: fullData)
    }

    func getTextFor(event ev: AmaxEvent?, type: AmaxEventType) -> String? {
        guard let e = ev else {
            return nil
        }
        let params = makeInterpreterCode(event: e, type: type)
        //NSLog("type: %@ (%d), params: %d, %d, %d, %d", AmaxEvent.EVENT_TYPE_STR[Int(e.mEvtype.rawValue)], Int(e.mEvtype.rawValue), params[0], params[1], params[2], params[3])
        var tempParams = [0, 0, 0, 0]
        mTexts.reset()
        mTexts.skipBytes(4)
        let sectionCount = mTexts.readUnsignedShort()
        var eventCount = 0
        for _ in 0 ..< sectionCount {
            if Int8(params[0]) == mTexts.readByte() {
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
            //NSLog("temp params: %d, %d, %d, %d", tempParams[0], tempParams[1], tempParams[2], tempParams[3])
            var isEqual = true
            for j in 0 ..< 3 {
                if params[j + 1] != tempParams[j] {
                    isEqual = false
                    break
                }
             }
            if isEqual {
                return composeHTML(mTexts.readUTF()!)
            }
            else {
                let len = mTexts.readUnsignedShort()
                mTexts.skipBytes(Int(len))
            }
         }
        return nil
    }

    func makeInterpreterCode(event ev: AmaxEvent, type: AmaxEventType) -> [Int] {
        var evType = type
        var planet = -1
        var param0 = -1, param1 = -1, param2 = -1
        switch (type) { 
            case EV_SUN_DAY:
                evType = EV_NAVROZ
                var dgr = ev.getDegree()
                if dgr >= 360 {
                    dgr += 1
                }
                planet = Int(ev.mPlanet0.rawValue)
                param0 = dgr
                break
            case EV_MOON_DAY:
                planet = Int(ev.mPlanet0.rawValue)
                param0 = ev.getDegree()
                break
            case EV_MOON_PHASE:
                planet = Int(ev.mPlanet0.rawValue)
                param0 = Int(ev.mPlanet1.rawValue)
                break
            case EV_ECLIPSE:
                param0 = 0
                break
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
    			}
                else {
                    if ev.mPlanet0 == SE_UNDEFINED {
                        param0 = Int(SE_MOON.rawValue)
                    }
                    else {
                        param0 = Int(ev.mPlanet0.rawValue)
                    }
                    param1 = Int(ev.mPlanet1.rawValue)
    			}
                break
            case EV_HELP0, EV_HELP1:
                param0 = ev.getDegree()
                break
            case EV_RISE:
                param0 = Int(ev.mPlanet0.rawValue)
                param1 = ev.getDegree()
                break
            default:
                break
        }
        return [Int(evType.rawValue), planet, param0, param1, param2]
    }

    func composeHTML(_ text: String) -> String {
        let html = """
        <html>
        <head>
        <style type="text/css">
        :root {
          color-scheme: light dark;
          --subhead-color: green;
          --link-color: blue;
        }

        @media screen and (prefers-color-scheme: dark) {
          :root {
            --subhead-color: #80ff80;
            --link-color: #93d5ff;
          }
        }

        body {
            font: -apple-system-body;
        }

        h1 {
            font: -apple-system-headline;
            color: var(--title-color);
            text-align: center;
        }

        h2 {
            font: -apple-system-subheadline;
            color: var(--subhead-color);
        }

        footer {
            font: -apple-system-footnote;
        }

        a {
            color: var(--link-color);
        }

        img {
            max-width: 100%;
        }
        </style>
        </head>
        <body>
        \(text)
        </body>
        </html>
        """
        return html
    }
}
