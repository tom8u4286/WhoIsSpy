//
//  CreateRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class CreateRoomViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var roomIdField: UITextField!
    @IBOutlet var sameIdHintLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var createButton: UIButton!
    
    var roomDocRef: DocumentReference!
    var gameRoomsDB = Firestore.firestore().collection("GameRooms")
    var roomId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.roomIdField.delegate = self
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool{
        if identifier == "createRoomSegue"{
            roomId = roomIdField.text!
            if checkFieldsNotEmpty(){
                spinner.startAnimating()
                sameIdHintLabel.isHidden = true
                createButton.isEnabled = false
                ifRoomIdUnique()
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRoomSegue"{
            roomDocRef = Firestore.firestore().document("GameRooms/\(roomId)")
            let data = ["host": ["gameIsOn": false, "emoji": "👑"]]
            sendData(to: roomDocRef, data)

            let controller = segue.destination as! StartGameViewController
            controller.title = roomId
        }
    }
    
    func ifRoomIdUnique(){
        let docRef = gameRoomsDB.document("\(roomId)")
        docRef.getDocument { (document, error) in
            guard let document = document else {return}
            if ((document.exists) == true) {
                self.sameIdHintLabel.isHidden = false
            }else{
                self.performSegue(withIdentifier: "createRoomSegue", sender: nil)
            }
            
            self.spinner.stopAnimating()
            self.createButton.isEnabled = true
        }
    }
    
    func checkFieldsNotEmpty() -> Bool{
        if roomIdField.text == ""{
            roomIdField.backgroundColor = UIColor(red: 255/255, green: 174/255, blue: 185/255, alpha: 1)
            UIView.animate(withDuration: 3){ self.roomIdField.backgroundColor = .white }
            return false
        }
        return true
    }
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any]){
        docRef.setData(data){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
    
    //Hide keyboard when ended editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        roomIdField.resignFirstResponder()
        return true
    }
}
