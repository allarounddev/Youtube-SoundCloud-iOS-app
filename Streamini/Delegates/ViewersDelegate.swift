//
//  ViewersDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/09/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

enum PullingDirection {
    case left, stable
}

protocol CollectionViewPullDelegate: class {
    func collectionViewDidBeginPullingLeft(_ collectionView: UIScrollView, offset: CGFloat)
}

class ViewersDelegate: NSObject, UICollectionViewDelegate {
    let pullThreshold: CGFloat = 10.0
    var pulling = false
    var pullingDirection: PullingDirection = .stable
    weak var pullDelegate: CollectionViewPullDelegate?
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x;
        
        if offset > max(0, abs(scrollView.contentSize.width - scrollView.frame.size.width + pullThreshold)) && !pulling {
            //pulling from right to left
            if let delegate = pullDelegate {
                delegate.collectionViewDidBeginPullingLeft(scrollView, offset: offset)
            }

            pullingDirection = PullingDirection.left;
            pulling = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollingEnded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollingEnded()
    }
    
    func scrollingEnded() {
        pulling = false
    }
    
}
