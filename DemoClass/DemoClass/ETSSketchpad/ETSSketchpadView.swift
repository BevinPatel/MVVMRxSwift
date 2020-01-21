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
    
    static func mostRecentAction(sketchLayer : ETSSketchLayer, undoStack : [ETSSketchUndo], undoIndex : Int) -> ETSSketchUndo?
    {
        for index in stride(from: undoIndex, through: 0, by: -1)
        {
            let action = undoStack[index]
            switch action
            {
            case .add(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .pan(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .rotate(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .pinch(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .flipH(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .flipV(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
                }
                break
            case .delete(let layer, _, _):
                if (layer.isEqual(sketchLayer))
                {
                    return action
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
            self.delegate?.shouldEnableUndo(isEnable: (self.undoIndex > -1))
            self.delegate?.shouldEnableRedo(isEnable: (self.undoIndex < (self.undoStack.count-1)))
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
        self.addInteraction(UIDropInteraction(delegate: self))
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
            let imageLayer = ETSImageLayer(frame : self.bounds, drawable : ETSDrawableImage(image : image), delegate : self)
            imageLayer.addInto(parent : self)
        }
        else
        {
            self.undoIndex = -1
        }
    }
    
    
    public func addSVGInSketch(svgData : Data, location : CGPoint)
    {
        let svgLayer = ETSSVGLayer(center : location, drawable : ETSDrawableSVG(svgData : svgData), delegate : self)
        svgLayer.addInto(parent : self)
    }
    
    
    private func addStockInSketch(bezierPath : UIBezierPath?, touchable : Bool)
    {
        if let bezierPath = bezierPath
        {
            let stockLayer = ETSStockLayer(drawable : ETSDrawableStock(bezierPath : bezierPath, tintColor : self.strokeColor, stockType : self.stockType), delegate : self)
            stockLayer.addInto(parent : self)
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
                sketchLayer.removeFromSuperview()
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .pan(let sketchLayer, let center, let transform):
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .rotate(let sketchLayer, let center, let transform):
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .pinch(let sketchLayer, let center, let transform):
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .flipH(let sketchLayer, let center, let transform):
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .flipV(let sketchLayer, let center, let transform):
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            case .delete(let sketchLayer, let center, let transform):
                self.addSubview(sketchLayer)
                self.undoStep(stack : stack, sketchLayer : sketchLayer, center : center, transform : transform)
                break
            }
        }
    }
    
    
    private func undoStep(stack : ETSSketchUndo, sketchLayer : ETSSketchLayer, center : CGPoint, transform : CGAffineTransform)
    {
        if let recentStack = ETSSketchUndo.mostRecentAction(sketchLayer : sketchLayer, undoStack : self.undoStack, undoIndex : self.undoIndex)
        {
            switch recentStack
            {
            case .add(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .pan(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .rotate(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .pinch(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .flipH(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .flipV(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .delete(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            }
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
                self.addSubview(sketchLayer)
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .pan(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .rotate(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .pinch(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .flipH(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .flipV(let sketchLayer, let center, let transform):
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            case .delete(let sketchLayer, let center, let transform):
                sketchLayer.removeFromSuperview()
                sketchLayer.center = center
                sketchLayer.transform = transform
                break
            }
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
    func didAdd(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.add(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didPan(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.pan(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didRotate(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.rotate(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didPinch(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.pinch(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didFlipV(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.flipV(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didFlipH(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.flipH(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
    
    
    func didDelete(sketchLayer : ETSSketchLayer)
    {
        self.undoIndex += 1
        self.undoStack.insert(.delete(sketchLayer, sketchLayer.center, sketchLayer.transform), at : self.undoIndex)
        self.undoStack = Array(self.undoStack[0 ... self.undoIndex])
        self.undoIndex += 0
    }
}


extension ETSSketchpadView : UIDropInteractionDelegate
{
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
    {
        let location = session.location(in: self)
        
        session.loadObjects(ofClass: SVGURL.self) { (urls) in
            for url in urls
            {
                if let svgUrl = (url as? SVGURL)?.url
                {
                    do
                    {
                        let svgData = try Data(contentsOf : svgUrl)
                        self.addSVGInSketch(svgData: svgData, location: location)
                    }
                    catch
                    {
                        assertionFailure("Not able to get data from svg")
                    }
                }
            }
        }
    }
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: SVGURL.self)
    }
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
    {
        return UIDropProposal(operation: .move)
    }
}
