//
//  SignInViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/29/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {

    @IBOutlet var emailTextField        : UITextField!
    @IBOutlet var passwordTextField     : UITextField!
    @IBOutlet var signInButton          : UIButton!
    @IBOutlet var forgotPasswordButton  : UIButton!
    @IBOutlet var dontHaveAcButton      : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI<T>(viewModel: T) where T : SignInViewModel {
        super.setUI(viewModel: viewModel)
    }
    override func setEventBinding<T>(viewModel: T) where T : SignInViewModel {
        super.setEventBinding(viewModel: viewModel)
        
        self.emailTextField.rx.text.orEmpty.bind(to:viewModel.email).disposed(by: disposeBag)
        self.passwordTextField.rx.text.orEmpty.bind(to:viewModel.password).disposed(by: disposeBag)
        
        self.signInButton.rx.tap.bind(onNext:(viewModel.signIn)).disposed(by: disposeBag)
        self.forgotPasswordButton.rx.tap.bind(onNext:(viewModel.forgotPassword)).disposed(by: disposeBag)
        self.dontHaveAcButton.rx.tap.bind(onNext:(viewModel.dontHaveAccount)).disposed(by: disposeBag)
        
        viewModel.isEnable.bind(to: signInButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isEnable.subscribe(onNext: {[weak self] value  in
            self?.signInButton.backgroundColor = value ? UIColor(red: 233.0/255.0, green: 29.0/255.0, blue: 41.0/255.0, alpha: 1.0) : UIColor.gray
        }).disposed(by: disposeBag)
    }
    override func setDataBinding<T>(viewModel: T) where T : SignInViewModel {
        super.setDataBinding(viewModel: viewModel)
    }
}
