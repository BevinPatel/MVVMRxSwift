//
//  SignUpLoginViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import UIKit

class SignUpLoginViewModel : BaseViewModel{    
    override func controllerType() -> UIViewController.Type {
        return SignUpLoginViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    func onTapLogin(){
        
    }
    func onTapSignUp(){
        
    }
}
