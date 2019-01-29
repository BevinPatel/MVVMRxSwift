//
//  GetStartedViewModel.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum GetStarted {
    case onGetStart
}
class GetStartedViewModel : BaseViewModel{
    let events = PublishSubject<GetStarted>()
    
    override func controllerType() -> UIViewController.Type {
        return GetStartedViewController.self
    }
    override func controllerStoryBoard() -> UIStoryboard {
        return UIStoryboard.main
    }
    func getStarted(){
        events.onNext(.onGetStart)
    }
}
