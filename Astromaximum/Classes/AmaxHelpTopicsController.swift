//
//  AmaxEventListViewController.m
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxHelpTopicsController : AmaxBaseViewController {

    let mTopics: [String] = [
        "help_planets",
        "help_zodiac",
        "help_aspects",
        "help_moon_events",
        "help_topics",
        "help_misc"
    ]

    let mAspects: [Int] = [
        0,    // Conjunction
        180,  // Opposition
        90,   // Square
        120,  // Trine
        60,   // Sextile
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
        return 3 //mTopics.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:  // "help_planets"
            return Int(SE_PLUTO.rawValue - SE_SUN.rawValue + 1)
        case 1:  // "help_zodiac"
            return 12
        case 2:  // "help_aspects"
            return mAspects.count
/*        case 3:  // "help_moon_events"
            break
        case 4:  // "help_topics"
            break
        case 5:  // "help_misc"
            break*/
        default:
            break
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(mTopics[section], comment: "")
    }

    // Customize the appearance of table view cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = ""
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .disclosureIndicator
        }
        guard let c = cell else {
            return cell!
        }
        var txt = ""
        switch indexPath.section {
        case 0:  // "help_planets"
            txt = NSLocalizedString("\(indexPath.row)", tableName: "Planets", comment: "")
        case 1:  // "help_zodiac"
            txt = NSLocalizedString("\(indexPath.row)", tableName: "ConstellNominative", comment: "")
        case 2:  // "help_aspects"
            txt = NSLocalizedString("\(mAspects[indexPath.row])", tableName: "Aspects", comment: "")
        case 3:  // "help_moon_events"
            break
        case 4:  // "help_topics"
            break
        case 5:  // "help_misc"
            break
        default:
            txt = NSLocalizedString("Current_location", comment: "Current location")
        }
        c.textLabel?.text = txt
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
            break
        case 4:  // "help_topics"
            break
        case 5:  // "help_misc"
            break
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
