//
//  PlayerViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet var playerNameField: UITextField!
    @IBOutlet var roomIdField: UITextField!
    
    @IBOutlet var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "玩家"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func enterRoom(_ sender: Any) {
        print(playerNameField.text)
        print(roomIdField.text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "playerEnterRoom" {
            let controller = segue.destination as! PlayerRoomViewController
            controller.playerName = playerNameField.text!
            controller.title = roomIdField.text
        }
    }
}
