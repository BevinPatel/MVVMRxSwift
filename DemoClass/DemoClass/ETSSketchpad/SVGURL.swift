//
//  SVGURL.swift
//  DemoClass
//
//  Created by MAC193 on 1/21/20.
//  Copyright © 2020 MAC193. All rights reserved.
//

import UIKit

class SVGURL : NSObject, Codable
{
    let url : URL
    
    init(url : URL)
    {
        self.url = url
    }
    
    public required init(_ svgUrl: SVGURL) {
      self.url = svgUrl.url
      super.init()
    }
}


extension SVGURL : NSItemProviderWriting
{
    static var writableTypeIdentifiersForItemProvider: [String]
    {
        return ["SVGURL"]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
    {
        do
        {
            let archiver = NSKeyedArchiver(requiringSecureCoding: false)
            try archiver.encodeEncodable(self, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
            let data = archiver.encodedData
            completionHandler(data, nil)
        }
        catch
        {
            completionHandler(nil, nil)
        }
        return nil
    }
}


extension SVGURL : NSItemProviderReading
{
    static var readableTypeIdentifiersForItemProvider: [String]
    {
        return ["SVGURL"]
    }
    
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
    {
        do
        {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom : data)
            guard let svgUrl = try unarchiver.decodeTopLevelDecodable(SVGURL.self, forKey: NSKeyedArchiveRootObjectKey)  else
            {
                throw EncodingError.invalidData
            }
            return self.init(svgUrl)
        }
        catch
        {
            throw EncodingError.invalidData
        }
    }
}

enum EncodingError: Error
{
    case invalidData
}
