//
//  UIEdgeInsets.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

extension UIEdgeInsets {    
    var inverse : UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    func apply(_ rect: CGRect) -> CGRect {
        return rect.inset(by: self)
    }
}
