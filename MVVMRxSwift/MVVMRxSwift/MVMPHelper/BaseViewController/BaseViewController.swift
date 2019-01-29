//
//  BaseViewController
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController : UIViewController {
    let disposeBag = DisposeBag()
    var baseViewModel : BaseViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI(viewModel : self.baseViewModel)
        self.setEventBinding(viewModel : self.baseViewModel)
        self.setDataBinding(viewModel : self.baseViewModel)
    }
    func viewModel<T:BaseViewModel>(type : T.Type)->T{
        return baseViewModel as! T
    }
    // Will called after viewdidload of superclass. We will do UI related code in this override function
    func setUI<T:BaseViewModel>(viewModel : T){
    }
    // Will called after setUI of self. We will do event binding in this override function
    func setEventBinding<T:BaseViewModel>(viewModel : T){
    }
    // Will called after setEventBinding of self. We will do data binding in this override function
    func setDataBinding<T:BaseViewModel>(viewModel : T){
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
