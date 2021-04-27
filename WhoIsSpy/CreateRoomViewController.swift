//
//  CreateRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class CreateRoomViewController: UIViewController {

    @IBOutlet var roomIdField: UITextField!
    
    var hostDocRef: DocumentReference!
    var playerDocRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool{
        if identifier == "createRoomSegue"{
            if roomIdField.text != ""{
                print("✅ shouldPerformSegue(): roomIdField checked!")
                print("roomId is \(roomIdField.text)")
                return true
            }else{
                print("⚠️ shouldPerformSegue(): roomIdField is Empty!")
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRoomSegue"{
            let roomId = roomIdField.text!

            hostDocRef = Firestore.firestore().document("\(roomId)/host")
            let data = ["gameStatus": "create"]
            sendData(to: hostDocRef, data)
            
            playerDocRef = Firestore.firestore().document("\(roomId)/players")
            let emptyDoc = ["DocumentExist": true]
            sendData(to: playerDocRef, emptyDoc)

            let controller = segue.destination as! StartGameViewController
            controller.title = roomId
        }
    }
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any]){
        docRef.setData(data){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
}
