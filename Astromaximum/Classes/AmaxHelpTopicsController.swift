//
//  AmaxEventListViewController.m
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxHelpTopicsController : AmaxBaseViewController, UITableViewDelegate, UITableViewDataSource {
    let cellNibName = "HelpTopicCell"
    @IBOutlet weak var tvCell: UITableViewCell!

    let mTopics: [String] = [
        "help_planets",
        "help_zodiac",
        "help_aspects",
        "help_moon_events",
        "help_misc"
    ]

    let mAspects: [Int] = [
        0,    // Conjunction
        180,  // Opposition
        90,   // Square
        120,  // Trine
        60,   // Sextile
    ]
    
    let mMoonEvents: [String] = [
        "si_key_voc",
        "si_key_vc",
        "si_key_moon_move",
        "help_moon_new",
        "help_moon_1q",
        "help_moon_full",
        "help_moon_3q"
    ]
    
    let mMisc: [String] = [
        "si_key_tithi",
        "help_misc_sd",
        "help_misc_md",
        "si_retrograde",
        "help_misc_eclipse_sun",
        "help_misc_eclipse_moon",
        "help_misc_decumbiture"
    ]
    
    @IBOutlet weak var mTableView: UITableView!
    
    init(nibName: String, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        title = NSLocalizedString("help_title", comment: "Help")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    // Customize the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return mTopics.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:  // "help_planets"
            return Int(SE_PLUTO.rawValue - SE_SUN.rawValue + 1)
        case 1:  // "help_zodiac"
            return 12
        case 2:  // "help_aspects"
            return mAspects.count
        case 3:  // "help_moon_events"
            return mMoonEvents.count
        case 4:  // "help_misc"
            return mMisc.count
        default:
            break
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(mTopics[section], comment: "")
    }

    // Customize the appearance of table view cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellNibName)
        if cell == nil {
            Bundle.main.loadNibNamed(cellNibName, owner: self, options: nil)
            cell = tvCell
            tvCell = nil
        }
        guard let c = cell else {
            return cell!
        }
        var insignia = ""
        var topic = ""
        switch indexPath.section {
        case 0:  // "help_planets"
            insignia = String(format: "%c", getSymbol(TYPE_PLANET, Int32(indexPath.row)))
            topic = NSLocalizedString("\(indexPath.row)", tableName: "Planets", comment: "")
        case 1:  // "help_zodiac"
            insignia = String(format: "%c", getSymbol(TYPE_ZODIAC, Int32(indexPath.row)))
            topic = NSLocalizedString("\(indexPath.row)", tableName: "ConstellNominative", comment: "")
        case 2:  // "help_aspects"
            insignia = String(format: "%c", getSymbol(TYPE_ASPECT, Int32(mAspects[indexPath.row])))
            topic = NSLocalizedString("\(mAspects[indexPath.row])", tableName: "Aspects", comment: "")
        case 3:  // "help_moon_events"
            topic = NSLocalizedString("\(mMoonEvents[indexPath.row])", comment: "")
        case 4:  // "help_misc"
            topic = NSLocalizedString("\(mMisc[indexPath.row])", comment: "")
        default:
            break
        }
        let sign = c.viewWithTag(1) as! UILabel
        sign.text = insignia
        //sign.isHidden = insignia.isEmpty
        (c.viewWithTag(2) as! UILabel).text = topic
        return c
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let e = AmaxEvent()
        e.mEvtype = EV_HELP0
        switch indexPath.section {
        case 0:  // "help_planets"
            e.mDegree = [10, 11, 12, 13, 14, 15, 16, 20, 21, 22][indexPath.row]
        case 1:  // "help_zodiac"
            e.mDegree = [30, 31, 32, 33, 34, 35, 40, 41, 42, 43, 44, 45][indexPath.row]
        case 2:  // "help_aspects"
            e.mEvtype = EV_HELP1
            e.mDegree = [70, 71, 72, 73, 74][indexPath.row]
         case 3:  // "help_moon_events"
            e.mEvtype = EV_HELP1
            e.mDegree = [60, 65, 77, 61, 62, 63, 64][indexPath.row]
        case 4:  // "help_misc"
            e.mEvtype = EV_HELP1
            e.mDegree = [80, 81, 82, 75, 83, 84, 96][indexPath.row]
        default:
            return
        }
        //print("indexPath: \(indexPath.section), \(indexPath.row), \(e.mDegree)")
        showInterpreterFor(event: e, type: e.mEvtype, title: NSLocalizedString(mTopics[indexPath.section], comment: ""))
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //mTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
