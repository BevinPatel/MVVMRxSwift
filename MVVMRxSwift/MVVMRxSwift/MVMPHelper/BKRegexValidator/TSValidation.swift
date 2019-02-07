
//
//  TSValidation.swift
//  RegularExpressionSWT
//
//  Created by Bevin on 09/07/15.
//  Copyright (c) 2015 tatvasoft. All rights reserved.
//

import Foundation
import UIKit

enum BKRegex : NSString{
    case userName       = "^[a-zA-Z0-9]{4,}$"
    case password       = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
    case zipCode        = "^\\d.{4,10}$"
    case panNumber      = "^\\d.{9,9}$"
    case phoneNumber    = "^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$"
    case webSite        = "^(0{0}|((https?://)?([a-z0-9]+([\\-_\\.][a-z0-9]+)*)\\.[a-z]{1,12})\\S*)$"
    case emailId        = "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$"
    
    func isValid(string : String?) -> Bool{
        let rex : NSRegularExpression = NSRegularExpression.regularExpresionForPattern(self.rawValue)
        return rex.checkIsItValid(string as NSString?)
    }
}
extension NSRegularExpression {
    func checkIsItValid(_ stringToCheck : NSString?) -> Bool {
        if let stringToCheck = stringToCheck{
            let match =  self.firstMatch(in: stringToCheck as String, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, stringToCheck.length))
            return (match != nil)
        }
        else{
            return false
        }
    }
    class func regularExpresionForPattern(_ pattrn : NSString)->NSRegularExpression{
        let regularExp : NSRegularExpression = try! NSRegularExpression(pattern: pattrn as String, options: NSRegularExpression.Options.caseInsensitive);
        return regularExp;
    }
}
extension String{
    func isValid(type : BKRegex) -> Bool{
        return type.isValid(string: self)
    }
}
