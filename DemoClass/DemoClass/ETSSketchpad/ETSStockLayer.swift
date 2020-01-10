//
//  ETSStockLayer.swift
//  ETSFormsManager
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit
import CoreGraphics

class ETSStockLayer : ETSSketchLayer
{
    private lazy var topLeftCorner = CAShapeLayer()
    private lazy var topRightCorner = CAShapeLayer()
    private lazy var bottomLeftCorner = CAShapeLayer()
    private lazy var bottomRightCorner = CAShapeLayer()
   
    private lazy var stockLayer : CAShapeLayer = {
        let stockLayer =  CAShapeLayer()
        stockLayer.fillColor = UIColor.clear.cgColor
        stockLayer.lineCap = .round
        stockLayer.lineJoin = .round
        if let sketchStock = self.drawable as? ETSDrawableStock
        {
            switch sketchStock.stockType
            {
            case .solidLine:
                stockLayer.lineDashPhase = 0
                stockLayer.lineDashPattern = []
            case .dottedLine:
                stockLayer.lineDashPhase = 5
                stockLayer.lineDashPattern = [5, 5]
            }
        }
        return stockLayer
    }()
    
    
    required init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init(drawable : ETSDrawableStock)
    {
        super.init(frame : drawable.bezierPath.bounds, drawable : drawable)
        ETSSketchLayer.setSelected(newLayer : nil)
    }
    
    
    override func draw(_ rect : CGRect)
    {
        if (ETSSketchLayer.selected == self)
        {
            let topLeftPath = UIBezierPath()
            topLeftPath.lineWidth = 3.0
            topLeftPath.move(to :       CGPoint(x : rect.origin.x + 10, y : rect.origin.y));
            topLeftPath.addLine(to :    CGPoint(x : rect.origin.x,      y : rect.origin.y));
            topLeftPath.addLine(to :    CGPoint(x : rect.origin.x,      y : rect.origin.y + 10));
            UIColor.darkGray.setStroke()
            topLeftPath.stroke()
            topLeftCorner.path = topLeftPath.cgPath
            topLeftCorner.strokeColor = UIColor.darkGray.cgColor
            topLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topLeftCorner)
            
            let topRightPath = UIBezierPath()
            topRightPath.lineWidth = 3.0
            topRightPath.move(to :      CGPoint(x : rect.size.width - 10,   y : rect.origin.y));
            topRightPath.addLine(to :   CGPoint(x : rect.size.width,        y : rect.origin.y));
            topRightPath.addLine(to :   CGPoint(x : rect.size.width,        y : rect.origin.y + 10));
            UIColor.darkGray.setStroke()
            topRightPath.stroke()
            topRightCorner.path = topRightPath.cgPath
            topRightCorner.strokeColor = UIColor.darkGray.cgColor
            topRightCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topRightCorner)
            
            let bottomLeftPath = UIBezierPath()
            bottomLeftPath.lineWidth = 3.0
            bottomLeftPath.move(to :    CGPoint(x : rect.origin.x + 10, y : rect.size.height));
            bottomLeftPath.addLine(to : CGPoint(x : rect.origin.x,      y : rect.size.height));
            bottomLeftPath.addLine(to : CGPoint(x : rect.origin.x,      y : rect.size.height - 10));
            UIColor.darkGray.setStroke()
            bottomLeftPath.stroke()
            bottomLeftCorner.path = bottomLeftPath.cgPath
            bottomLeftCorner.strokeColor = UIColor.darkGray.cgColor
            bottomLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(bottomLeftCorner)
            
            let bottomRightPath = UIBezierPath()
            bottomRightPath.lineWidth = 3.0
            bottomRightPath.move(to :       CGPoint(x : rect.size.width,     y : rect.size.height - 10));
            bottomRightPath.addLine(to  :   CGPoint(x : rect.size.width,     y : rect.size.height));
            bottomRightPath.addLine(to  :   CGPoint(x : rect.size.width - 10,  y : rect.size.height));
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
        
        if let sketchStock = self.drawable as? ETSDrawableStock
        {
            let origin = CGPoint(x: -sketchStock.bezierPath.bounds.origin.x, y: -sketchStock.bezierPath.bounds.origin.y)
            stockLayer.frame = CGRect(origin : origin, size : sketchStock.bezierPath.bounds.size)
            stockLayer.lineWidth = sketchStock.bezierPath.lineWidth
            stockLayer.strokeColor = sketchStock.tintColor.cgColor
            stockLayer.path = sketchStock.bezierPath.cgPath
            self.layer.addSublayer(stockLayer)
        }
    }
}
