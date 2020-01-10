//
//  SketchpadControlViewController.swift
//  ETSFormsManager
//
//  Created by MAC193 on 7/3/19.
//  Copyright © 2019 MAC202. All rights reserved.
//

import UIKit
import SwiftSVG
import CULColorPicker

protocol SketchpadControlViewControllerDelegate : class
{
    func sketchpadControl(_ controller : SketchpadControlViewController, sketchImage : UIImage?)
    func sketchpadControlDidCancel(_ controller : SketchpadControlViewController)
}

class SketchpadControlViewController : UIViewController
{
    @IBOutlet fileprivate var sketchpadView : ETSSketchpadView?
    
    @IBOutlet fileprivate var undoButton    : UIButton?
    @IBOutlet fileprivate var redoButton    : UIButton?
    @IBOutlet fileprivate var eraseButton   : UIButton?
    
    @IBOutlet fileprivate var solidLineButton   : UIButton?
    @IBOutlet fileprivate var dottedLineButton  : UIButton?
    
    @IBOutlet fileprivate var colorButton       : UIButton?
    @IBOutlet fileprivate var stockSizeSlider   : UISlider?
        
    weak var delegate : SketchpadControlViewControllerDelegate?
    var sketchImage : UIImage?
    
    @IBOutlet fileprivate var vectorCollectionView : UICollectionView?
    fileprivate let vectorNames = [ "svg_barbed_wire",
                                    "svg_bridge",
                                    "svg_car",
                                    "svg_crossroad",
                                    "svg_digging",
                                    "svg_dog",
                                    "svg_down_arrow",
                                    "svg_electric_pole",
                                    "svg_gasoline",
                                    "svg_grass",
                                    "svg_house",
                                    "svg_left_arrow",
                                    "svg_right_arrow",
                                    "svg_smartphone",
                                    "svg_speed_limit",
                                    "svg_split",
                                    "svg_stop",
                                    "svg_traffic_cone",
                                    "svg_transmission_line",
                                    "svg_tree",
                                    "svg_trees",
                                    "svg_up_arrow",
                                    "svg_warning","tipper-truck1"]
    
    lazy var colorPickerController : ColorPickerViewController? =
    {
        if let colorPickerViewController = Bundle.loadNib(ColorPickerViewController.self)
        {
            colorPickerViewController.color = self.colorButton?.backgroundColor
            colorPickerViewController.delegate = self
            colorPickerViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            return colorPickerViewController
        }
        else
        {
            return nil
        }
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.prepareView()
    }
    
    
    private func prepareView()
    {
        self.sketchpadView?.delegate = self
        self.sketchpadView?.addImageInSketch(image : self.sketchImage)

        let rightbutton = UIBarButtonItem.init(title : Text.label.save, style : .plain, target : self, action : #selector(self.onSaveSketch(sender : )))
        self.navigationItem.rightBarButtonItem = rightbutton
       
        let leftbutton = UIBarButtonItem.init(title : Text.label.cancel, style : .plain, target : self, action : #selector(self.onCancelSketch(sender : )))
        self.navigationItem.leftBarButtonItem = leftbutton
        
        self.selectLineType(self.solidLineButton!)
    }
    
    
    @objc func onSaveSketch(sender : UIBarButtonItem)
    {
        self.delegate?.sketchpadControl(self, sketchImage : self.sketchpadView?.getSketchImage())
    }
    
    
    @objc func onCancelSketch(sender : UIBarButtonItem)
    {
        self.delegate?.sketchpadControlDidCancel(self)
    }
}


extension SketchpadControlViewController
{
    @IBAction func onUnDoSketch(_ sender : UIButton)
    {
        self.sketchpadView?.undo()
    }
    
    
    @IBAction func onReDoSketch(_ sender : UIButton)
    {
        self.sketchpadView?.redo()
    }
    
    
    @IBAction func onClearSketch(_ sender : UIButton)
    {
        self.sketchpadView?.clear()
    }
    
    
    @IBAction func onChangeLineType(_ sender : UIButton)
    {
        if (sender == solidLineButton)
        {
            self.sketchpadView?.stockType = .solidLine
        }
        else
        {
            self.sketchpadView?.stockType = .dottedLine
        }
        self.selectLineType(sender)
    }
    
    
    private func selectLineType(_ sender : UIButton)
    {
        self.solidLineButton?.borderwidth = (sender == self.solidLineButton) ? 2 : 0.5
        self.dottedLineButton?.borderwidth = (sender == self.dottedLineButton) ? 2 : 0.5
        
        self.solidLineButton?.bordercolor = (sender == self.solidLineButton) ? UIColor.black : UIColor.lightGray
        self.dottedLineButton?.bordercolor = (sender == self.dottedLineButton) ? UIColor.black : UIColor.lightGray
    }
    
    
    @IBAction func onSelectColorSketch(_ sender : UIButton)
    {
        if let colorPickerController = self.colorPickerController
        {
            let navigationController = UINavigationController(rootViewController : colorPickerController)
            navigationController.modalPresentationStyle = .popover
            
            let popover = navigationController.popoverPresentationController
            popover?.sourceRect = sender.bounds
            popover?.sourceView = sender
            
            self.present(navigationController, animated : true, completion : nil)
        }
    }
    
    
    @objc private func dismissController()
    {
        self.dismiss(animated : true, completion : nil)
    }
    
    
    @IBAction func onChangeStockSketch(_ sender : UISlider)
    {
        self.sketchpadView?.strokeWidth = CGFloat(sender.value)
    }
}


extension SketchpadControlViewController : ETSSketchpadViewDelegate
{
    func shouldEnableRedo(isEnable : Bool)
    {
        self.redoButton?.isEnabled = isEnable
        if (isEnable)
        {
            self.redoButton?.alpha = 1.0
        }
        else
        {
            self.redoButton?.alpha = 0.6
        }
    }
    
    
    func shouldEnableUndo(isEnable : Bool)
    {
        self.undoButton?.isEnabled = isEnable
        if (isEnable)
        {
            self.undoButton?.alpha = 1.0
        }
        else
        {
            self.undoButton?.alpha = 0.6
        }
    }
}


extension SketchpadControlViewController : ColorPickerViewControllerDelegate
{
    func onSelectColor(color : UIColor)
    {
        self.sketchpadView?.strokeColor = color
        self.colorButton?.backgroundColor = color
    }
}

extension SketchpadControlViewController : UICollectionViewDataSource, UICollectionViewDelegate
{
    func numberOfSections(in collectionView : UICollectionView) -> Int
    {
        return 1
    }
    
    
    func collectionView(_ collectionView : UICollectionView, numberOfItemsInSection section : Int) -> Int
    {
        return self.vectorNames.count
    }
    
    
    func collectionView(_ collectionView : UICollectionView, cellForItemAt indexPath : IndexPath) -> UICollectionViewCell
    {
        let cell : VectorImageCollectionViewCell = self.vectorCollectionView!.dequeueReusableCell(for : indexPath)
        if let url = Bundle.main.url(forResource: vectorNames[indexPath.row], withExtension: "svg")
        {
            CALayer(SVGURL: url) { (layer) in
                layer.resizeToFit(cell.contentView.bounds)
                cell.contentView.layer.addSublayer(layer)
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath : IndexPath)
    {
        if let svgUrl = Bundle.main.url(forResource: vectorNames[indexPath.row], withExtension: "svg")
        {
            do
            {
                let svgData = try Data(contentsOf : svgUrl)
                self.sketchpadView?.addSVGInSketch(svgData: svgData)
            }
            catch
            {
                assertionFailure("Not able to get data from svg")
            }
        }
    }
}
