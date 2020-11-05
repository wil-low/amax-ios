//
//  AmaxInterpreterController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxInterpreterController : UIViewController {

    private var _interpreterText: String = ""
    var interpreterText: String {
        get { return _interpreterText }
        set { _interpreterText = newValue }
    }
    private var _interpreterEvent: AmaxEvent?
    var interpreterEvent: AmaxEvent {
        get { return _interpreterEvent! }
        set { _interpreterEvent = newValue }
    }
    private var _eventType: AmaxEventType?
    var eventType: AmaxEventType {
        get { return _eventType! }
        set { _eventType = newValue }
    }
    @IBOutlet weak var interpreterTextView: UIWebView!
    @IBOutlet weak var eventDescriptionView: UILabel!
    @IBOutlet weak var dateRangeView: UILabel!

    override init(nibName: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibName, bundle:nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    func makeTitleFrom(event ev: AmaxEvent!, type: AmaxEventType) -> String! {
        switch (type) {
    		case EV_VOC:
                return NSLocalizedString("si_key_voc", comment: "")

            case EV_VIA_COMBUSTA:
                return NSLocalizedString("si_key_vc", comment: "")
    		
            case EV_DEGREE_PASS:
                let planet = NSLocalizedString("\(Int(ev.mPlanet0.rawValue))", tableName: "Planets", comment: "")
                let constell = NSLocalizedString("\(ev.getDegree() / 30)", tableName: "ConstellGenitive", comment: "")
                return String(format:NSLocalizedString("fmt_planet_in_degree", comment: ""),
                        planet,
                        ev.getDegree() % 30 + 1,
                        constell) 
    		
            case EV_SIGN_ENTER:
                let planet = NSLocalizedString("\(Int(ev.mPlanet0.rawValue))", tableName: "Planets", comment: "")
                let constell = NSLocalizedString("\(ev.getDegree())", tableName: "ConstellLocative", comment: "")
                return String(format:NSLocalizedString("fmt_planet_in_sign", comment: ""),
                        planet,
                        constell) 

    		case EV_PLANET_HOUR:
                let planet = NSLocalizedString("\(Int(ev.mPlanet0.rawValue))", tableName: "PlanetsGenitive", comment: "")
                return String(format:NSLocalizedString("fmt_hour_of_planet", comment: ""),
                        planet) 

    		case EV_MOON_MOVE:
                return NSLocalizedString("si_key_moon_move", comment: "")

    		case EV_ASP_EXACT_MOON,
    		     EV_ASP_EXACT:
                let planet0 = NSLocalizedString("\(Int(ev.mPlanet0.rawValue))", tableName: "Planets", comment: "")
                let planet1 = NSLocalizedString("\(Int(ev.mPlanet1.rawValue))", tableName: "Planets", comment: "")
                let aspect = NSLocalizedString("\(ev.getDegree())", tableName: "Aspects", comment: "")
    			return String(format:NSLocalizedString("fmt_aspect", comment: ""),
                        aspect,
                        planet0,
                        planet1) 

    		case EV_TITHI:
                let result = NSLocalizedString("si_key_tithi", comment: "")
     			return String(format:"%@ %d", result, ev.getDegree()) 

    		case EV_RETROGRADE:
                let planet0 = NSLocalizedString("\(Int(ev.mPlanet0.rawValue))", tableName: "Planets", comment: "")
    			return String(format:NSLocalizedString("fmt_retrograde_motion", comment: ""),
                        planet0) 

            case EV_SUN_DAY:
                let result = NSLocalizedString("si_sun_day", comment: "")
                var dgr = ev.getDegree()
                if dgr >= 360 {
                    dgr = -(dgr - 359)
                }
                return String(format:"%@ %d", result, dgr)
            
            case EV_MOON_DAY:
                let result = NSLocalizedString("si_moon_day", comment: "")
                return String(format:"%@ %d", result, ev.getDegree())
            
            default:
                return ev.description
       }
    }

    func makeDateRangeFrom(event:AmaxEvent!) -> String! {
        switch (event.mEvtype) { 
    		case EV_ASP_EXACT_MOON,
    		     EV_ASP_EXACT:
                return AmaxEvent.long2String(event.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
            default:
                break
        }
        return String(format:"%@ - %@",
                      AmaxEvent.long2String(event.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false),
                      AmaxEvent.long2String(event.date(at: 1), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: true))
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("interp_title", comment: "")
        // Do any additional setup after loading the view from its nib.
        interpreterTextView.loadHTMLString("", baseURL: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventDescriptionView.text = makeTitleFrom(event: _interpreterEvent, type: _eventType!)
        dateRangeView.text = makeDateRangeFrom(event: _interpreterEvent)
        interpreterTextView.loadHTMLString(_interpreterText, baseURL: nil)
        //NSLog(@"%@", _interpreterText);
    }
}
