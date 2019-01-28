//
//  SignUpLoginViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class SignUpLoginViewController: BaseViewController {
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var newUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI() {
        super.setUI()
    }
    override func setEventBinding() {
        super.setEventBinding()
        self.loginButton.rx.tap.bind(onNext : self.myViewModel(type: SignUpLoginViewModel.self).onTapLogin).disposed(by: disposeBag)
        self.newUserButton.rx.tap.bind(onNext : self.myViewModel(type: SignUpLoginViewModel.self).onTapSignUp).disposed(by: disposeBag)
    }
    override func setDataBinding() {
        super.setDataBinding()
    }
}
