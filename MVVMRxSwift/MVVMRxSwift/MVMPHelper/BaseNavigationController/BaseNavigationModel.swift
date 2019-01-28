//
//  BaseViewModel.swift
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
enum NavigationStackAction {
    case set(viewModels: [BaseViewModel], animated: Bool)
    case push(viewModel: BaseViewModel, animated: Bool)
    case pop(animated: Bool)
    case present(viewModel: BaseViewModel, animated : Bool,completion: (() -> Swift.Void)?)
    case dismiss(animated : Bool,completion: (() -> Swift.Void)?)
}
class BaseNavigationModel{
    lazy var navigationActions = BehaviorSubject<NavigationStackAction>(value: .set(viewModels: [self.rootModel()], animated: true))
    required init() {
        
    }
    func initController<T:BaseNavigationController>()->T?{
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
    func controllerType() -> UINavigationController.Type{
        fatalError("Subclasses need to implement the `controllerType()` method.")
    }
    func rootModel()->BaseViewModel{
        fatalError("Subclasses need to implement the `rootModel()` method.")
    }
}
