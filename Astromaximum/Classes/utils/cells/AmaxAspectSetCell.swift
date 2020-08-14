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
        var aspects = [UIButton]()
        for e in si.mEvents {
            //UIView* view = [[NSBundle mainBundle] loadNibNamed:@"AspectCell" owner:self options:nil].firstObject;
            //UILabel* aspect = (UILabel*)[view viewWithTag:3];
            let aspect = UIButton(type: .system)
            aspect.setTitle(String(format: "%c %c %c",
                                   getSymbol(TYPE_PLANET, e.mPlanet0.rawValue),
                                   getSymbol(TYPE_ASPECT, Int32(e.mDegree)),
                                   getSymbol(TYPE_PLANET, e.mPlanet1.rawValue)),
                            for: .normal)
            aspect.titleLabel?.font = UIFont(name: "Astronom", size: (aspect.titleLabel?.font.pointSize)!)
            aspect.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
            aspect.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

            aspect.addTarget(self, action: #selector(self.aspectTapped(sender:)), for: .touchUpInside)

            aspects.append(aspect)
         }
        for view in contentView.subviews {
            view.removeFromSuperview()
         }

        let stackedInfoView:UIStackView! = UIStackView(arrangedSubviews:aspects)

        stackedInfoView.axis = .horizontal
        stackedInfoView.distribution = .fillEqually//EqualSpacing;
        stackedInfoView.alignment = .fill
        //stackedInfoView.spacing = 5;
        stackedInfoView.translatesAutoresizingMaskIntoConstraints = false

        // To Make Our Buttons aligned to left We have added one spacer view
        let spacerButton:UIButton! = UIButton()
        spacerButton.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacerButton.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        stackedInfoView.addArrangedSubview(spacerButton)

        self.contentView.addSubview(stackedInfoView)

        stackedInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackedInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackedInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackedInfoView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor).isActive = true
        //[stackedInfoView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = true;

        self.updateInfoButtonWith(si)
    }

    func aspectTapped(sender:UIButton!) {
        var responder: UIResponder = self
        while responder is UIView {
            responder = responder.next!
        }
        let controller = responder as! AmaxSummaryViewController
        controller.showEventListFor(si: summaryItem, xib: "AspectCell")
        NSLog("Ok button was tapped: dismiss the view controller.")
    }
}
