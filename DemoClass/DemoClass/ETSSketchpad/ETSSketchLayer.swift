//
//  ETSSketchLayer.swift
//  DemoClass
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit
import SwiftSVG


public enum LineType
{
    case solidLine
    case dottedLine
}


protocol ETSDrawable
{
    var touchable : Bool { get }
}


struct ETSDrawableImage : ETSDrawable
{
    let image       : UIImage
    var touchable   : Bool
    {
        return false
    }
}


struct ETSDrawableSVG : ETSDrawable
{
    let svgData     : Data
    var touchable   : Bool
    {
        return true
    }
}


struct ETSDrawableStock : ETSDrawable
{
    let bezierPath  : UIBezierPath
    let tintColor   : UIColor
    let stockType   : LineType
    
    var touchable   : Bool
    {
        return true
    }
}


protocol ETSSketchLayerDelegate : class
{
    func didAdd(sketchLayer : ETSSketchLayer)
    func didPan(sketchLayer : ETSSketchLayer)
    func didRotate(sketchLayer : ETSSketchLayer)
    func didPinch(sketchLayer : ETSSketchLayer)
    func didFlipV(sketchLayer : ETSSketchLayer)
    func didFlipH(sketchLayer : ETSSketchLayer)
    func didDelete(sketchLayer : ETSSketchLayer)
}


open class ETSSketchLayer : UIView
{
    private weak var delegate   : ETSSketchLayerDelegate?
    let drawable : ETSDrawable
    
    private var tapGesture      : UITapGestureRecognizer?
    private var panGesture      : UIPanGestureRecognizer?
    private var pinchGesture    : UIPinchGestureRecognizer?
    private var rotateGesture   : UIRotationGestureRecognizer?
    
 
    required public init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init(frame : CGRect, drawable : ETSDrawable, delegate : ETSSketchLayerDelegate)
    {
        self.drawable = drawable
        self.delegate = delegate
        super.init(frame : frame)
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
        
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ETSImageLayer.didPinch(_:)))
        if let pinchGesture = self.pinchGesture
        {
            self.addGestureRecognizer(pinchGesture)
        }
    }
    
    
    open func addInto(parent : UIView)
    {
        parent.addSubview(self)
        self.delegate?.didAdd(sketchLayer : self)
    }
    
    
    open func removeFromParent()
    {
        self.removeFromSuperview()
        self.delegate?.didDelete(sketchLayer : self)
    }
    
    
    open func flipHorizontal()
    {
        self.transform = CGAffineTransform(scaleX: -self.transform.a, y: self.transform.d)
        self.delegate?.didFlipH(sketchLayer : self)
    }
    
    
    open func flipVertical()
    {
        self.transform = CGAffineTransform(scaleX: self.transform.a, y: -self.transform.d)
        self.delegate?.didFlipV(sketchLayer : self)
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
            if (ETSSketchpadView.shared?.selected == self)
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
    @objc fileprivate func didTap(_ panGR : UITapGestureRecognizer)
    {
        if (ETSSketchpadView.shared?.selected == self)
        {
            ETSSketchpadView.shared?.setSelected(newLayer : nil)
        }
        else
        {
            ETSSketchpadView.shared?.setSelected(newLayer : self)
        }
    }
    
    
    @objc fileprivate func didPan(_ panGR : UIPanGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            var translation = panGR.translation(in : self)
            translation = translation.applying(self.transform)
            self.center.x += translation.x
            self.center.y += translation.y
            panGR.setTranslation(CGPoint.zero, in : self)
            
            if(panGR.state == .ended)
            {
                self.delegate?.didPan(sketchLayer: self)
            }
        }
    }
    
    
    @objc fileprivate func didPinch(_ pinchGR : UIPinchGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            if pinchGR.state == .began || pinchGR.state == .changed
            {
               pinchGR.view?.transform = (pinchGR.view?.transform.scaledBy(x: pinchGR.scale, y: pinchGR.scale))!
               pinchGR.scale = 1.0
            }
            
            if(pinchGR.state == .ended)
            {
                self.delegate?.didPinch(sketchLayer: self)
            }
        }
    }
    
    
    @objc fileprivate func didRotate(_ rotateGR : UIRotationGestureRecognizer)
    {
        if ((self.drawable.touchable) && (ETSSketchpadView.shared?.selected == self))
        {
            self.superview!.bringSubviewToFront(self)
            let rotation = rotateGR.rotation
            self.transform = self.transform.rotated(by: rotation)
            rotateGR.rotation = 0.0
            
            if(rotateGR.state == .ended)
            {
                self.delegate?.didRotate(sketchLayer: self)
            }
        }
    }
}
