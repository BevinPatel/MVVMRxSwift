//
//  ETSImageLayer.swift
//  ETSFormsManager
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit
import CoreGraphics

class ETSImageLayer : ETSSketchLayer
{
    private lazy var topLeftCorner = CAShapeLayer()
    private lazy var topRightCorner = CAShapeLayer()
    private lazy var bottomLeftCorner = CAShapeLayer()
    private lazy var bottomRightCorner = CAShapeLayer()
     
    required init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init?(frame : CGRect, drawable : ETSDrawableImage)
    {
        if (drawable.touchable)
        {
            let size = CGSize(width: drawable.image.size.width * 0.2, height: drawable.image.size.height * 0.2)
            let frame = CGRect(origin : CGPoint(x : (frame.width - size.width)/2, y : (frame.height - size.height)/2), size : size)
            super.init(frame : frame, drawable : drawable)
        }
        else
        {
            super.init(frame : frame, drawable : drawable)
        }
        
        if drawable.touchable
        {
            self.initGestureRecognizers()
            ETSSketchLayer.setSelected(newLayer: self)
        }
    }
    
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        if (!drawable.touchable), let superView = superview
        {
            self.frame = superView.bounds
        }
    }
    
    
    private func initGestureRecognizers()
    {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(ETSImageLayer.didTap(_:)))
        addGestureRecognizer(tapGR)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPan(_:)))
        addGestureRecognizer(panGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPinch(_:)))
        addGestureRecognizer(pinchGR)
        
        let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(ETSImageLayer.didRotate(_:)))
        addGestureRecognizer(rotationGR)
    }
    
    
    override func draw(_ rect: CGRect)
    {
        if ((self.drawable.touchable) && (ETSSketchLayer.selected == self))
        {
            let topLeftPath = UIBezierPath()
            topLeftPath.lineWidth = 3.0
            topLeftPath.move(to:       CGPoint(x:rect.origin.x+10, y:rect.origin.y));
            topLeftPath.addLine(to:    CGPoint(x:rect.origin.x, y:rect.origin.y));
            topLeftPath.addLine(to:    CGPoint(x:rect.origin.x, y:rect.origin.y+10));
            UIColor.darkGray.setStroke()
            topLeftPath.stroke()
            topLeftCorner.path = topLeftPath.cgPath
            topLeftCorner.strokeColor = UIColor.darkGray.cgColor
            topLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topLeftCorner)
            
            let topRightPath = UIBezierPath()
            topRightPath.lineWidth = 3.0
            topRightPath.move(to:       CGPoint(x:rect.size.width-10, y:rect.origin.y));
            topRightPath.addLine(to:    CGPoint(x:rect.size.width, y:rect.origin.y));
            topRightPath.addLine(to:    CGPoint(x:rect.size.width, y:rect.origin.y+10));
            UIColor.darkGray.setStroke()
            topRightPath.stroke()
            topRightCorner.path = topRightPath.cgPath
            topRightCorner.strokeColor = UIColor.darkGray.cgColor
            topRightCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(topRightCorner)
            
            let bottomLeftPath = UIBezierPath()
            bottomLeftPath.lineWidth = 3.0
            bottomLeftPath.move(to:       CGPoint(x:rect.origin.x+10, y:rect.size.height));
            bottomLeftPath.addLine(to:    CGPoint(x:rect.origin.x,    y:rect.size.height));
            bottomLeftPath.addLine(to:    CGPoint(x:rect.origin.x, y:rect.size.height-10));
            UIColor.darkGray.setStroke()
            bottomLeftPath.stroke()
            bottomLeftCorner.path = bottomLeftPath.cgPath
            bottomLeftCorner.strokeColor = UIColor.darkGray.cgColor
            bottomLeftCorner.fillColor = UIColor.clear.cgColor;
            layer.addSublayer(bottomLeftCorner)
            
            let bottomRightPath = UIBezierPath()
            bottomRightPath.lineWidth = 3.0
            bottomRightPath.move(to:       CGPoint(x:rect.size.width, y:rect.size.height-10));
            bottomRightPath.addLine(to:    CGPoint(x:rect.size.width, y:rect.size.height));
            bottomRightPath.addLine(to:    CGPoint(x:rect.size.width-10, y:rect.size.height));
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
        
        if let sketchImage = self.drawable as? ETSDrawableImage
        {
            sketchImage.image.draw(in : rect)
        }
    }
    
    
    //MARK: Gesture Method
    @objc func didTap(_ panGR: UITapGestureRecognizer)
    {
        if (ETSSketchLayer.selected == self)
        {
            ETSImageLayer.setSelected(newLayer: nil)
        }
        else
        {
            ETSImageLayer.setSelected(newLayer: self)
        }
    }
    
    
    @objc func didPan(_ panGR: UIPanGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSImageLayer.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            var translation = panGR.translation(in: self)
            translation = translation.applying(self.transform)
            self.center.x += translation.x
            self.center.y += translation.y
            panGR.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    
    @objc func didPinch(_ pinchGR: UIPinchGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSImageLayer.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            let scale = pinchGR.scale
            
            let center = self.center;
            let size = CGSize(width: self.bounds.size.width*scale, height: self.bounds.size.height*scale)
            self.bounds = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            self.center = center;
            self.setNeedsDisplay();
            pinchGR.scale = 1.0
        }
    }
    
    
    @objc func didRotate(_ rotationGR: UIRotationGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSImageLayer.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            let rotation = rotationGR.rotation
            self.transform = self.transform.rotated(by: rotation)
            rotationGR.rotation = 0.0
        }
    }
}
