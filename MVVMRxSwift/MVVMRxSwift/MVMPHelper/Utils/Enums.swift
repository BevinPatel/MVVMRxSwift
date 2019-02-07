//
//  Enums.swift
//  MVVMRxSwift
//
//  Created by MAC193 on 2/7/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

enum AppColor : String{
    case HEX_E91D29 = "E91D29"
    case HEX_969694 = "969694"
    
    var color : UIColor?{
        return UIColor(named: self.rawValue, in: Bundle.main, compatibleWith: nil)
    }
}
