//
//  EpisodesDataSource.swift
//  Streamini
//
//  Created by developer on 12/2/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation

class EpisodesDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var streamSelectedDelegate: StreamSelecting?
    var userSelectedDelegate: UserSelecting?
    var streams: [Stream] = []
    var delegate : StreamDataSourceDelegate? = nil
    var profileDelegate: ProfileDelegate?

    //    var collectionView: UICollectionView
    
    fileprivate let l = UILabel()
    
    override init() {
        super.init()
        
        l.font = UIFont(name: "HelveticNeue-Light", size: 17.0)
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var stream: Stream?
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodesCollectionCell", for: indexPath) as! EpisodesCollectionCell
        
        stream = streams[indexPath.row]
        
        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        if let delegate = self.streamSelectedDelegate {
            cell.streamSelectedDelegate = delegate
        }

        cell.updateMyStream(stream!)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        if let delegate = streamSelectedDelegate {
            delegate.streamDidSelected(streams[indexPath.row])
        }
        
        if streams[indexPath.row].videotype == "scmusic" {
            GStream = streams[indexPath.row]
            delegate?.goStream()
        } else if streams[indexPath.row].videotype == "youtube" {
            GStream = streams[indexPath.row]
            delegate?.goStream()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    }
    
    
}
