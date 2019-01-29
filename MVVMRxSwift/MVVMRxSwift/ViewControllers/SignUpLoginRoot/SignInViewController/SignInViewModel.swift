//
//  SignInViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/29/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignInViewModel: BaseViewModel {
    let email    : BehaviorRelay<String>  = BehaviorRelay(value: "")
    let password : BehaviorRelay<String>  = BehaviorRelay(value: "")
    
    required init() {
        super.init()
    }
    override func controllerType() -> UIViewController.Type {
        return SignInViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    func signIn(){
        
    }
    func forgotPassword(){
        
    }
    func dontHaveAccount(){
        
    }
}
