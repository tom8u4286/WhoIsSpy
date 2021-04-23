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
    
    var DocRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRoomSegue" {
            if roomIdField.text != ""{
                let roomId = roomIdField.text!

                DocRef = Firestore.firestore().document("\(roomId)/host")
                let data = ["gameStatus": "create"]
                sendData(data)

                let controller = segue.destination as! StartGameViewController
                controller.title = roomId
            }else{
                print("room file is empty!")
            }
        }
    }
    
    func sendData(_ data: [String: Any]){
        DocRef.setData(data){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
}
