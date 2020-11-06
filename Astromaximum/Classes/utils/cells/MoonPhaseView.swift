//
//  MoonPhaseView.swift
//  Astromaximum
//
//  Created by Andrei Ivushkin on 05.11.2020.
//

import UIKit

class MoonPhaseView: UIView {
    
    var phase: Float = 0

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        draw(inContext: context)
    }

    func draw(inContext context: CGContext) {
        let radius = min(bounds.width, bounds.height) / 2

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

        //print("Phase: \(phase), sweep: \(sweep[0]) \(sweep[1]), mag \(mag)")
        context.setLineWidth(3)
        context.setStrokeColor(UIColor.white.cgColor)

        let tx: Float = Float(radius) * (1 - mag)
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 3 / 2, clockwise: sweep[0], transform: CGAffineTransform.identity.translatedBy(x: CGFloat(tx), y: 0).scaledBy(x: CGFloat(mag), y: 1))
        path.addArc(center: center, radius: radius, startAngle: CGFloat.pi * 3 / 2, endAngle: CGFloat.pi / 2, clockwise: sweep[1])
        path.closeSubpath()

        context.addPath(path)
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}
