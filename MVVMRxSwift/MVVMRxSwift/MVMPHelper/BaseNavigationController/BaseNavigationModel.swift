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
    let disposeBag = DisposeBag()
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
    //Navigation methods
    func setViewModels(viewModels: [BaseViewModel], animated: Bool){
        self.navigationActions.onNext(.set(viewModels: viewModels, animated: animated))
    }
    func push(viewModel: BaseViewModel, animated: Bool){
        self.navigationActions.onNext(.push(viewModel: viewModel, animated: animated))
    }
    func pop(animated: Bool){
        self.navigationActions.onNext(.pop(animated: animated))
    }
    func present(viewModel: BaseViewModel, animated: Bool,completion: (() -> Swift.Void)? = nil){
        self.navigationActions.onNext(.present(viewModel: viewModel, animated: animated, completion: completion))
    }
    func dismiss(animated : Bool,completion: (() -> Swift.Void)?){
        self.navigationActions.onNext(.dismiss(animated: animated, completion: completion))
    }
}
