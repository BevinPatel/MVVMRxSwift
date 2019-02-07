//
//  CreateAccountViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 2/1/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum CreateACEvent{
    case onCreateAccount
    case onTermsOfUse
    case onIHaveAccount
}
class CreateAccountViewModel: BaseViewModel {
    var event           : PublishSubject<CreateACEvent> = PublishSubject()
    let name            : PublishSubject<String> = PublishSubject()
    let email           : PublishSubject<String> = PublishSubject()
    let pan             : PublishSubject<String> = PublishSubject()
    let password        : PublishSubject<String> = PublishSubject()
    let confirmPassword : PublishSubject<String> = PublishSubject()
    let isEnable        : BehaviorRelay<Bool>   = BehaviorRelay(value: false)
    
    required init() {
        super.init()
        Observable.combineLatest(name,email,pan,password,confirmPassword).subscribe(onNext:{ [weak self] nameText,emailText,panText,passwordText,confirmPasswordText in
            let isValidName     = nameText.isValid(type: .userName)
            let isValidEmail    = emailText.isValid(type: .emailId)
            let isValidPan      = panText.isValid(type: .panNumber)
            let isValidPassword = passwordText.isValid(type: .password)
            let isMatchPassword = passwordText == confirmPasswordText
            
            self?.isEnable.accept(isValidName && isValidEmail && isValidPan && isValidPassword && isMatchPassword)
        }).disposed(by: disposeBag)
    }
    override func controllerType() -> UIViewController.Type {
        return CreateAccountViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    func createAccount(){
        event.onNext(.onCreateAccount)
    }
    func termsOfUse(){
        event.onNext(.onTermsOfUse)
    }
    func iHaveAccount(){
        event.onNext(.onIHaveAccount)
    }
}
