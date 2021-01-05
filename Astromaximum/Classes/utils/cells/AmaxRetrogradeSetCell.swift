//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxRetrogradeSetCell : AmaxTableCell {
    @IBOutlet weak  var tvCell: AmaxTableCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //stackView = (UIStackView *)[self viewWithTag:4];
        //stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //stackView.translatesAutoresizingMaskIntoConstraints = false;
    }

    override func configure(_ extRangeMode: Bool, _ summaryMode: Bool) {
        super.configure(extRangeMode, summaryMode)

        if let si = summaryItem {
            for view in contentView.subviews {
                if view.tag != 1 {
                    view.removeFromSuperview()
                }
            }

            let isEmpty = si.mEvents.count == 0
            eventLabel?.isHidden = !isEmpty

            if isEmpty {
                return
            }

            var events = [UIView]()

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:)))
            tap.numberOfTapsRequired = 1
            addGestureRecognizer(tap)

            for e in si.mEvents {
                let cell = RetrogradeView()
                cell.mPlanet.text = String(format: "%c", getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
                //cell.layer.borderWidth = 0.8
                //cell.layer.borderColor = UIColor.gray.cgColor
                events.append(cell)
            }

            let spacerButton = UIView()
            spacerButton.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
            spacerButton.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
            //spacerButton.layer.borderWidth = 0.8
            //spacerButton.layer.borderColor = UIColor.red.cgColor
            events.append(spacerButton)

            let stackedInfoView:UIStackView! = UIStackView(arrangedSubviews: events)

            stackedInfoView.axis = .horizontal
            //stackedInfoView.distribution = .fillEqually//EqualSpacing;
            //stackedInfoView.alignment = .fill
            stackedInfoView.spacing = 0;
            stackedInfoView.translatesAutoresizingMaskIntoConstraints = false

            self.contentView.addSubview(stackedInfoView)

            stackedInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            stackedInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            stackedInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
            stackedInfoView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor).isActive = true
        }
    }

    @objc func itemTapped(sender: UIButton!) {
        if let si = summaryItem {
            var responder: UIResponder = self
            while responder is UIView {
                responder = responder.next!
            }
            let controller = responder as! AmaxSummaryViewController
            controller.showEventListFor(si: si, xib: "RetrogradeCell")
            //NSLog("Ok button was tapped: dismiss the view controller.")
        }
    }
}
