//
//  ETSSketchpadView.swift
//  ETSFormsManager
//
//  Created by MAC193 on 7/3/19.
//  Copyright © 2019 MAC202. All rights reserved.
//

import UIKit

@objc protocol ETSSketchpadViewDelegate : class
{
    func shouldEnableRedo(isEnable : Bool)
    func shouldEnableUndo(isEnable : Bool)
}


open class ETSSketchpadView : UIView
{
    open var strokeColor = UIColor.black
    open var strokeWidth : CGFloat = 2.0
        
    @IBOutlet weak var delegate : ETSSketchpadViewDelegate?
    
    fileprivate var sketchLayers = [ETSSketchLayer]()
    fileprivate var controlPoint : Int = -1
    {
        didSet
        {
            self.delegate?.shouldEnableUndo(isEnable: (self.controlPoint > -1))
            self.delegate?.shouldEnableRedo(isEnable: (self.controlPoint < (self.sketchLayers.count-1)))
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder : aDecoder)
        self.setupView()
    }

    private func setupView()
    {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.purple.cgColor
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1
        self.clipsToBounds = true
    }
    
    
    public func addImageInSketch(image : UIImage?, touchable : Bool)
    {
        if let image = image, let layer = ETSImageLayer(frame: self.bounds, drawable : ETSDrawableImage(image: image, tintColor: self.strokeColor, touchable: touchable))
        {
            self.controlPoint += 1
            self.sketchLayers.append(layer)
            self.addSubview(layer)
        }
    }
    
    
    //MARK: Utility Methods
    /*Clears the drawn paths in the canvas*/
    open func clear()
    {
        self.sketchLayers.removeAll()
        self.subviews.forEach { $0.removeFromSuperview() }
        self.controlPoint = -1
    }
    
    
    open func redo()
    {
        self.controlPoint += 1
        self.addSubview(self.sketchLayers[self.controlPoint])
    }
    
    
    open func undo()
    {
        self.sketchLayers[controlPoint].removeFromSuperview()
        self.controlPoint -= 1
    }
    
    
    /*Returns the drawn path as Image. Adding subview to this view will also get returned in this image.*/
    open func getSketchImage() -> UIImage?
    {
        UIGraphicsBeginImageContext(CGSize(width : self.bounds.size.width, height : self.bounds.size.height))
        self.layer.render(in : UIGraphicsGetCurrentContext()!)
        let sketch : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return sketch
    }
}
