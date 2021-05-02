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
    
//    var playerDocRef: DocumentReference!
//    var hostDocRef: DocumentReference!
    
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
    
    //MARK: - functions
    //MARK: -
    
    @IBAction func emojiButtonAction(_ sender: UIButton) {
        playerEmoji = sender.title(for: .normal)!
        chooseYourEmojiLabel.text = "選擇你的Emoji: \(playerEmoji)"
        for button in EmojiButtonCollection{ button.backgroundColor = .none }
        sender.backgroundColor = .lightGray
    }
    
    func allowedToEnter(){
        //MARK: -
        //MARK: 1.如果有玩家的playerName取名為host，會有問題。待解決。
        //MARK: 2.應加入playerName檢查機制，確保沒有相同名稱的player。待解決。
//                DocRef = gameRoomDB.document("\(roomId)/host")
        let docRef = gameRoomsDB.document("\(roomId)")
        docRef.getDocument { (document, error) in
            guard let document = document else {return}
            if ((document.exists) == true) {
                let data = document.data()?["host"] as! [String : Any]
                let gameIsOnData = data["gameIsOn"] as! Bool
                if !gameIsOnData{
                    //TODO: 這種直接performSegue的作法可能不是很好，接下來待改進
                    //這邊如果用return true的方式，由於getDocument要耗時(async)
                    //在還沒取得firebase document之前，function就直接先return false了，
                    //所以永遠不會執行prepare() (永遠不會執行Segue)
                    print("✅ PlayerVC.allowedToEnter(): Room Exists.")
                    self.performSegue(withIdentifier: "playerEnterRoom", sender: nil)
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
                print("✅ PlayerVC.checkFieldsValid(): Fields Valid.")
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
