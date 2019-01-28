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
    var viewModel : BaseViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.setEventBinding()
        self.setDataBinding()
    }
    func myViewModel<T:BaseViewModel>(type : T.Type)->T{
        return viewModel as! T
    }
    // Will called after viewdidload of superclass. We will do UI related code in this override function
    func setUI(){
    }
    // Will called after setUI of self. We will do event binding in this override function
    func setEventBinding(){
    }
    // Will called after setEventBinding of self. We will do data binding in this override function
    func setDataBinding(){
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
