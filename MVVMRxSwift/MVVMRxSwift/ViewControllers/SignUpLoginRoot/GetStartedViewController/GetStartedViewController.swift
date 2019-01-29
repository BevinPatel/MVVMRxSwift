//
//  GetStartedViewController.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 1/28/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

class GetStartedViewController: BaseViewController {    
    @IBOutlet var getStartedButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func setUI() {
        super.setUI()
    }
    override func setEventBinding() {
        super.setEventBinding()
        self.getStartedButton.rx.tap.bind(onNext : self.viewModel(type: GetStartedViewModel.self).getStarted).disposed(by: disposeBag)
    }
    override func setDataBinding() {
        super.setDataBinding()
    }
}
