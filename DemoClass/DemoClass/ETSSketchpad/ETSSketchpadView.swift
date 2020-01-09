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
    open var stockType : LineType = .solidLine
    {
            didSet
            {
                switch self.stockType
                {
                case .solidLine:
                    self.stockLayer.lineDashPhase = 0
                    self.stockLayer.lineDashPattern = []
                case .dottedLine:
                    self.stockLayer.lineDashPhase = 5
                    self.stockLayer.lineDashPattern = [5,5]
                case .solidArrow:
                    self.stockLayer.lineDashPhase = 0
                    self.stockLayer.lineDashPattern = []
                case .dottedArrow:
                    self.stockLayer.lineDashPhase = 5
                    self.stockLayer.lineDashPattern = [5,5]
                }
            }
    }
        
    fileprivate var bezierPath : UIBezierPath?
    fileprivate var bezierPoints = [CGPoint](repeating : CGPoint(), count : 5)
    fileprivate var bezierCounter : Int = 0
    
    private lazy var stockLayer : CAShapeLayer = {
        let stockLayer =  CAShapeLayer()
        stockLayer.fillColor = UIColor.clear.cgColor
        stockLayer.lineCap = .round
        stockLayer.lineJoin = .round
        return stockLayer
    }()
    
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
        self.layer.borderColor = UIColor.Form.inputFieldBorderColor.cgColor
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
            self.sketchLayers = Array(self.sketchLayers[0 ... self.controlPoint])
            self.controlPoint += 0// just for update undo redo button
        }
    }
    
    
    private func addStockInSketch(bezierPath : UIBezierPath?, touchable : Bool)
    {
        if let bezierPath = bezierPath, let layer = ETSStockLayer(frame: bezierPath.bounds, drawable : ETSDrawableStock(bezierPath: bezierPath, tintColor: self.strokeColor))
        {
            self.controlPoint += 1
            self.sketchLayers.append(layer)
            self.addSubview(layer)
            self.sketchLayers = Array(self.sketchLayers[0 ... self.controlPoint])
            self.controlPoint += 0// just for update undo redo button
        }
    }
    
    
    override open func draw(_ rect : CGRect)
    {
        stockLayer.removeFromSuperlayer()
        if let bezierPath = self.bezierPath
        {
            stockLayer.frame = rect
            stockLayer.lineWidth = bezierPath.lineWidth
            stockLayer.strokeColor = strokeColor.cgColor
            stockLayer.path = bezierPath.cgPath
            self.layer.addSublayer(stockLayer)
        }
    }
    
    
    // To prevent ios13 present controller default gesture to dismiss screen while draw signature.
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer : UIGestureRecognizer) -> Bool
    {
        return (gestureRecognizer.view == self)
    }
    
    
    override open func touchesBegan(_ touches : Set<UITouch>, with event : UIEvent?)
    {
        if let currentPoint = touchPoint(touches)
        {
            bezierPoints[0] = currentPoint
            bezierCounter = 0
            bezierPath = UIBezierPath()
            bezierPath?.lineWidth = self.strokeWidth
            bezierPath?.lineCapStyle = .round
            bezierPath?.lineJoinStyle = .round
        }
    }
    
    
    override open func touchesMoved(_ touches : Set<UITouch>, with event : UIEvent?)
    {
        if let currentPoint = touchPoint(touches)
        {
            bezierCounter += 1
            bezierPoints[bezierCounter] = currentPoint

            //Smoothing is done by Bezier Equations where curves are calculated based on four concurrent  points drawn
            if (bezierCounter == 4)
            {
                bezierPoints[3] = CGPoint(x: (bezierPoints[2].x + bezierPoints[4].x) / 2 , y: (bezierPoints[2].y + bezierPoints[4].y) / 2)
                bezierPath?.move(to : bezierPoints[0])
                bezierPath?.addCurve(to : bezierPoints[3], controlPoint1 : bezierPoints[1], controlPoint2 : bezierPoints[2])
                setNeedsDisplay()
                bezierPoints[0] = bezierPoints[3]
                bezierPoints[1] = bezierPoints[4]
                bezierCounter = 1
            }
        }
    }
    
    
    override open func touchesEnded(_ touches : Set<UITouch>, with event : UIEvent?)
    {
        self.addStockInSketch(bezierPath : self.bezierPath, touchable : true)
        self.bezierPath = nil
        self.bezierCounter = 0
        self.bezierPoints = [CGPoint](repeating : CGPoint(), count : 5)
        self.setNeedsDisplay()
    }
    
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.bezierPath = nil
        self.bezierCounter = 0
        self.bezierPoints = [CGPoint](repeating : CGPoint(), count : 5)
        self.setNeedsDisplay()
    }
    
    
    func touchPoint(_ touches : Set<UITouch>) -> CGPoint?
    {
        if let touch = touches.first
        {
            return touch.location(in: self)
        }
        return nil
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


public enum LineType
{
    case solidLine
    case dottedLine
    case solidArrow
    case dottedArrow
}
