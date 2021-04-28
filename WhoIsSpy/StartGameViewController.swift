//
//  StartGameViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/23.
//

import UIKit
import Firebase

class StartGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let numberList = ["1人","2人","3人","4人","5人"]
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var citizenWordField: UITextField!
    @IBOutlet var spyWordField: UITextField!
    @IBOutlet var playerNumberLabel: UILabel!
    
    
    @IBOutlet var outerVStack: UIStackView!
    @IBOutlet var innerHStackView: UIStackView!
    
    var gameIsOn = false
    var citizenWord = ""
    var spyWord = ""
    var playerNumber = 5
    var spyNumber = 1
//    var playerNameList = [String](){ didSet{
//        playerListTextView.text = playerNameList.joined(separator: ", ")
//    }}
    
    var allPlayerList = [String:[String:String]](){
        didSet{
            playerNumber = allPlayerList.count
            playerNumberLabel.text = "\(playerNumber) 人"
        }
    }
    
    var hostDocRef: DocumentReference!
    var playerDocRef: DocumentReference!
    var quoteListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let roomId = title!
        hostDocRef = Firestore.firestore().document("\(roomId)/host")
        playerDocRef = Firestore.firestore().document("\(roomId)/players")
        print("StarGameViewController, viewDidLoad(): roomID is \(roomId)")
        
        outerVStack.distribution = .fillEqually
        innerHStackView.alignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteListener = playerDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
//                self.playerNameList = data.keys.filter { $0 != "DocumentExist" }
                if !self.gameIsOn{
                    let newNameList = Array(data.keys.filter {$0 != "DocumentExist"})
                    let oldNameList = Array(self.allPlayerList.keys)
                    let difference = newNameList.difference(from: oldNameList)
                    
                    if difference.count != 0{
                        for name in difference{
                            let dic = data[name] as! [String: Any]
                            let emoji = dic["emoji"] as! String
                            print("\(name): \(emoji)")
                            
                            self.allPlayerList[name] = ["emoji": emoji]
                            self.stackViewUpdate(name: name, emoji: emoji)
                        }
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "gameIsOnSegue"{
            if checkFieldsValid(){
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameIsOnSegue" {
            gameIsOn = true
            let (spyList, citizensList) = chooseSpies()
            
            citizenWord = citizenWordField.text!
            spyWord = spyWordField.text!
            
            let hostTable = segue.destination as! HostRoomViewController
            hostTable.title = title
            hostTable.citizenWord = citizenWord
            hostTable.spyWord = spyWord
            hostTable.citizenList = citizensList
            hostTable.spyList = spyList
            
            hostDocRef = Firestore.firestore().document("\(title!)/host")
            let data = ["gameIsOn": true,
                        "playerNumber": playerNumber,
                        "spyNumber": spyNumber,
                        "citizenWord": citizenWord,
                        "spyWord": spyWord] as [String : Any]
            sendData(to: hostDocRef, data, merge: false)
            
            
            for spy in spyList{
                let dic = ["word": spyWord]
                let data = ["\(spy)": dic]
                sendData(to: playerDocRef, data, merge: true)
            }
            for citizen in citizensList{
                let dic = ["word": citizenWord]
                let data = ["\(citizen)": dic]
                sendData(to: playerDocRef, data, merge: true)
            }
        }
        
    }
    
    func chooseSpies() -> ([String], [String]){
        var list = Array(allPlayerList.keys) as [String]
        list.shuffle()
        let spies = Array(list.prefix(spyNumber))
        let citizens = Array(list.suffix(allPlayerList.count-spyNumber))
        return (spies, citizens)
    }
    
    func checkFieldsValid() -> Bool{
        if citizenWordField.text != ""{
            if spyWordField.text != ""{
                if spyNumber < playerNumber{
                    return true
                }else{
                    print("⚠️ Too many spy!")
                }
            }else{
                print("⚠️ Spy word is nil!")
            }
        }else{
            print("⚠️ Citizen word is nil!")
        }
        return false
    }
    
    func stackViewUpdate(name: String, emoji: String){
        let attributedText = NSMutableAttributedString(string: "\(emoji)\n", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)])
        attributedText.append(NSAttributedString(string: "\(name)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)]))
        let label = UILabel()
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .center
        
        print("count: \(allPlayerList.count)")
        if allPlayerList.count < 5{
            innerHStackView.addArrangedSubview(label)
        }
        if allPlayerList.count == 5{
            let newHStack = UIStackView()
            newHStack.tag = 1
            newHStack.addArrangedSubview(label)
            outerVStack.addArrangedSubview(newHStack)
        }
        if allPlayerList.count > 5{
            let HStack = outerVStack.viewWithTag(1) as! UIStackView
            HStack.addArrangedSubview(label)
        }
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
    
    func sendData(to docRef: DocumentReference, _ data: [String: Any], merge: Bool){
        docRef.setData(data, merge: merge){ error in
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
