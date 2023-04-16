//
//  FollowingDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class FriendsDataSource: UserStatisticsDataSource {
    override func reload() {
        UserConnector().friends(statisticsDataSuccess, failure: statisticsDataFailure)
    }
    
    override func fetchMore() {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        
        if let delegate = userSelectedDelegate {
            delegate.userDidSelected(user)
        }
    }
}
