//
//  PlayerViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class PlayerViewController: UIViewController {

    @IBOutlet var playerNameField: UITextField!
    @IBOutlet var roomIdField: UITextField!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var chooseYourEmojiLabel: UILabel!
    @IBOutlet var EmojiButtonCollection: [UIButton]!
    @IBOutlet var enterButton: UIButton!
    
    var playerEmoji = "😃"
    var playerName = ""
    var roomId = ""
    var gameRoomsDB = Firestore.firestore().collection("GameRooms")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "玩家"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "playerEnterRoom"{
            playerName = playerNameField.text!
            roomId = roomIdField.text!
            if checkFieldsValid(){
                spinner.startAnimating()
                allowedToEnter()
            }
        }
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "playerEnterRoom" {
            let controller = segue.destination as! PlayerRoomViewController
            controller.playerName = playerName
            controller.playerEmoji = playerEmoji
            controller.title = roomId
            
            //目前設計為第一階Collection為room的名稱(roomId)
            //4.29之後設計為Collection只稱為GameRooms，document名稱為Room房名
            let dic = ["emoji": playerEmoji, "word": "", "connected": true] as [String: Any]
            let data = ["\(playerName)": dic]
            
            sendData(to: gameRoomsDB.document("\(roomId)"), data, merge: true)
        }
    }

    @IBAction func emojiButtonAction(_ sender: UIButton) {
        playerEmoji = sender.title(for: .normal)!
        chooseYourEmojiLabel.text = "選擇你的Emoji: \(playerEmoji)"
        for button in EmojiButtonCollection{ button.backgroundColor = .none }
        sender.backgroundColor = .lightGray
    }
    func allowedToEnter(){
        //此allowedToEnter()檢查三件事 1.房間是否已存在 2.遊戲是否已經開始 3.使否有同名玩家
        
        let docRef = gameRoomsDB.document("\(roomId)")
        docRef.getDocument { (document, error) in
            guard let document = document else {return}
            
            //1.檢查房間是否存在，即主持人是否已經開房
            if ((document.exists) == true) {
                let hostData = document.data()?["host"] as! [String : Any]
                //2.檢查遊戲是否已經開始，如果已經開始，則玩家不允許進入房間
                let gameIsOnData = hostData["gameIsOn"] as! Bool
                if !gameIsOnData{
                    
                    //3.檢查是否有玩家名稱相同，如果已經有相同名稱者(包含host)，則玩家不允許進入房間
                    let playerList = document.data()?.keys
                    if !(playerList?.contains(self.playerName) ?? true){
                        //TODO: 這種直接performSegue的作法可能不是很好，接下來待改進
                        //這邊如果用return true的方式，由於getDocument要耗時(async)
                        //在還沒取得firebase document之前，function就直接先return false了，
                        //所以永遠不會執行prepare() (永遠不會執行Segue)
                        print("✅ PlayerVC.allowedToEnter(): Allowed to enter the room.")
                        self.performSegue(withIdentifier: "playerEnterRoom", sender: nil)
                    }else{
                        print("⚠️ PlayerVC.allowedToEnter(): Got same player name in room. Change a name to enter.")
                    }
                }else{
                    print("⚠️ PlayerVC.allowedToEnter(): The game is in progress. The player shall wait.")
                }
            }else{
                print("⚠️ PlayerVC.allowedToEnter(): room doesn't exist!")
            }
            self.spinner.stopAnimating()
        }
    }
    
    func checkFieldsValid() -> Bool{
        if playerNameField.text != ""{
            if roomIdField.text != ""{
                print("✅ PlayerVC.checkFieldsValid(): Valid field.")
                return true
            }
            else{ print("⚠️ PlayerVC.checkFieldsValid(): roomIdField is Empty!")}
        }else{ print("⚠️ PlayerVC.checkFieldsValid(): playerNameField is Empty!")}
        return false
    }
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any], merge: Bool){
        docRef.setData(data, merge: merge){ error in
            if let error = error{
                print("⚠️ PlayerViewController.sendData(): Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
}
