//
//  AmaxBaseViewController.m
//  Astromaximum
//
//  Created by admin on 28.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxSelectionViewController : AmaxBaseViewController {

    var selectedView: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: Selection is lost here!
        if updateDisplay() {
            makeSelected(selectedView)
        }
    }

    @objc func itemTapped(sender: UITapGestureRecognizer) {
        if let tap = sender as? AmaxTapRecognizer {
            //print("itemTapped: \(tap.mEvent.description), type: \(AmaxEvent.EVENT_TYPE_STR[Int(tap.mEventType.rawValue)])")
            if let newView = tap.view {
                if newView == selectedView {
                    showInterpreterFor(event: tap.mEvent, type: tap.mEventType)
                }
                else {
                    makeSelected(newView)
                }
            }
        }
    }

    func makeSelected(_ view: UIView?) {
        if let p = mParent {
            if view == nil || view!.window == nil {
                p.mSelectedViewTime.text = mDataProvider?.locationName()
            }
            if selectedView != view {
                selectedView?.layer.borderColor = dimmedColor
                selectedView?.layer.borderWidth = 1
                selectedView = view
                selectedView?.layer.borderColor = ColorCompatibility.label.cgColor
                selectedView?.layer.borderWidth = 3
            }
            if let grArray = selectedView?.gestureRecognizers {
                for gr in grArray {
                    if let tap = gr as? AmaxTapRecognizer {
                        p.mSelectedViewTime.text = makeSelectedDateString(tap.mEvent)
                        break
                    }
                }
            }
        }
    }

    func makeSelectedDateString(_ e: AmaxEvent) -> String {
        if e.date(at: 0) == e.date(at: 1) {
            return AmaxEvent.long2String(e.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false)
        }
        return String(format:"%@ - %@",
                AmaxEvent.long2String(e.date(at: 0), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: false),
                AmaxEvent.long2String(e.date(at: 1), format: AmaxEvent.monthAbbrDayDateFormatter(), h24: true))
    }

    @objc func itemLongPressed(sender: UILongPressGestureRecognizer) {
        if let longPress = sender as? AmaxLongPressRecognizer {
            if longPress.state == .began {
                showEventListFor(si: longPress.mSummaryItem, xib: longPress.mXibName)
            }
        }
    }
    
    func addLongPressRecognizer(view: UIView, summaryItem: AmaxSummaryItem, xib: String) {
        let longPress = AmaxLongPressRecognizer(target: self, action: #selector(itemLongPressed), summaryItem: summaryItem, xib: xib)
        view.gestureRecognizers = [longPress]
    }

}
