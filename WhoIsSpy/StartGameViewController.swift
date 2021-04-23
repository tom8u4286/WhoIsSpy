//
//  StartGameViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/23.
//

import UIKit
import Firebase

class StartGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var citizenWordField: UITextField!
    @IBOutlet var spyWordField: UITextField!
    
    var citizenWord = ""
    var spyWord = ""
    var playerNumber = 5
    var spyNumber = 1
    
    let numberList = ["1人","2人","3人","4人","5人"]
    
    var DocRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameIsOnSegue" {
            if checkFields(){
                let controller = segue.destination as! HostRoomViewController
                controller.title = title
                
                citizenWord = citizenWordField.text!
                spyWord = spyWordField.text!
                
                DocRef = Firestore.firestore().document("\(title!)/host")
                let data = ["gameStatus": "gameIsOn",
                            "playerNumber": playerNumber,
                            "spyNumber": spyNumber,
                            "citizenWord": citizenWord,
                            "spyWord": spyWord] as [String : Any]
                print(data)
                sendData(data)
            }
        }
    }
    
    func checkFields() -> Bool{
        if citizenWordField.text != ""{
            if spyWordField.text != ""{
                if spyNumber < playerNumber{
                    return true
                }else{
                    print("Too many spy!")
                }
            }else{
                print("Spy word is nil!")
            }
        }else{
            print("Citizen word is nil!")
        }
        return false
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let str = numberList[row]
        spyNumber = Int(str.strip("人"))!
    }
    
    func sendData(_ data: [String: Any]){
        DocRef.setData(data){ error in
            if let error = error{
                print("⚠️ Got an error sending data: \(error.localizedDescription)")
            }
        }
    }
}

extension String{
    func strip(_ character: String) -> String {
            return replacingOccurrences(of: character, with: "")
    }
}
