//
//  StreamDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol StreamDataSourceDelegate {
    func goStream()
    func showInfo()
}

var GStream: Stream?
var isPlaylist = false

class StreamDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var lives: [Stream]     = []
    var recent: [Stream]    = []
    var delegate : StreamDataSourceDelegate? = nil
    var identifier = ""

    var userSelectedDelegate: UserSelecting?
    var streamSelectedDelegate: StreamSelecting?

    fileprivate let l = UILabel()
    
    override init() {
        super.init()

        l.font = UIFont(name: "HelveticNeue-Light", size: 17.0)
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? lives.count : recent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        tableView.register(UINib.init(nibName: "MusicStreamCell", bundle: nil), forCellReuseIdentifier: "MusicStreamCell")
//        tableView.register(UINib.init(nibName: "PlayListCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")

        var stream: Stream?
        if indexPath.section == 0 {
            identifier = "LiveStreamCell"
            stream = lives[indexPath.row]

        } else if indexPath.section == 1 {
            identifier = "RecentStreamCell"

//            if recent[indexPath.row].videotype == "scmusic" {
//                identifier = "MusicStreamCell"
//            }
//            if (recent[indexPath.row].isplaylist) {
//                identifier = "PlayListCell"
//            }

            stream = recent[indexPath.row]

        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StreamCell
        
        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        cell.update(stream!)

        print(stream?.isplaylist)
        if indexPath.section == 0 {
//            cell.separatorInset = UIEdgeInsetsMake(10, 10, 10, 10)
        }
        
        cell.onButtonTapped = {
            print("tappedadsfasdfasdfasdfasdf")
            GStream = self.recent[indexPath.row]
            self.delegate?.showInfo()
        }

        return cell

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || recent.isEmpty {
            return nil
        }
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 35))
        header.backgroundColor = UIColor.clear
        
        let label = UILabel()
        label.text = NSLocalizedString("recent_streams", comment: "")
        label.font = UIFont(name: "HelveticaNeue", size: 17.0)
        label.frame = CGRect(x: 14, y: 0, width: tableView.bounds.size.width - 14.0, height: 35)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.clear
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0 || recent.isEmpty) ? 0.0 : 35.0
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180.0;
        } else {
            l.text = recent[indexPath.row].title
//            let expectedSize = l.sizeThatFits(CGSize(width: tableView.bounds.size.width - 68.0, height: 1000))
            if identifier == "MusicStreamCell" {
                return 500.0
            } else if identifier == "RecentStreamCell" {
                return 500.0
            } else {
//                return expectedSize.height + 220.0
                return 220.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(identifier)
        if recent[indexPath.row].videotype == "scmusic" {
            GStream = recent[indexPath.row]
            delegate?.goStream()
        } else if (recent[indexPath.row].isplaylist) && (recent[indexPath.row].videotype == "youtube"){
            GStream = recent[indexPath.row]
            delegate?.goStream()
        }

    }
}
