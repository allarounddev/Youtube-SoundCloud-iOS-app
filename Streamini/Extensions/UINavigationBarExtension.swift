//
//  UINavigationBarExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/09/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    class func setCustomAppereance() {
        UINavigationBar.appearance().tintColor = UIColor.black
//        UINavigationBar.appearance().bar
//        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav-background"), for: UIBarMetrics.default)
//        UINavigationBar.appearance().shadowImage = UIImage(named: "nav-border")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Ultra", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.black]
    }
    
    class func resetCustomAppereance() {
        UINavigationBar.appearance().tintColor = nil
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        UINavigationBar.appearance().shadowImage = nil
//        UINavigationBar.appearance().titleTextAttributes = nil
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Ultra", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.black]

    }
}
