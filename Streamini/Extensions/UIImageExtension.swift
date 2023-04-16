//
//  UIImageExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 20/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

extension UIImage {
    
    func cropCenterSquare() -> UIImage {
        let originalWidth  = Float(self.size.width * self.scale)
        let originalHeight = Float(self.size.height * self.scale)
        let edge = fminf(originalWidth, originalHeight)
        let posX = (originalWidth - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        var cropSquare: CGRect
        if(self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.right) {
            cropSquare = CGRect(x: CGFloat(posY), y: CGFloat(posX), width: CGFloat(edge), height: CGFloat(edge))
            
        } else {
            cropSquare = CGRect(x: CGFloat(posX), y: CGFloat(posY), width: CGFloat(edge), height: CGFloat(edge))
        }
        
        let imageRef = self.cgImage!.cropping(to: cropSquare);
        let cropped = UIImage(cgImage: imageRef!, scale: 1.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    func imageScaledToSize(_ newSize: CGSize, inRect rect:CGRect) -> UIImage {
        let scale = UIScreen.main.scale
        
        if scale == 2.0 || scale == 3.0 {
            UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
        } else {
            UIGraphicsBeginImageContext(newSize)
        }
        
        //Draw image in provided rect
        self.draw(in: rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageScaledToFitToSize(_ newSize: CGSize) -> UIImage {
        if self.size.width < newSize.width && self.size.height < newSize.height {
            return self.copy() as! UIImage
        }
        
        let widthScale: CGFloat = newSize.width/self.size.width;
        let heightScale: CGFloat = newSize.height/self.size.height;
        
        let scaleFactor: CGFloat
        
        //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
        widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
        let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor);
        
        return imageScaledToSize(scaledSize, inRect: CGRect(x: 0.0, y: 0.0, width: scaledSize.width, height: scaledSize.height))
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func fixOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity;
        
        switch self.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        default: ()
        }
        
        switch self.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
        default: ()
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        
        ctx!.concatenate(transform)
        
        switch self.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            // Grr...
            ctx!.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage();
        return UIImage(cgImage: cgimg!)
    }
}
