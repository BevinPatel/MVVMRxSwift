//
//  ForgotPasswordViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 2/1/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    @IBOutlet var emailTextField            : UITextField!
    @IBOutlet var panTextField              : UITextField!
    @IBOutlet var forgotPasswordButton      : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI<T>(viewModel: T) where T : BaseViewModel {
        super.setUI(viewModel: viewModel)
    }
    override func setEventBinding<T>(viewModel: T) where T : BaseViewModel {
        super.setEventBinding(viewModel: viewModel)
    }
    override func setDataBinding<T>(viewModel: T) where T : BaseViewModel {
        super.setDataBinding(viewModel: viewModel)
    }
}
