//
//  AmaxMoonSignCell.m
//  Astromaximum
//
//  Created by admin on 05.12.12.
//  Copyright (c) 2012 S&W Axis. All rights reserved.
//

import UIKit

class AmaxAspectSetCell : AmaxTableCell {

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

        var aspects = [UIView]()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:)))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)

        for e in si.mEvents {
            //UIView* view = [[NSBundle mainBundle] loadNibNamed:@"AspectCell" owner:self options:nil].firstObject;
            //UILabel* aspect = (UILabel*)[view viewWithTag:3];
            let aspect = UILabel()
            //aspect.layer.borderWidth = 0.8
            //aspect.layer.borderColor = UIColor.gray.cgColor
            aspect.text = String(format: "%c %c %c",
                                   getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                   getSymbol(TYPE_ASPECT, Int32(e.mDegree)),
                                   getSymbol(TYPE_PLANET, e.mPlanet1.rawValue))
            aspect.font = UIFont(name: "Astronom", size: CGFloat(AmaxLABEL_FONT_SIZE) /*(aspect.titleLabel?.font.pointSize)!*/)
            //aspect.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
            //aspect.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
            aspect.sizeToFit()

            //aspect.addGestureRecognizer(tap)  //addTarget(self, action: #selector(self.itemTapped(sender:)), for: .touchUpInside)

            aspects.append(aspect)
        }

        let spacerButton = UIView()
        spacerButton.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacerButton.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        //spacerButton.layer.borderWidth = 0.8
        //spacerButton.layer.borderColor = UIColor.red.cgColor
        aspects.append(spacerButton)

        for view in contentView.subviews {
            view.removeFromSuperview()
        }

        let stackedInfoView:UIStackView! = UIStackView(arrangedSubviews:aspects)

        stackedInfoView.axis = .horizontal
        //stackedInfoView.distribution = .fillEqually//EqualSpacing;
        //stackedInfoView.alignment = .fill
        stackedInfoView.spacing = 20;
        stackedInfoView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(stackedInfoView)

        stackedInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackedInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackedInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        stackedInfoView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor).isActive = true

        self.updateInfoButtonWith(si)
    }

    @objc func itemTapped(sender:UIButton!) {
        //NSLog("AmaxAspectCell tapped")
        var responder: UIResponder = self
        while responder is UIView {
            responder = responder.next!
        }
        let controller = responder as! AmaxSummaryViewController
        controller.showEventListFor(si: summaryItem, xib: "AspectCell")
        //NSLog("Ok button was tapped: dismiss the view controller.")
    }
}
