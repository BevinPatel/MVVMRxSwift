//
//  SignUpLoginNavigationModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import UIKit

class SignUpLoginNavigationModel : BaseNavigationModel{
    override func controllerType() -> UINavigationController.Type {
        return SignUpLoginNavigationController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    override func rootModel() -> BaseViewModel {
        let getStartedViewModel = GetStartedViewModel()
        getStartedViewModel.events.subscribe(onNext: { [weak self] event in
            self?.onGetStart()
        }).disposed(by: disposeBag)
        return getStartedViewModel
    }
    private func onGetStart(){
        self.navigationActions.onNext(NavigationStackAction.push(viewModel: self.signInViewModel(), animated: true))
    }
    private func signInViewModel()->SignInViewModel{
        let signInModel = SignInViewModel()
        signInModel.event.subscribe(onNext:{[weak self] event in
            switch (event){
                case .onSignIn:
                    self?.onHomeScreen()
                    break;
                case .onForgotPassword:
                    self?.onForgotPassword()
                    break;
                case .onCreateAccount:
                    self?.onCreateAccount()
            }
        }).disposed(by: disposeBag)
        return signInModel
    }
    private func onHomeScreen(){
        self.navigationActions.onNext(NavigationStackAction.push(viewModel: HomeScreenViewModel(), animated: true))
    }
    private func onForgotPassword(){
        self.navigationActions.onNext(NavigationStackAction.push(viewModel: ForgotPasswordViewModel(), animated: true))
    }
    private func onCreateAccount(){
        self.navigationActions.onNext(NavigationStackAction.push(viewModel: CreateAccountViewModel(), animated: true))
    }
}
