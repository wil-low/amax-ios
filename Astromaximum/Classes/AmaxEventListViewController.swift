//
//  AmaxEventListViewController.m
//  Astromaximum
//
//  Created by admin on 28.11.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxEventListViewController : AmaxBaseViewController {

    var cellNibName: String = ""
    @IBOutlet weak var mTableView: UITableView!

    var detailItem: AmaxSummaryItem?
    /*var detailItem:AmaxSummaryItem! {
        get { return _detailItem }
        set(newDetailItem) { 
            if _detailItem != newDetailItem {
                _detailItem = newDetailItem

                // Update the view.
                self.configureView()
            }
        }
    }*/
    
    @IBOutlet weak var tvCell: AmaxTableCell?

    // `setDetailItem:` has moved as a setter.

    func configureView() {
        navigationItem.title = NSLocalizedString("event_list_title", comment: "")
    }

    init(nibName: String, bundle nibBundleOrNil: Bundle) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellNibName)
        if cell == nil {
            Bundle.main.loadNibNamed(cellNibName, owner: self, options: nil)
            cell = tvCell
            tvCell = nil
            cell?.accessoryType = .none
        }
        // Configure the cell.
        let event = detailItem!.mEvents[indexPath.row]
        let si = AmaxSummaryItem(key: detailItem!.mKey, events: [event])
        si.mActiveEvent = event
        (cell as! AmaxTableCell).configure(si)
        return cell!
    }

    // Customize the number of sections in the table view.
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = detailItem!.mEvents.count
        return count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let textId = String(format:"%d", detailItem!.mKey.rawValue)
        return NSLocalizedString(textId, tableName: "EventListTitle", comment: "")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let e = detailItem!.mEvents[indexPath.row]
        showInterpreterFor(event: e)
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
