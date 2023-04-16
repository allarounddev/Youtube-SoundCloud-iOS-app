//
//  Config.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class Config: NSObject {
    fileprivate var config: Config?
    fileprivate var data: NSDictionary?
    
    // MARK: - Init
    
    class var shared : Config {
        struct Static {
            static let instance : Config = Config()
        }
        return Static.instance
    }
    
    override init() {
        super.init()

        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            data = NSDictionary(contentsOfFile: path)
        } else {
            print("Error: Config.plist is missing.")
        }
    }
    
    func api() -> (String) {
        let apiData: NSDictionary = data!["API"] as! NSDictionary
        let host: String = apiData["host"] as! String
        return (host)
    }
    
    func site() -> (String) {
        let apiData: NSDictionary = data!["API"] as! NSDictionary
        let site: String = apiData["site"] as! String
        return (site)
    }
    
    func wowza() -> (host: String, port: String, application: String, username: String, password: String) {
        let wowzaData: NSDictionary = data!["Wowza"] as! NSDictionary
        let host: String = wowzaData["host"] as! String
        let port: String = wowzaData["port"] as! String
        let application: String = wowzaData["application"] as! String
        let username: String = wowzaData["username"] as! String
        let password: String = wowzaData["password"] as! String
        
        return (host, port, application, username, password)
    }
    
    func amazon() -> (accessKeyId: String, secretAccessKey: String, region: String, streamBucket: String, imagesBucket: String) {
        let amazonData: NSDictionary = data!["Amazon"] as! NSDictionary
        let accessKeyId: String = (amazonData["accessKeyId"] as! String).trimmingCharacters(in: CharacterSet.newlines)
        let secretAccessKey: String = (amazonData["secretAccessKey"] as! String).trimmingCharacters(in: CharacterSet.newlines)
        let region: String = (amazonData["region"] as! String).trimmingCharacters(in: CharacterSet.newlines)
        let streamBucket: String = (amazonData["streamBucket"] as! String).trimmingCharacters(in: CharacterSet.newlines)
        let imagesBucket: String = (amazonData["imagesBucket"] as! String).trimmingCharacters(in: CharacterSet.newlines)
        
        return (accessKeyId, secretAccessKey, region, streamBucket, imagesBucket)
    }
    
    func twitter() -> (consumerKey: String, consumerSecret: String, tweetURL: String) {
        let twitterData: NSDictionary = data!["Twitter"] as! NSDictionary
        let consumerKey: String = twitterData["consumerKey"] as! String
        let consumerSecret: String = twitterData["consumerSecret"] as! String
        let tweetURL: String = twitterData["tweetURL"] as! String
        
        return (consumerKey, consumerSecret, tweetURL)
    }
    
    func pubNub() -> (publishKey: String, subscribeKey: String) {
        let pubNubData: NSDictionary = data!["PubNub"] as! NSDictionary
        let publishKey: String = pubNubData["publishKey"] as! String
        let subscribeKey: String = pubNubData["subscribeKey"] as! String
        
        return (publishKey, subscribeKey)
    }
    
    func feedback() -> String {
        let feedbackData: NSDictionary = data!["Feedback"] as! NSDictionary
        let email: String = feedbackData["email"] as! String
        return email
    }
    
    func legal() -> (termsOfService: String, privacyPolicy: String) {
        let legalData: NSDictionary = data!["Legal"] as! NSDictionary
        let termsOfService: String  = legalData["termsOfService"] as! String
        let privacyPolicy: String   = legalData["privacyPolicy"] as! String
        return (termsOfService, privacyPolicy)
    }
    
    func payment() -> (production: String, sandbox: String) {
        let setData: NSDictionary = data!["Payment"] as! NSDictionary
        let production: String = setData["production"] as! String
        let sandbox: String = setData["sandbox"] as! String
        
        return (production, sandbox)
    }
}
