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
    
    var playerEmoji = "😃"
    var playerName = ""
    var roomId = ""
    
    @IBOutlet var enterButton: UIButton!
    
    var playerDocRef: DocumentReference!
    var hostDocRef: DocumentReference!
    
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
                
                //MARK: -
                //MARK: 1.如果有玩家的playerName取名為host，會有問題。待解決。
                //MARK: 2.應加入playerName檢查機制，確保沒有相同名稱的player。待解決。
                hostDocRef = Firestore.firestore().document("\(roomId)/host")
                hostDocRef.getDocument { (document, error) in
                    if ((document?.exists) == true) {
                        print("✅ Room Exists. Perform Segue!")
                        //TODO: 這種直接performSegue的作法可能不是很好，接下來待改進
                        self.performSegue(withIdentifier: "playerEnterRoom", sender: nil)
                    }else{
                        print("⚠️ room doesn't exist!")
                    }
                    self.spinner.stopAnimating()
                }
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
            let dic = ["emoji": playerEmoji, "word": "connected"]
            let data = ["\(playerName)": dic]
            playerDocRef = Firestore.firestore().document("\(roomId)/players")
            print("playerDocRef: \(playerDocRef)")
            sendData(to: playerDocRef, data, merge: true)
        }
    }
    
    
    
    //MARK: - functions
    //MARK: -
    
    @IBAction func emojiButtonAction(_ sender: UIButton) {
        playerEmoji = sender.title(for: .normal)!
        chooseYourEmojiLabel.text = "選擇你的Emoji: \(playerEmoji)"
        resetEmojiButtons()
        sender.backgroundColor = .lightGray
    }
    
    func resetEmojiButtons(){
        for button in EmojiButtonCollection{
            button.backgroundColor = .none
        }
    }
    
    
    func checkRoomExist() -> Bool{
        return false
    }
    
    func checkFieldsValid() -> Bool{
        print("playerNameField.text: \(playerName)")
        print("roomIdField.text: \(roomId)")
        
        if playerNameField.text != ""{
            if roomIdField.text != ""{ return true }
            else{ print("⚠️ roomIdField is Empty!")}
        }else{ print("⚠️ playerNameField is Empty!")}
        print("✅ Fields Valid.")
        return false
    }
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any], merge: Bool){
        docRef.setData(data, merge: merge){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
}
