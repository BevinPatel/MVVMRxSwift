//
//  SketchpadNavigationController.swift
//  ETSFormsManager
//
//  Created by MAC193 on 1/7/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit

class SketchpadNavigationController : UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    override var shouldAutorotate : Bool
    {
        return true
    }
    
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        switch UIDevice.current.orientation
        {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .landscapeLeft
        }
    }
    
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return .landscape
    }
}
