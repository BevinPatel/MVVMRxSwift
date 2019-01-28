//
//  BaseViewModel.swift
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import UIKit

enum ControllerStackAction {
    case present(viewModel: BaseViewModel, animated : Bool)
    case dismiss(animated : Bool)
}
class BaseViewModel{
    required init() {
    }
    func initController<T:BaseViewController>()->T?{
        if let genericType = self.controllerType() as? T.Type{
             return self.controllerStoryBoard().getController(genericType)
        }
        else{
            fatalError("ControllerType class should be derived from `BaseViewController` class.")
        }
    }
    func controllerStoryBoard()->UIStoryboard{
        fatalError("Subclasses need to implement the `controllerStoryBoard()` method.")
    }
    func controllerType() -> UIViewController.Type{
        fatalError("Subclasses need to implement the `controllerType()` method.")
    }
}
