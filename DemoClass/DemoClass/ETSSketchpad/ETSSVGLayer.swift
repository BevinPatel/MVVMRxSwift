//
//  ETSSVGLayer.swift
//  ETSFormsManager
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit
import SwiftSVG
import CoreGraphics

class ETSSVGLayer : ETSSketchLayer
{
    private static let size = CGSize(width : 200, height : 200)
    
    private lazy var topLeftCorner = CAShapeLayer()
    private lazy var topRightCorner = CAShapeLayer()
    private lazy var bottomLeftCorner = CAShapeLayer()
    private lazy var bottomRightCorner = CAShapeLayer()

    required init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init(contentSize : CGSize, drawable : ETSDrawableSVG, delegate : ETSSketchLayerDelegate)
    {
        let origin = CGPoint(x : (contentSize.width - ETSSVGLayer.size.width) * 0.5, y : (contentSize.height - ETSSVGLayer.size.height) * 0.5)
        super.init(frame : CGRect(origin : origin, size : ETSSVGLayer.size), drawable : drawable, delegate : delegate)
        CALayer(SVGData : drawable.svgData)
        { (layer) in
            if let myCopy = layer.svgLayerCopy
            {
                myCopy.resizeToFit(self.bounds)
                self.layer.addSublayer(myCopy)
            }
        }
        ETSSketchpadView.shared?.setSelected(newLayer : self)
    }
    
    
    override func draw(_ rect : CGRect)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            let topLeftPath = UIBezierPath()
            topLeftPath.lineWidth = 3.0
            topLeftPath.move(to :       CGPoint(x : rect.origin.x + 10, y : rect.origin.y));
            topLeftPath.addLine(to :    CGPoint(x : rect.origin.x, y : rect.origin.y));
            topLeftPath.addLine(to :    CGPoint(x : rect.origin.x, y : rect.origin.y + 10));
            UIColor.darkGray.setStroke()
            topLeftPath.stroke()
            topLeftCorner.path = topLeftPath.cgPath
            topLeftCorner.strokeColor = UIColor.darkGray.cgColor
            topLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topLeftCorner)
            
            let topRightPath = UIBezierPath()
            topRightPath.lineWidth = 3.0
            topRightPath.move(to :      CGPoint(x : rect.size.width-10, y : rect.origin.y));
            topRightPath.addLine(to :   CGPoint(x : rect.size.width, y : rect.origin.y));
            topRightPath.addLine(to :   CGPoint(x : rect.size.width, y : rect.origin.y + 10));
            UIColor.darkGray.setStroke()
            topRightPath.stroke()
            topRightCorner.path = topRightPath.cgPath
            topRightCorner.strokeColor = UIColor.darkGray.cgColor
            topRightCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topRightCorner)
            
            let bottomLeftPath = UIBezierPath()
            bottomLeftPath.lineWidth = 3.0
            bottomLeftPath.move(to :    CGPoint(x : rect.origin.x + 10,   y : rect.size.height));
            bottomLeftPath.addLine(to : CGPoint(x : rect.origin.x,      y : rect.size.height));
            bottomLeftPath.addLine(to : CGPoint(x : rect.origin.x,      y : rect.size.height-10));
            UIColor.darkGray.setStroke()
            bottomLeftPath.stroke()
            bottomLeftCorner.path = bottomLeftPath.cgPath
            bottomLeftCorner.strokeColor = UIColor.darkGray.cgColor
            bottomLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(bottomLeftCorner)
            
            let bottomRightPath = UIBezierPath()
            bottomRightPath.lineWidth = 3.0
            bottomRightPath.move(to :       CGPoint(x : rect.size.width,     y : rect.size.height-10));
            bottomRightPath.addLine(to :    CGPoint(x : rect.size.width,     y : rect.size.height));
            bottomRightPath.addLine(to :    CGPoint(x : rect.size.width-10,  y : rect.size.height));
            UIColor.darkGray.setStroke()
            bottomRightPath.stroke()
            bottomRightCorner.path = bottomRightPath.cgPath
            bottomRightCorner.strokeColor = UIColor.darkGray.cgColor
            bottomRightCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(bottomRightCorner)
        }
        else
        {
            topLeftCorner.removeFromSuperlayer();
            topRightCorner.removeFromSuperlayer();
            bottomLeftCorner.removeFromSuperlayer();
            bottomRightCorner.removeFromSuperlayer();
        }
    }
}
