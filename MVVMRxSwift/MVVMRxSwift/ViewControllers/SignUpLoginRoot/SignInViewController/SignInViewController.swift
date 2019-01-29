//
//  SignInViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/29/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI<T>(viewModel: T) where T : SignInViewModel {
        super.setUI(viewModel: viewModel)
    }
    override func setEventBinding<T>(viewModel: T) where T : SignInViewModel {
        super.setEventBinding(viewModel: viewModel)
    }
    override func setDataBinding<T>(viewModel: T) where T : SignInViewModel {
        super.setDataBinding(viewModel: viewModel)
    }
}
