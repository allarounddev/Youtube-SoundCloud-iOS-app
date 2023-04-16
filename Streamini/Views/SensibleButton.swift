//
//  SensibleButton.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class SensibleButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 20.0;
        let area = self.bounds.insetBy(dx: -margin, dy: -margin);
        return area.contains(point);
    }

}
