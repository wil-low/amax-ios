//
//  AmaxLocationListController.m
//  
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

import UIKit

@objcMembers class AmaxLocationListController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var mDataProvider:AmaxDataProvider!
    private var workingLocationIndex = -1
    private var selectedLocationIndex = -1
    @IBOutlet weak var tableView1: UITableView!

    override init(nibName: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibName, bundle:nibBundleOrNil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didSelectLocation(sender:)))
        title = NSLocalizedString("Current location", comment: "Current location")
        mDataProvider = AmaxDataProvider.sharedInstance
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()

        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        workingLocationIndex = 0
        for i in 0 ..< mDataProvider.mSortedLocationKeys.count {
            if (mDataProvider.mLocationId == mDataProvider.mSortedLocationKeys[i]) {
                workingLocationIndex = i
                break
            }
         }
        let path = IndexPath(row: workingLocationIndex, section: 0)
        tableView(tableView1, didSelectRowAt: path)
        tableView1.scrollToRow(at: path, at: .middle, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func viewDidDisappear(_ animated:Bool) {
        let path = IndexPath(row: workingLocationIndex, section: 0)
        tableView(tableView1, didSelectRowAt: path)
        selectedLocationIndex = -1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataProvider.mSortedLocationKeys.count
    }

    // Customize the appearance of table view cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"

        var cell = tableView1.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
        }

        cell?.textLabel?.text = mDataProvider.mLocations[mDataProvider.mSortedLocationKeys[indexPath.row]]

        let key = mDataProvider.mSortedLocationKeys[indexPath.row]
        cell?.detailTextLabel?.text = key

        cell?.accessoryType = selectedLocationIndex == indexPath.row ? .checkmark : .none

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView1.deselectRow(at: indexPath, animated: false)

        if selectedLocationIndex == indexPath.row {
            return
        }

        let newCell = tableView1.cellForRow(at: indexPath)
        newCell?.accessoryType = .checkmark

        let oldIndexPath = IndexPath(row: selectedLocationIndex, section:0)
        if let oldCell = tableView1.cellForRow(at: oldIndexPath) {
            oldCell.accessoryType = .none
        }
        //NSLog(@"didSelect new %d, old %d, selected %d, working %d", [indexPath indexAtPosition:1], [oldIndexPath indexAtPosition:1], selectedLocationIndex, workingLocationIndex);

        selectedLocationIndex = indexPath.row
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedLocationIndex != workingLocationIndex
    }

    @IBAction func didSelectLocation(sender:AnyObject!) {
        workingLocationIndex = selectedLocationIndex
        mDataProvider.loadLocationById(locationId:  mDataProvider.mSortedLocationKeys[workingLocationIndex])
        navigationController?.popViewController(animated: true)
    }
}
