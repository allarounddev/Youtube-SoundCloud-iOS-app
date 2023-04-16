//
//  BaseNavigationController.swift
//  Golfstream
//
//  Created by Vasiliy Evreinov on 23.09.15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare background image
        
        let backgroundImage = UIImage.imageWithColor(UIColor.whiteColor(), size: CGSize(width: 1, height: 1))
        
        // Prepare hairline image
        
        let shadowColor = UIColor.blackColor()
        let shadowHeight = 1 / UIScreen.mainScreen().scale
        let shadowSize = CGSize(width: 1, height: shadowHeight)
        let shadowImage = UIImage.imageWithColor(shadowColor, size: shadowSize)
        
        // Style navigation bars
        
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.setBackgroundImage(backgroundImage, forBarMetrics: .Default)
        navigationBarAppearance.shadowImage = shadowImage
    }
    
}