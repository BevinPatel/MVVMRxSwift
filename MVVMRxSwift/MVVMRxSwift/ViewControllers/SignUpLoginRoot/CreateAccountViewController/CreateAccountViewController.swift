//
//  CreateAccountViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 2/1/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class CreateAccountViewController: BaseViewController {
    @IBOutlet var nameTextField             : UITextField!
    @IBOutlet var emailTextField            : UITextField!
    @IBOutlet var panTextField              : UITextField!
    @IBOutlet var passwordTextField         : UITextField!
    @IBOutlet var confirmPasswordTextField  : UITextField!
    
    @IBOutlet var createAccountButton       : UIButton!
    @IBOutlet var termsOfUseButton          : UIButton!
    @IBOutlet var iHaveAcButton             : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI<T>(viewModel: T) where T : CreateAccountViewModel {
        super.setUI(viewModel: viewModel)
    }
    override func setEventBinding<T>(viewModel: T) where T : CreateAccountViewModel {
        super.setEventBinding(viewModel: viewModel)
        
        nameTextField.rx.text.orEmpty.bind(to:viewModel.name).disposed(by: disposeBag)
        emailTextField.rx.text.orEmpty.bind(to:viewModel.email).disposed(by: disposeBag)
        panTextField.rx.text.orEmpty.bind(to:viewModel.pan).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to:viewModel.password).disposed(by: disposeBag)
        confirmPasswordTextField.rx.text.orEmpty.bind(to:viewModel.confirmPassword).disposed(by: disposeBag)
        
        createAccountButton.rx.tap.bind(onNext:viewModel.createAccount).disposed(by: disposeBag)
        termsOfUseButton.rx.tap.bind(onNext:viewModel.termsOfUse).disposed(by: disposeBag)
        iHaveAcButton.rx.tap.bind(onNext:viewModel.iHaveAccount).disposed(by: disposeBag)
        
        viewModel.isEnable.bind(to: createAccountButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isEnable.subscribe(onNext: {[weak self] value  in
            self?.createAccountButton.backgroundColor = value ? AppColor.HEX_E91D29.color : AppColor.HEX_969694.color
        }).disposed(by: disposeBag)
    }
    override func setDataBinding<T>(viewModel: T) where T : CreateAccountViewModel {
        super.setDataBinding(viewModel: viewModel)
    }
}
