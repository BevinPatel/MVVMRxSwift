//
//  HomeScreenViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 2/1/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class HomeScreenViewModel: BaseViewModel {
    override func controllerType() -> UIViewController.Type {
        return HomeScreenViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
}
