//
//  Extension.swift
//  MVVMDemoProject
//
//  Created by MAC193 on 1/22/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

extension UIStoryboard{
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    public func getNavigation<M : UINavigationController>(_ identifier : M.Type) -> M?{
        if let controller = instantiateViewController(withIdentifier: String(describing: identifier)) as? M{
            return controller
        }
        else{
            return nil
        }
    }
    public func getController<M : UIViewController>(_ identifier : M.Type) -> M?{
        if let controller = instantiateViewController(withIdentifier: String(describing: identifier)) as? M{
            return controller
        }
        else{
            return nil
        }
    }
}
