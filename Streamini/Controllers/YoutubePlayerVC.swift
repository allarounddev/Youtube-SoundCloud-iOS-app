//
//  YoutubePlayerVC.swift
//  Streamini
//
//  Created by developer on 8/14/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit

class YoutubePlayerVC: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    var videoID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let videoId = self.videoID else { return }
        playerView.load(withVideoId: videoId, playerVars: ["playsinline":1])

    }

    @IBAction func closeBtnClicked(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)

    }
}
