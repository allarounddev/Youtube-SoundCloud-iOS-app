//
//  RecentUsersDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class RecentStreamsDataSource: UserStatisticsDataSource {
    var streams: [Stream] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stream = streams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentStreamCell", for: indexPath) as! RecentStreamCell
        cell.update(stream)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let delegate = streamSelectedDelegate {
            delegate.streamDidSelected(streams[indexPath.row])
        }
    }
    
    func recentSuccess(_ streams: [Stream]) {
        if let pullToRefreshView = tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
        
        self.streams = streams
        
        tableView.isHidden = self.streams.isEmpty
        let range = NSMakeRange(0, tableView.numberOfSections)
        let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
        tableView.reloadSections(indexSet, with: UITableView.RowAnimation.automatic)
    }

    func recentaFailure(_ error: NSError) {
        if let pullToRefreshView = tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
    }
    
    override func reload() {
        StreamConnector().recent(userId, success: recentSuccess, failure: recentaFailure)
    }
    
    override func fetchMore() {        
    }
    
    override func clean() {
        streams = []
        tableView.reloadData()
    }
}
