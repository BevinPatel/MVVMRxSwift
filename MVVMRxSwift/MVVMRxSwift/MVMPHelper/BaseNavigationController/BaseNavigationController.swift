//
//  BaseNavigationController
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
import RxSwift

class BaseNavigationController: UINavigationController {
    let disposeBag = DisposeBag()
    var viewModel : BaseNavigationModel?
    
    func myViewModel<T:BaseNavigationModel>(_ modelType : T.Type) -> T? {
        return viewModel as? T
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = self.myViewModel(BaseNavigationModel.self);
        model?.navigationActions.subscribe(onNext: { [weak self] action in
            switch action{
            case .set(let viewModels, let animated):
                let controllers = viewModels.compactMap { MVVM.viewController(model: $0)}
                self?.setViewControllers(controllers, animated: animated);
                break
            case .push(let viewModel, let animated):
                guard let controller = MVVM.viewController(model: viewModel)else {return}
                self?.pushViewController(controller, animated: animated);
                break
            case .pop(let animated):
                self?.popViewController(animated: animated);
                break;
            case .present(let viewModel, let animated, let completion):
                guard let controller = MVVM.viewController(model: viewModel)else {return}
                self?.present(controller, animated: animated, completion: completion)
                break;
            case .dismiss(let animated,let completion):
                self?.dismiss(animated: animated, completion: completion)
                break
            }
        }).disposed(by: self.disposeBag)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
