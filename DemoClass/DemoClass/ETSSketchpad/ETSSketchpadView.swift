//
//  ETSSketchpadView.swift
//  ETSFormsManager
//
//  Created by MAC193 on 7/3/19.
//  Copyright © 2019 MAC202. All rights reserved.
//

import UIKit
import SwiftSVG

@objc protocol ETSSketchpadViewDelegate : class
{
    func shouldEnableRedo(isEnable : Bool)
    func shouldEnableUndo(isEnable : Bool)
    func shouldEnanleFlipAndDelete(isEnable : Bool)
}


private enum ETSSketchUndo : Equatable
{
    case add(ETSSketchLayer, CGPoint, CGAffineTransform)
    case pan(ETSSketchLayer, CGPoint, CGAffineTransform)
    case rotate(ETSSketchLayer, CGPoint, CGAffineTransform)
    case pinch(ETSSketchLayer, CGPoint, CGAffineTransform)
    case flipH(ETSSketchLayer, CGPoint, CGAffineTransform)
    case flipV(ETSSketchLayer, CGPoint, CGAffineTransform)
    case delete(ETSSketchLayer, CGPoint, CGAffineTransform)
    
    static func mostRecentAction(sketchLayer : ETSSketchLayer, undoStack : [ETSSketchUndo], undoIndex : Int) -> (ETSSketchLayer, CGPoint, CGAffineTransform)?
    {
        for index in stride(from: undoIndex, through: 0, by: -1)
        {
            let action = undoStack[index]
            switch action
            {
            case .add(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .pan(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .rotate(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .pinch(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .flipH(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .flipV(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .delete(let layer, let center, let transform):
                if (layer.isEqual(sketchLayer))
                {
                    return (layer, center, transform)
                }
                break
            }
        }
        return nil
    }
}


open class ETSSketchpadView : UIView
{
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
                self.stockLayer.lineDashPattern = [5, 5]
            }
        }
    }
    open var strokeColor = UIColor.black
    open var strokeWidth : CGFloat = 2.0
    @IBOutlet var delegate : ETSSketchpadViewDelegate?
    
    //-----For undo and redo--------------------
    private(set) var selected : ETSSketchLayer?
    fileprivate  var undoStack  =   [ETSSketchUndo]()
    fileprivate  var undoIndex  =   -1
    {
        didSet
        {
            print("History Index \(self.undoIndex)")
//            self.delegate?.shouldEnableUndo(isEnable: (self.controlPoint > -1))
//            self.delegate?.shouldEnableRedo(isEnable: (self.controlPoint < (self.sketchLayers.count-1)))
        }
    }
    //------------------------------------------
    
    //-----For free hand drawing----------------
    fileprivate var bezierPath      : UIBezierPath?
    fileprivate var bezierCounter   : Int = 0
    fileprivate var bezierPoints    : [CGPoint] = [CGPoint](repeating : CGPoint(), count : 5)
    //------------------------------------------
    
    
    private lazy var stockLayer : CAShapeLayer = {
        let stockLayer =  CAShapeLayer()
        stockLayer.fillColor = UIColor.clear.cgColor
        stockLayer.lineCap = .round
        stockLayer.lineJoin = .round
        return stockLayer
    }()
    
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder : aDecoder)
        ETSSketchpadView.shared = self
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
    
    
    public func addImageInSketch(image : UIImage?)
    {
        if let image = image
        {
            let imageLayer = ETSImageLayer(frame: self.bounds, drawable : ETSDrawableImage(image: image), delegate : self)
            imageLayer.addInto(parent: self)
        }
    }
    
    
    public func addSVGInSketch(svgData : Data)
    {
        let svgLayer = ETSSVGLayer(contentSize : self.bounds.size, drawable : ETSDrawableSVG(svgData: svgData), delegate : self)
        svgLayer.addInto(parent: self)
    }
    
    
    private func addStockInSketch(bezierPath : UIBezierPath?, touchable : Bool)
    {
        if let bezierPath = bezierPath
        {
            let stockLayer = ETSStockLayer(drawable : ETSDrawableStock(bezierPath : bezierPath, tintColor : self.strokeColor, stockType : self.stockType), delegate : self)
            stockLayer.addInto(parent: self)
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
    
    
    open override func touchesCancelled(_ touches : Set<UITouch>, with event : UIEvent?)
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
    open func undo()
    {
        if (self.undoStack.indices.contains(self.undoIndex))
        {
            let stack = self.undoStack[self.undoIndex]
            self.undoIndex -= 1
            
            switch stack
            {
            case .add(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .pan(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .rotate(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .pinch(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .flipH(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .flipV(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .delete(let sketchLayer, let center, let transform):
                self.undoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            }
        }
    }
    
    
    private func undoStep(stack : ETSSketchUndo, sketchLayer : ETSSketchLayer, center : CGPoint, transform : CGAffineTransform)
    {
        if let recentStack = ETSSketchUndo.mostRecentAction(sketchLayer : sketchLayer, undoStack : self.undoStack, undoIndex : self.undoIndex)
        {
            sketchLayer.center = recentStack.1
            sketchLayer.transform = recentStack.2
        }
        else
        {
            sketchLayer.removeFromSuperview()
        }
    }
    
    
    open func redo()
    {
        if (self.undoStack.indices.contains(self.undoIndex + 1))
        {
            let stack = self.undoStack[self.undoIndex + 1]
            self.undoIndex += 1
            
            switch stack
            {
            case .add(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .pan(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .rotate(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .pinch(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .flipH(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .flipV(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            case .delete(let sketchLayer, let center, let transform):
                self.redoStep(stack: stack, sketchLayer: sketchLayer, center: center, transform: transform)
                break
            }
        }
    }
    
    
    private func redoStep(stack : ETSSketchUndo, sketchLayer : ETSSketchLayer, center : CGPoint, transform : CGAffineTransform)
    {
        if let superView = sketchLayer.superview, superView.isEqual(self)
        {
            sketchLayer.transform = transform
            sketchLayer.center = center
        }
        else
        {
            self.addSubview(sketchLayer)
            sketchLayer.transform = transform
            sketchLayer.center = center
        }
    }
    
    
    open func clear()
    {
        self.subviews.forEach { $0.removeFromSuperview() }
        self.undoStack.removeAll()
        self.undoIndex = -1
    }
    
    
    open func flipHSelected()
    {
        self.selected?.flipHorizontal()
    }
    
    
    open func flipVSelected()
    {
        self.selected?.flipVertical()
    }
    
    
    open func deleteSelected()
    {
        self.selected?.removeFromParent()
        ETSSketchpadView.shared?.setSelected(newLayer: nil)
    }
    
    
    /*Returns the drawn path as Image. Adding subview to this view will also get returned in this image.*/
    open func getSketchImage() -> UIImage?
    {
        ETSSketchpadView.shared?.setSelected(newLayer : nil)
        UIGraphicsBeginImageContext(CGSize(width : self.bounds.size.width, height : self.bounds.size.height))
        self.layer.render(in : UIGraphicsGetCurrentContext()!)
        let sketch : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return sketch
    }
}


extension ETSSketchpadView
{
    private(set) static var shared : ETSSketchpadView?
    
    public func setSelected(newLayer : ETSSketchLayer?)
    {
        if let oldLayer = ETSSketchpadView.shared?.selected
        {
            ETSSketchpadView.shared?.selected = newLayer
            oldLayer.setNeedsDisplay()
            newLayer?.setNeedsDisplay()
        }
        else
        {
            ETSSketchpadView.shared?.selected = newLayer
            newLayer?.setNeedsDisplay()
        }
        self.delegate?.shouldEnanleFlipAndDelete(isEnable: (self.selected == nil) ? false : true)
    }
}


extension ETSSketchpadView : ETSSketchLayerDelegate
{
    func didAdd(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.add(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didPan(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.pan(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didRotate(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.rotate(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didPinch(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.pinch(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didFlipV(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.flipV(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didFlipH(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.flipH(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
    
    
    func didDelete(sketchLayer: ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.delete(sketchLayer, sketchLayer.center, sketchLayer.transform), at: self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
    }
}
