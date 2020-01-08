//
//  AppDelegate.swift
//  DemoClass
//
//  Created by MAC193 on 6/6/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var oriantaionLock : UIInterfaceOrientationMask = .all
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.oriantaionLock;
    }
}
extension UIView
{

    func addShadow(shadowColor : UIColor = UIColor.black)
    {
        layer.shadowRadius  = 3.0
        layer.shadowColor   = shadowColor.cgColor
        layer.shadowOffset  = CGSize(width : 0.0, height : 0.8)
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }

    @IBInspectable
    var radious : CGFloat{
        get {
            return 0
        }

        set {
            if (newValue > 0)
            {
                self.layer.cornerRadius = newValue
                self.layer.masksToBounds = true
            }
        }
    }

    @IBInspectable
    var borderwidth : CGFloat{
        get {
            return 0
        }

        set {
            if (newValue > 0)
            {
                self.layer.borderWidth = newValue
            }
        }
    }

    @IBInspectable
    var bordercolor : UIColor{
        get {
            return .clear
        }

        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
}
extension UIImage
{
    var base64String : String?
    {
        if let pngData = self.pngData()
        {
            let base64String = pngData.base64EncodedString(options : Data.Base64EncodingOptions.lineLength64Characters)
            return "data:image/jpg;base64," + base64String
        }
        else
        {
            return nil
        }
    }
    
    
    // MARK: - UIImage+Resize
    func compressedImageData(_ expectedSizeInMb : Int) -> Data?
    {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress : Bool = true
        var imageData : Data?
        var compressingValue : CGFloat = 1.0
        while (needCompress && compressingValue > 0.0)
        {
            if let data:Data = self.jpegData(compressionQuality: compressingValue)
            {
                if (data.count < sizeInBytes)
                {
                    needCompress = false
                    imageData = data
                }
                else
                {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imageData
        {
            return data
        }
        return nil
    }
}
extension String
{
    var stringByDecodingHTMLEntities : String
    {
        let characterEntities : [Substring : Character] = [
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&apos;"    : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
            "&nbsp;"    : "\u{00a0}",
            "&diams;"   : "♦",
        ]
        
        func decodeNumeric(_ string : Substring, base : Int) -> Character?
        {
            guard let code = UInt32(string, radix : base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        
        func decode(_ entity : Substring) -> Character?
        {
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X")
            {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            }
            else if entity.hasPrefix("&#")
            {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            }
            else
            {
                return characterEntities[entity]
            }
        }

        
        var result = ""
        var position = startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of : "&")
        {
            result.append(contentsOf : self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of : ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound

            if let decoded = decode(entity)
            {
                // Replace by decoded character:
                result.append(decoded)
            }
            else
            {
                // Invalid entity, copy verbatim:
                result.append(contentsOf : entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf : self[position...])
        return result
    }
    
    
    func getHTMLAttributedString(fontName : String, pointSize : CGFloat) -> NSAttributedString?
    {
        let regexForHtmlTag = "\\<[^\\>]*\\>"
        if (self.matches(regexForHtmlTag))
        {
            let modifiedFontText = NSString(format : "<span style=\"font-family: \(fontName); font-size: \(pointSize)\">%@</span>" as NSString, self)
            
            let attrStr = try! NSAttributedString(
                data : modifiedFontText.data(using : String.Encoding.unicode.rawValue, allowLossyConversion : true)!,
                options : [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding : String.Encoding.utf8.rawValue],
                documentAttributes : nil)
            
            return attrStr
        }
        else
        {
            return nil
        }
    }
    
    
    var trimmed : String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    
    var length : Int
    {
        return self.count
    }

    
    var trimmedLength : Int
    {
        return self.trimmed.length
    }
    
    
    func deletingPrefix(_ prefix : String) -> String
    {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    
    var base64ToImage : UIImage?
    {
        var base64String = self.replacingOccurrences(of : "data:image/jpg;base64,", with : "")
        base64String = base64String.replacingOccurrences(of : "data:image/png;base64,", with : "")
        if let base64Data = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        {
            return UIImage(data: base64Data)
        }
        else
        {
            return nil
        }
    }
    
    
    func jsonStringArray() -> [String]?
    {
        do
        {
            if let jsonData = self.data(using: .utf8)
            {
                return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String]
            }
            else
            {
                return nil
            }
        }
        catch
        {
            return nil
        }
    }
    
    
    func jsonObjectDictionaryArray() -> [[String : Any]]?
    {
        do
        {
            if let jsonData = self.data(using: .utf8)
            {
                return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String:Any]]
            }
            else
            {
                return nil
            }
        }
        catch
        {
            return nil
        }
    }
    
    
    func jsonObjectDictionary() -> [String : Any]?
    {
        do
        {
            if let jsonData = self.data(using: .utf8)
            {
                return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any]
            }
            else
            {
                return nil
            }
        }
        catch
        {
            return nil
        }
    }
    
    
    func matches(_ regex : String) -> Bool
    {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    
    func instanceTitleComponent() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "\\{\\[(.*?)\\)\\}", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with : $0.range)
            }
        }
        return []
    }
    
    
    func parseComputedFieldNames() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "\\((.*?)\\)", options: .caseInsensitive)
        {
            let string = self as NSString
            
            let matchedStrings = regex.matches(in : self, options : [], range : NSRange(location : 0, length : string.length)).map {
                string.substring(with : $0.range)
            }
            return matchedStrings.map { $0.replacingOccurrences(of: "(contact:", with: "").replacingOccurrences(of: ")", with: "") }
        }
        return []
    }
    
    
    func parseComputedFieldValues() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "[\\+\\-][\\s]?[0-9]+$", options: .caseInsensitive)
        {
            let string = self as NSString
            
            let matchedStrings = regex.matches(in : self, options : [], range : NSRange(location : 0, length : string.length)).map {
                string.substring(with : $0.range).replacingOccurrences(of : " ", with : "")
            }
            return matchedStrings
        }
        return []
    }
}
