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
    let isEnable : BehaviorRelay<Bool>  = BehaviorRelay(value: false)
    
    required init() {
        super.init()
        email.subscribe(onNext:{[weak self] value in
            self?.isEnable.accept((value == "bevinpatel20" && self?.password.value == "1234"))
        }).disposed(by: disposeBag)
        password.subscribe(onNext:{[weak self] value in
            self?.isEnable.accept((value == "1234" && self?.email.value == "bevinpatel20"))
        }).disposed(by: disposeBag)
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
