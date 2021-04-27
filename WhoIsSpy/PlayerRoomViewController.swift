//
//  PlayerRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class PlayerRoomViewController: UIViewController {

    var hostDocRef: DocumentReference!
    var playerDocRef: DocumentReference!
    var playerListener: ListenerRegistration!
    var hostListener: ListenerRegistration!
    
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var gameStatusLabel: UILabel!
    
    var playerEmoji = ""
    var playerName = ""
    var roomId = ""
    var gameIsOn = false
    var allPlayerList = [[String:[String:String]]]()//["Alice":["emoji": "😎"]]
    @IBOutlet var playerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text = "玩家名稱： " + playerEmoji + playerName
        roomId = title!
        hostDocRef = Firestore.firestore().document("\(roomId)/host")
        playerDocRef = Firestore.firestore().document("\(roomId)/players")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerListener = playerDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
                
                let dic = data[self.playerName] as! [String: Any]
                let playerWord = dic["word"] as! String
                self.wordLabel.text = playerWord
                
                
                if !self.gameIsOn{
                    var temp = [[String:[String:String]]]()
                    for name in data.keys.filter { $0 != "DocumentExist" }{
                        let dic = data[name] as! [String: Any]
                        let emoji = dic["emoji"] as! String
                        let stru = [name: ["emoji": emoji]]
                        temp.append(stru)
                    }
                    self.allPlayerList = temp
                    print(self.allPlayerList)
                }
            }
        }
        hostListener = hostDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
                let gameIsOn = data["gameIsOn"] as! Bool?
                if gameIsOn ?? false{
                    self.gameStatusLabel.isHidden = true
                    self.hintLabel.isHidden = false
                    self.wordLabel.isHidden = false
                }else{
                    self.gameStatusLabel.isHidden = false
                    self.hintLabel.isHidden = true
                    self.wordLabel.isHidden = true
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            
        }
    }
    
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any], merge: Bool){
        docRef.setData(data, merge: merge){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }

}
