//
//  PlayerRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class PlayerRoomViewController: UIViewController {

    var DocRef: DocumentReference!
    
    var playerName = ""
    var roomId = ""
    @IBOutlet var playerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text = "玩家名稱：" + playerName
    }
    
    func sendData(_ data: [String: Any]){
        DocRef.setData(data){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }

}
