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
    required init?(coder: NSCoder)
    {
        return nil
    }
    
    
    init(frame : CGRect, drawable : ETSDrawableImage, delegate : ETSSketchLayerDelegate)
    {
        super.init(frame : frame, drawable : drawable, delegate : delegate)
    }
    
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        if (!drawable.touchable), let superView = superview
        {
            self.frame = superView.bounds
        }
    }
    
    
    override func draw(_ rect : CGRect)
    {
        if let sketchImage = self.drawable as? ETSDrawableImage
        {
            sketchImage.image.draw(in : rect)
        }
    }
}
