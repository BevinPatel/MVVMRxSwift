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
    override func setUI<T>(viewModel: T) where T : GetStartedViewModel {
        super.setUI(viewModel: viewModel)
    }
    override func setEventBinding<T>(viewModel: T) where T : GetStartedViewModel {
        super.setEventBinding(viewModel: viewModel)
        self.getStartedButton.rx.tap.bind(onNext : viewModel.getStarted).disposed(by: disposeBag)
    }
    override func setDataBinding<T>(viewModel: T) where T : GetStartedViewModel {
        super.setDataBinding(viewModel: viewModel)
    }
}
