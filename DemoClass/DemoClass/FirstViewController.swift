//
//  FirstViewController.swift
//  DemoClass
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController
{
    var base64ToImage : String?
    @IBOutlet var sketchpadView : UIImageView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func onDrawShapes(tapGesture : UITapGestureRecognizer)
    {
        let sketchpadControlViewController = SketchpadControlViewController()
        let navigationController = SketchpadNavigationController(rootViewController : sketchpadControlViewController)
        sketchpadControlViewController.title = "Sketchpad"
        sketchpadControlViewController.delegate = self
        sketchpadControlViewController.sketchImage = base64ToImage?.base64ToImage
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension FirstViewController : SketchpadControlViewControllerDelegate
{
    func sketchpadControl(_ controller : SketchpadControlViewController, sketchImage : UIImage?)
    {
        if let sketchImage = sketchImage, let base64String = sketchImage.base64String
        {
            self.base64ToImage = base64String
            self.sketchpadView?.image = sketchImage
        }
        else
        {
            self.base64ToImage = ""
            self.sketchpadView?.image = nil
        }
        controller.dismiss(animated : true, completion : nil)
    }
    
    
    func sketchpadControlDidCancel(_ controller : SketchpadControlViewController)
    {
        controller.dismiss(animated : true, completion : nil)
    }
}
