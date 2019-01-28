//
//  SignUpLoginNavigationModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import UIKit

class SignUpLoginNavigationModel : BaseNavigationModel{
    override func controllerType() -> UINavigationController.Type {
        return SignUpLoginNavigationController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    override func rootModel() -> BaseViewModel {
        return SignUpLoginViewModel();
    }
}
