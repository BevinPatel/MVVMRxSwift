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

enum SignInEvent{
    case onSignIn
    case onForgotPassword
    case onCreateAccount
}
class SignInViewModel: BaseViewModel {
    
    var event    : PublishSubject<SignInEvent> = PublishSubject()
    let email    : BehaviorRelay<String>  = BehaviorRelay(value: "")
    let password : BehaviorRelay<String>  = BehaviorRelay(value: "")
    let isEnable : BehaviorRelay<Bool>  = BehaviorRelay(value: false)
    
    required init() {
        super.init()
        Observable.combineLatest(email,password).subscribe(onNext: {[weak self] emailText, passwordText in
            self?.isEnable.accept(emailText == "bevinpatel20@gmail.com" && passwordText == "1234")
        }).disposed(by: disposeBag)
    }
    override func controllerType() -> UIViewController.Type {
        return SignInViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    func signIn(){
        event.onNext(.onSignIn)
    }
    func forgotPassword(){
        event.onNext(.onForgotPassword)
    }
    func dontHaveAccount(){
        event.onNext(.onCreateAccount)
    }
}
