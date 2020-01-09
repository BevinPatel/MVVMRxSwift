//
//  AppDelegate.swift
//  DemoClass
//
//  Created by MAC193 on 6/6/19.
//  Copyright © 2019 MAC193. All rights reserved.
//

import UIKit
typealias Text  = ETSText

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
extension Bundle
{
    static func loadNib<T:UIViewController>(_ identifier : T.Type) -> T?
    {
        return T.init(nibName: String(describing: identifier), bundle: nil)
    }
}
struct ETSText
{
    static let label        :   ETSLabel        =   ETSLabel()
    static let message      :   ETSMessage      =   ETSMessage()
    
    //Localize all these texts of Label for support multilanguage
    struct ETSLabel
    {
        let no = "No"
        let noDataFound = "No data found"
        let ok = "OK"
        let confirm = "Confirm"
        let cancel = "Cancel"
        let yes = "Yes"
        let savedDraft = "Saved Draft"
        let newForm = "New Form"
        let viewList = "View List"
        let categoryTab = "Categories"
        let savedDraftTab = "Saved Drafts"
        let submittedTab = "Submitted"
        let saveAndExit = "Save and exit"
        let exitWithoutSaving = "Exit without saving"
        let save = "Save"
        let delete = "Delete"
        let done = "Done"
        let search = "Search"
        let address = "Address"
        let back = "Back"
        let submit = "Submit"
    }
    
    //Localize all these texts of Message for support multilanguage
    struct ETSMessage
    {
        let noInternet = "Please check your Internet connection"
        let unknownError = "Server is not responding due to some error. Please try later."
        let successful = "Successful"
        let requestSubmitted = "Your form has been submitted succesfully."
        let askingAboutSavePartially = "Are you sure you want to save partially filled form for later use?"
        let askingAboutSubmitForm = "Are you sure you want to submit form?"
        let saveDraftMessage = " The form has been saved. It will be delivered to the server when connectivity is available."
        let allFormsSubmittedToServer = "All your pending  forms has been submitted to the server."
        let askForSavedDraftAndNewForm = "There are already forms waiting in the saved drafts."
        let noDraftInstancesAvailable = "No drafted instances available."
        let noSubmittedInstancesAvailable = "No submitted instances available."
        let noInstancesAvailable = "No instances available."
        let cameraSupport = "Camera is not supported in your device."
        let photoPermission = "Please allow ETS to access your photos."
        let cameraPermission = "Please allow ETS to access your device camera."
    }
}
extension UICollectionView
{
    func register<T: UICollectionViewCell>(_ : T.Type) where T : ReusableView
    {
        register(T.self, forCellWithReuseIdentifier : T.defaultReuseIdentifier)
    }
    
    
    func register<T : UICollectionReusableView>(_ : T.Type, forSupplementaryViewOfKind kind : String) where T : ReusableView
    {
        register(T.self, forSupplementaryViewOfKind : kind, withReuseIdentifier : T.defaultReuseIdentifier)
    }
    
    
    func register<T : UICollectionViewCell>(_ : T.Type) where T : ReusableView, T : NibLoadableView
    {
        let bundle = Bundle(for : T.self)
        let nib = UINib(nibName : T.nibName, bundle : bundle)
        register(nib, forCellWithReuseIdentifier : T.defaultReuseIdentifier)
    }
    
    
    func dequeueReusableCell<T : UICollectionViewCell>(for indexPath : IndexPath) -> T where T : ReusableView
    {
        register(T.self)
        guard let cell = dequeueReusableCell(withReuseIdentifier : T.defaultReuseIdentifier, for : indexPath) as? T else
        {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    
    func dequeueReusableCell<T : UICollectionViewCell>(for indexPath : IndexPath) -> T where T : ReusableView, T : NibLoadableView
    {
        register(T.self)
        guard let cell = dequeueReusableCell(withReuseIdentifier : T.defaultReuseIdentifier, for : indexPath) as? T else
        {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind : String, for indexPath : IndexPath) -> T where T : ReusableView
    {
        register(T.self, forSupplementaryViewOfKind : kind)
        guard let cell = dequeueReusableSupplementaryView(ofKind : kind, withReuseIdentifier : T.defaultReuseIdentifier, for : indexPath) as? T else
        {
            fatalError("Could not dequeue reusable supplementaryView with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}


public protocol ReusableView : class
{
    static var defaultReuseIdentifier : String { get }
}


extension ReusableView where Self : UIView
{
    public static var defaultReuseIdentifier : String
    {
        return String(describing: self)
    }
}


public protocol NibLoadableView : class
{
    static var nibName : String { get }
}


extension NibLoadableView where Self : UIView
{
    static var nibName : String
    {
        return String(describing: self)
    }
}
extension UIColor
{
    struct HexCode
    {
        static let pinTintColor = "#800080" //pink color
    }
    
    struct Form
    {
        static let toolTipTextColor = UIColor.init(hexString : "#212121")
        static let inputFieldBorderColor = UIColor.init(hexString : "#A7A8A9")
        static let draftTagBackgroundColor = UIColor.init(hexString : "#D6A634")
        static let submittedTagBackgroundColor = UIColor.init(hexString : "#4DB941")
        static let disableFieldColor = UIColor.init(hexString : "#E9ECEF")
    }
    
    struct FileIcon
    {
        static let pdfColor = UIColor.init(hexString : "#F13A1D") // red
        static let docColor = UIColor.init(hexString : "#438F30") // dark green
        static let htmColor = UIColor.init(hexString : "#ADE982") // light green
        static let zipColor = UIColor.init(hexString : "#2CC777") // green
        static let rtfColor = UIColor.init(hexString : "#6599A5") // CadetBlue
        static let xlsColor = UIColor.init(hexString : "#581508") // brown
        static let txtColor = UIColor.init(hexString : "#719B35") // olive green
    }
    
    struct Map
    {
        static let pinTintColor = UIColor.init(hexString : HexCode.pinTintColor)
        static let overlayCircleFillColor = UIColor.black.withAlphaComponent(0.5)
        static let overlayPolygonStrokeColor = UIColor.black
        static let overlayPolylineStrokeColor = UIColor.orange
    }

    
    static let rgb = { (red : CGFloat, green : CGFloat, blue : CGFloat, alpha : CGFloat) -> UIColor in
        return UIColor(red:red / 255.0, green:green / 255.0, blue:blue / 255.0, alpha:alpha)
    }

    
    convenience init(hexString : String)
    {
        let hex = hexString.trimmingCharacters(in : CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string : hex).scanHexInt32(&int)
        let a, r, g, b : UInt32
        switch hex.count
        {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
        }
        self.init(red : CGFloat(r) / 255, green : CGFloat(g) / 255, blue : CGFloat(b) / 255, alpha : CGFloat(a) / 255)
    }
    

    static func colorWithRGB(red : CGFloat, green : CGFloat, blue : CGFloat, alpha : CGFloat) -> UIColor
    {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
