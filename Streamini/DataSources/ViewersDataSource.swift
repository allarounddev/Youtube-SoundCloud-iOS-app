//
//  ViewersDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 21/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class ViewersDataSource: NSObject, UICollectionViewDataSource {
    var viewers: [User] = []
    var userSelectedDelegate: UserSelecting?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = viewers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "viewersCell", for: indexPath) as! ViewersCollectionViewCell
        
        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        
        cell.update(user)
        return cell
    }
}
