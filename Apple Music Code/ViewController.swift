//
//  ViewController.swift
//  Apple Music Code
//
//  Created by Kody Young on 7/20/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //// Usage ////
        
        AppleMusicManager.shared.find(songTitle: "Demons Yng Kody", developerToken: "developer_token"){

            AppleMusicManager.shared.play(song: [AppleMusicManager.shared.identifier])
            
        }
        
    }


}



