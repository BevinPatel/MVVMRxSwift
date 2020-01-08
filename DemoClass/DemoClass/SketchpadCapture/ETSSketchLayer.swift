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
 
    required init?(coder: NSCoder)
    {
        return nil
    }
    
    init(frame : CGRect, drawable : ETSDrawable)
    {
        self.drawable = drawable
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
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


protocol ETSDrawable
{
    var touchable : Bool { get }
}


struct ETSDrawableImage : ETSDrawable
{
    let image           : UIImage
    let tintColor       : UIColor
    let touchable       : Bool
}


struct ETSDrawableStock : ETSDrawable
{
    let bezierPath      : UIBezierPath
    let tintColor       : UIColor
    var touchable: Bool
    {
        return true
    }
}
