//
//  UIColorExtension.swift
// Streamini
//
//  Created by Vasily Evreinov on 21/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension UIColor {
    
    // Color for highlighted state of buttons in tabbar
    class func buttonHighlightedColor() -> UIColor {
//        return UIColor(red: 156.0/255.0, green: 65.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)

    }
    
    // Color for normal state of buttons in tabbar
    class func buttonNormalColor() -> UIColor {
        return UIColor(red: 125.0/255.0, green: 169.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    }
    
    // Dark green, color of UINavigation bar
    class func navigationBarColor() -> UIColor {
        return UIColor(red: 14.0/255.0, green: 102.0/255.0, blue: 129.0/255.0, alpha: 1.0)
    }
    
}
