//
//  SketchpadControlViewController.swift
//  ETSFormsManager
//
//  Created by MAC193 on 7/3/19.
//  Copyright © 2019 MAC202. All rights reserved.
//

import UIKit
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
    
    @IBOutlet fileprivate var colorButton       : UIButton?
    @IBOutlet fileprivate var stockSizeSlider   : UISlider?
        
    weak var delegate : SketchpadControlViewControllerDelegate?
    var sketchImage : UIImage?
    
    @IBOutlet fileprivate var vectorCollectionView : UICollectionView?
    fileprivate let vectorNames = ["crossWays", "electricPoleA", "electricPoleB", "gasoline", "house", "road", "splitWays", "tree", "trees", "tunnel", "warning"]
    
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
        self.sketchpadView?.addImageInSketch(image : self.sketchImage, touchable : false)

        let rightbutton = UIBarButtonItem.init(title : Text.label.save, style : .plain, target : self, action : #selector(self.onSaveSketch(sender : )))
        self.navigationItem.rightBarButtonItem = rightbutton
       
        let leftbutton = UIBarButtonItem.init(title : Text.label.cancel, style : .plain, target : self, action : #selector(self.onCancelSketch(sender : )))
        self.navigationItem.leftBarButtonItem = leftbutton
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
        cell.imageView?.image = UIImage(named: vectorNames[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath : IndexPath)
    {
        if let image = UIImage(named: vectorNames[indexPath.row])
        {
            self.sketchpadView?.addImageInSketch(image : image, touchable : true)
        }
    }
}
