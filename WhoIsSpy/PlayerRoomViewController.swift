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
    var quoteListener: ListenerRegistration!
    
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    
    var playerEmoji = ""
    var playerName = ""
    var roomId = ""
    @IBOutlet var playerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text = "玩家名稱：" + playerName
        roomId = title!
        hostDocRef = Firestore.firestore().document("\(roomId)/host")
        playerDocRef = Firestore.firestore().document("\(roomId)/players")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteListener = playerDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
                self.wordLabel.text = data[self.playerName] as? String
                self.hintLabel.isHidden = false
                self.wordLabel.isHidden = false
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
