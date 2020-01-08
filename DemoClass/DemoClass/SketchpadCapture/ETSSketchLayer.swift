//
//  ETSSketchLayer.swift
//  DemoClass
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit

class ETSSketchLayer : UIView
{
    let drawable : ETSDrawable
    
    private var tapGesture      : UITapGestureRecognizer?
    private var panGesture      : UIPanGestureRecognizer?
    private var pinchGesture    : UIPinchGestureRecognizer?
    private var rotateGesture   : UIRotationGestureRecognizer?
 
    required init?(coder: NSCoder)
    {
        return nil
    }
    
    init(frame : CGRect, drawable : ETSDrawable)
    {
        self.drawable = drawable
        super.init(frame: frame)
        self.initGestureRecognizers()
        self.backgroundColor = .clear
    }
    
    private func initGestureRecognizers()
    {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(ETSImageLayer.didTap(_:)))
        if let tapGesture = self.tapGesture
        {
            self.addGestureRecognizer(tapGesture)
        }
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPan(_:)))
        if let panGesture = self.panGesture
        {
            self.addGestureRecognizer(panGesture)
        }
        
        self.rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(ETSImageLayer.didRotate(_:)))
        if let rotateGesture = self.rotateGesture
        {
            self.addGestureRecognizer(rotateGesture)
        }
        
        if (self.drawable.isVector)
        {
            self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPinch(_:)))
            if let pinchGesture = self.pinchGesture
            {
                self.addGestureRecognizer(pinchGesture)
            }
        }
    }
}


extension ETSSketchLayer
{
    private(set) static var selected : ETSSketchLayer?
       
    public static func setSelected(newLayer : ETSSketchLayer?)
    {
        if let oldLayer = ETSSketchLayer.selected
        {
            ETSSketchLayer.selected = newLayer
            oldLayer.setNeedsDisplay()
            newLayer?.setNeedsDisplay()
        }
        else
        {
            ETSSketchLayer.selected = newLayer
            newLayer?.setNeedsDisplay()
        }
    }
}


extension ETSSketchLayer
{
    // To prevent ios13 present controller default gesture to dismiss screen while draw signature.
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer : UIGestureRecognizer) -> Bool
    {
        if (self.tapGesture == gestureRecognizer)
        {
            return true// always work for select deselect
        }
        else
        {
            if (ETSSketchLayer.selected == self)
            {
                if ((self.panGesture == gestureRecognizer) || (self.pinchGesture == gestureRecognizer) || (self.rotateGesture == gestureRecognizer))
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
    }
    
    //MARK: Gesture Method
    @objc fileprivate func didTap(_ panGR: UITapGestureRecognizer)
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
    
    
    @objc fileprivate func didPan(_ panGR: UIPanGestureRecognizer)
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
    
    
    @objc fileprivate func didPinch(_ pinchGR: UIPinchGestureRecognizer)
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
    
    
    @objc fileprivate func didRotate(_ rotationGR: UIRotationGestureRecognizer)
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


protocol ETSDrawable
{
    var touchable : Bool { get }
    var isVector : Bool { get }
}


struct ETSDrawableImage : ETSDrawable
{
    let image           : UIImage
    let tintColor       : UIColor
    let touchable       : Bool
    var isVector        : Bool
    {
        return true
    }
}


struct ETSDrawableStock : ETSDrawable
{
    let bezierPath      : UIBezierPath
    let tintColor       : UIColor
    var touchable: Bool
    {
        return true
    }
    var isVector         : Bool
    {
        return false
    }
}
