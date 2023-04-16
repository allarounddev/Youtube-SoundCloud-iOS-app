//
//  CALayerExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

extension CALayer {

    func addDarkGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds;
        gradient.colors = [ UIColor(white: 0.0, alpha: 0.75).cgColor, UIColor(white: 0.0, alpha: 0.25).cgColor ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.addSublayer(gradient)
    }
    
    func setBorderUIColor(_ color: UIColor) {
        self.borderColor = color.cgColor
    }
    
    func borderUIColor() -> UIColor {
        return UIColor(cgColor: self.borderColor!)
    }    
}
