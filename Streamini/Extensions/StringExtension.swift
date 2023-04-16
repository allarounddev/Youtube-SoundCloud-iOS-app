//
//  StringExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension String {
    func handleEmoji() -> String {
        let emojies =
        [
            ":)": "\u{1F60A}", ":-)": "\u{1F60A}",
            ":(": "\u{1F61E}", ":-(": "\u{1F61E}",
            ";)": "\u{1F609}", ";-)": "\u{1F609}",
            ":D": "\u{1F603}", ":-D": "\u{1F603}", ":d": "\u{1F603}", ":-d": "\u{1F603}",
            ":P": "\u{1F60B}", ":-P": "\u{1F60B}", ":p": "\u{1F60B}", ":-p": "\u{1F60B}"
        ]
        
        var string = self
        for e in emojies {
            string = string.replacingOccurrences(of: e.0, with: e.1)
        }
        
        return string
    }
}

// MARK: - HTTPParametersConvertible
extension String: HTTPParametersConvertible {
    var queryStringValue: String {
        return self
    }
    
    var formDataValue: Data {
        return data(using: .utf8) ?? Data()
    }
}

// MARK: - Query dictionary
extension String {
    var queryDictionary: [String: String] {
        let parameters = components(separatedBy: "&")
        var dictionary = [String: String]()
        for parameter in parameters {
            let keyValue = parameter.components(separatedBy: "=")
            if keyValue.count == 2,
                let key = keyValue[0].removingPercentEncoding,
                let value = keyValue[1].removingPercentEncoding {
                dictionary[key] = value
            }
        }
        return dictionary
    }
}

extension String {
    
    func getYoutubeFormattedDuration() -> String {
        
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
        
    }
    
}
