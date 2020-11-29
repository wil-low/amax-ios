//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

class MoonPhaseView: UIView {
    
    var phase: Float = 0
    var whiteBorder = false

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        draw(inContext: context)
    }

    func draw(inContext context: CGContext) {
        let radius = min(bounds.width, bounds.height) / 2 - 5
        var sweep: [Bool]
        var mag: Float
        // the "sweep-flag" and the direction of movement change every quarter moon
        // zero and one are both new moon; 0.50 is full moon
        if phase <= 0.25 {
            sweep = [ true, false ]
        }
        else if phase <= 0.50 {
            sweep = [ false, false ]
        }
        else if phase <= 0.75 {
            sweep = [ true, true ]
        }
        else if phase <= 1 {
            sweep = [ false, true ]
        }
        else {
            return
        }
        mag = abs(cos(phase * Float.pi * 2))

        let lineWidth: CGFloat = 2

        let cpoint = CGPoint(x: bounds.minX + bounds.width / 2, y: bounds.minY + bounds.height / 2)

        context.addEllipse(in: CGRect(x: cpoint.x - radius - lineWidth, y: cpoint.y - radius - lineWidth, width: (radius + lineWidth) * 2, height: (radius + lineWidth) * 2))
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()

        context.setStrokeColor(UIColor.white.cgColor)
        if phase == 0 && whiteBorder {
            context.addEllipse(in: CGRect(x: cpoint.x - radius - lineWidth, y: cpoint.y - radius - lineWidth, width: (radius + lineWidth) * 2, height: (radius + lineWidth) * 2))
            context.strokePath()
        }

        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: cpoint.y), radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 3 / 2, clockwise: sweep[0], transform: CGAffineTransform.identity.scaledBy(x: CGFloat(mag), y: 1).translatedBy(x: cpoint.x / CGFloat(mag), y: 0))
        //print("cur_point: \(path.currentPoint.x), middle: \(cpoint.x), mag \(mag), radius \(radius)")
        path.addArc(center: cpoint, radius: radius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi / 2, clockwise: sweep[1])
        //print("cur_point2: \(path.currentPoint.x)")
        path.closeSubpath()

        context.addPath(path)
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}
