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
}
