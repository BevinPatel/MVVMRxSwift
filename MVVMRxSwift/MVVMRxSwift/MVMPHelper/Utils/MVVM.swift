//
//  MVMP.swift
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
class MVVM {
    class func navigationController<T:BaseNavigationModel,M:BaseNavigationController>(model : T)->M?{
        let controller = model.initController()
        controller?.baseNavigationModel = model
        if let genericController = controller as? M {
            return genericController
        }
        else{
            fatalError("viewController should be derived from `BaseViewController` class")
        }
    }
    class func viewController<T : BaseViewModel,M:BaseViewController>(model : T)->M?{
        let controller = model.initController()
        controller?.baseViewModel = model
        if let genericCntroller = controller as? M {
            return genericCntroller
        }
        else{
            fatalError("viewController should be derived from `BaseViewController` class")
        }
    }
}
