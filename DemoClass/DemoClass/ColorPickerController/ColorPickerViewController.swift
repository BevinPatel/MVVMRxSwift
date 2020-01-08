//
//  ColorPickerViewController.swift
//  ETSFormsManager
//
//  Created by MAC193 on 12/10/19.
//  Copyright © 2019 MAC202. All rights reserved.
//

import UIKit
import CULColorPicker

protocol ColorPickerViewControllerDelegate : class
{
    func onSelectColor(color : UIColor)
}

class ColorPickerViewController : UIViewController
{
    @IBOutlet weak var colorPicker : ColorPickerView!
    @IBOutlet weak var colorView : UIView!
    
    weak var delegate : ColorPickerViewControllerDelegate?
    var color : UIColor!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.colorPicker.updateSelectedColor(self.color!)
        self.colorPicker.updateBrightness(1.0)
        self.colorView.backgroundColor = self.color
        self.colorPicker.delegate = self
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem : .done, target : self, action : #selector(onDone))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    
    @objc private func onDone()
    {
        self.delegate?.onSelectColor(color : self.color!)
        self.dismiss(animated : true, completion : nil)
    }
    
    
    @IBAction func onChangeStockSketch(_ sender : UISlider)
    {
        self.colorPicker.updateBrightness(CGFloat(sender.value))
    }
}


extension ColorPickerViewController : ColorPickerViewDelegate
{
    func colorPickerWillBeginDragging(_ colorPicker : ColorPickerView)
    {
        self.color = colorPicker.selectedColor
        self.colorView.backgroundColor = self.color
    }
    
    
    func colorPickerDidEndDagging(_ colorPicker : ColorPickerView)
    {
        self.color = colorPicker.selectedColor
        self.colorView.backgroundColor = self.color
    }
    
    
    func colorPickerDidSelectColor(_ colorPicker : ColorPickerView)
    {
        self.color = colorPicker.selectedColor
        self.colorView.backgroundColor = self.color
    }
}
