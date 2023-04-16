//
//  MyStreamsDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 24/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class MyStreamsDataSource: RecentStreamsDataSource {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentStreamCell", for: indexPath) as! RecentStreamCell
        let stream = streams[indexPath.row]
        cell.updateMyStream(stream)
        
        return cell
    }
    
    func myRecentSuccess(_ streams: [Stream]) {
        super.recentSuccess( streams.map({ $0.user = UserContainer.shared.logged(); return $0 }) )
    }
        
    override func reload() {
        StreamConnector().my(myRecentSuccess, failure: recentaFailure)
    }
    
    override func fetchMore() {
    }
}
