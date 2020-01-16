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


private enum ETSSketchUndoRedoStack : Equatable
{
    case add(ETSSketchLayer, CGPoint, CGAffineTransform)
    case pan(ETSSketchLayer, CGPoint, CGAffineTransform)
    case rotate(ETSSketchLayer, CGPoint, CGAffineTransform)
    case pinch(ETSSketchLayer, CGPoint, CGAffineTransform)
    case flipH(ETSSketchLayer, CGPoint, CGAffineTransform)
    case flipV(ETSSketchLayer, CGPoint, CGAffineTransform)
    case delete(ETSSketchLayer, CGPoint, CGAffineTransform)
    
    func mostRecentAction(selfLayer : ETSSketchLayer, fromArray : [ETSSketchUndoRedoStack]) -> (ETSSketchLayer, CGPoint, CGAffineTransform)?
    {
        for index in stride(from: fromArray.count-1, through: 0, by: -1)
        {
            let action = fromArray[index]
            switch action
            {
            case .add(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .pan(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .rotate(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .pinch(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .flipH(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .flipV(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
                {
                    return (layer, center, transform)
                }
                break
            case .delete(let layer, let center, let transform):
                if (layer.isEqual(selfLayer))
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
    fileprivate  var stackUndoRedo = [ETSSketchUndoRedoStack]()
    //    fileprivate  var controlPoint : Int = -1
    //    {
    //        didSet
    //        {
    //            self.delegate?.shouldEnableUndo(isEnable: (self.controlPoint > -1))
    //            self.delegate?.shouldEnableRedo(isEnable: (self.controlPoint < (self.sketchLayers.count-1)))
    //        }
    //    }
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
        if let last = self.stackUndoRedo.last
        {
            self.stackUndoRedo.removeLast()
            switch last
            {
            case .add(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .pan(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .rotate(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .pinch(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .flipH(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .flipV(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            case .delete(let layer, let center, let transform):
                self.undoStep(stack: last, layer: layer, center: center, transform: transform)
                break
            }
        }
    }
    
    
    private func undoStep(stack : ETSSketchUndoRedoStack, layer : ETSSketchLayer, center : CGPoint, transform : CGAffineTransform)
    {
        if let mostRecentData = stack.mostRecentAction(selfLayer : layer, fromArray : self.stackUndoRedo)
        {
            layer.center = mostRecentData.1
            layer.transform = mostRecentData.2
        }
        else
        {
            layer.removeFromSuperview()
        }
    }
    
    
    open func redo()
    {
        
    }
    
    
    open func clear()
    {
        self.subviews.forEach { $0.removeFromSuperview() }
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
        self.stackUndoRedo.append(.add(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didPan(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.pan(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didRotate(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.rotate(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didPinch(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.pinch(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didFlipV(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.flipV(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didFlipH(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.flipH(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
    
    
    func didDelete(sketchLayer: ETSSketchLayer)
    {
        self.stackUndoRedo.append(.delete(sketchLayer, sketchLayer.center, sketchLayer.transform))
    }
}
