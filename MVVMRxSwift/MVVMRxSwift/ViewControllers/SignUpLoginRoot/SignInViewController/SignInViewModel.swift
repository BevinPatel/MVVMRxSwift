//
//  SignInViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/29/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class SignInViewModel: BaseViewModel {
    
    override func controllerType() -> UIViewController.Type {
        return SignInViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
}
