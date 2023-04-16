//
//  YoutubePlayerViewController.swift
//  Streamini
//
//  Created by ナム Nam Nguyen on 5/24/17.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import UIKit

class YoutubePlayerViewController: UIViewController,YTPlayerViewDelegate {
    @IBOutlet weak var playerView: YTPlayerView?
    @IBOutlet weak var closeButton: UIButton!
    var videoId:String? {
        didSet {
            if videoId != nil {
                playerView?.load(withVideoId: videoId!, playerVars: ["playsinline":1])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if videoId != nil {
            playerView?.load(withVideoId: videoId!, playerVars: ["playsinline":1])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeDidTouch(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
