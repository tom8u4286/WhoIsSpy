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
    var roomDocRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool{
        if identifier == "createRoomSegue"{
            if roomIdField.text != ""{
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

            roomDocRef = Firestore.firestore().document("GameRooms/\(roomId)")
            let data = ["host": ["gameIsOn": false, "emoji": "👑"]]
            sendData(to: roomDocRef, data)

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
