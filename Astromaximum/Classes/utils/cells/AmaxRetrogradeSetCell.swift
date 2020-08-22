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

    override func configure(_ si: AmaxSummaryItem) {
        super.configure(si)
        if si.mEvents.count == 0 {
            return
        }

        var events = [UIView]()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:)))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)

        for e in si.mEvents {
            //let cell = AmaxRetrogradeCell()
            let cell = Bundle.main.loadNibNamed("RetrogradeCell", owner: self, options: nil)![0] as! UIView
            if let dummy = cell.viewWithTag(3) {
                let planet = dummy.viewWithTag(1) as! UILabel
                planet.text = String(format: "%c", getSymbol(TYPE_PLANET, e.mPlanet0.rawValue))
                planet.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE))
                //dummy.layer.borderWidth = 0.8
                //dummy.layer.borderColor = UIColor.gray.cgColor
                //dummy.sizeToFit()
                events.append(dummy)
            }
        }

        let spacerButton = UIButton()
        spacerButton.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacerButton.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        //spacerButton.layer.borderWidth = 0.8
        //spacerButton.layer.borderColor = UIColor.red.cgColor
        events.append(spacerButton)

        for view in contentView.subviews {
            view.removeFromSuperview()
        }

        let stackedInfoView:UIStackView! = UIStackView(arrangedSubviews: events)

        stackedInfoView.axis = .horizontal
        //stackedInfoView.distribution = .fillEqually//EqualSpacing;
        //stackedInfoView.alignment = .fill
        stackedInfoView.spacing = 0;
        stackedInfoView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(stackedInfoView)

        stackedInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackedInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackedInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        stackedInfoView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor).isActive = true
        //[stackedInfoView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = true;

        self.updateInfoButtonWith(si)
    }

    @objc func itemTapped(sender:UIButton!) {
        var responder: UIResponder = self
        while responder is UIView {
            responder = responder.next!
        }
        let controller = responder as! AmaxSummaryViewController
        controller.showEventListFor(si: summaryItem, xib: "RetrogradeCell")
        NSLog("Ok button was tapped: dismiss the view controller.")
    }
}
