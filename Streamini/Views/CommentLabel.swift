//
//  CommentLabel.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CommentLabel: UILabel {
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = edgeInsets.apply(bounds)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return edgeInsets.inverse.apply(rect)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: edgeInsets.apply(rect))
    }
}
