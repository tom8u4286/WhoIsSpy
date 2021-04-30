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
    
    var roomId = ""
    var gameIsOn = false
    var citizenWord = ""
    var spyWord = ""
    var playerNumber = 5
    var spyNumber = 1
    
    var playerList = [String:[String:String]](){
        didSet{
            playerNumber = playerList.count - 1 //host不算
            playerNumberLabel.text = "\(playerNumber) 人"
        }
    }
    
    var roomDocRef: DocumentReference!
    var docListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomId = title ?? "title is not set."
        roomDocRef = Firestore.firestore().document("GameRooms/\(roomId)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        docListener = roomDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
//                if !self.gameIsOn{
                    self.checkIfNewPlayerEnteredOrLeaved(data)
//                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "gameIsOnSegue"{
            if checkFieldsValid(){ return true }
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
            
            //設定遊戲基本資料
            let gameMeta = ["host.gameIsOn": true,
                        "host.playerNumber": playerNumber,
                        "host.spyNumber": spyNumber,
                        "host.citizenWord": citizenWord,
                        "host.spyWord": spyWord] as [String : Any]
            roomDocRef.updateData(gameMeta)
            
            //設定所有玩家的題目
            for spy in spyList{ roomDocRef.updateData(["\(spy).word": spyWord])}
            for citizen in citizensList{ roomDocRef.updateData(["\(citizen).word": citizenWord])}
            
            docListener.remove()
        }
        
    }
    
    func chooseSpies() -> ([String], [String]){
        var list = Array(playerList.keys.filter { $0 != "host" }) as [String]
        list.shuffle()
        let spies = Array(list.prefix(spyNumber))
        let citizens = Array(list.suffix(list.count-spyNumber))
        return (spies, citizens)
    }
    
    func checkFieldsValid() -> Bool{
        if citizenWordField.text != ""{
            if spyWordField.text != ""{
                if spyNumber < playerNumber{ return true } else { print("⚠️ Too many spy!")}
            }else{
                print("⚠️ Spy word is nil!")
            }
        }else{
            print("⚠️ Citizen word is nil!")
        }
        return false
    }
    
    func checkIfNewPlayerEnteredOrLeaved(_ data: [String: Any]){
        let newNameList = Array(data.keys)
        let oldNameList = Array(self.playerList.keys)
        let difference = newNameList.difference(from: oldNameList)
        
        if difference.count != 0{
            //有新玩家進入遊戲間
            if newNameList.count - oldNameList.count > 0{
                print("👏 StartGameVC: \(difference) entered this room!")
                for name in difference{
                    let dic = data[name] as! [String: Any]
                    let emoji = dic["emoji"] as! String
                    print("\(name): \(emoji)")
                    
                    self.playerList[name] = ["emoji": emoji]
                }
            }
            //有玩家離開遊戲
            if oldNameList.count - newNameList.count > 0{
                print("👋 StartGameVC: \(difference) leaved this room!")
                for name in difference{
                    self.playerList.removeValue(forKey: name)
                }
                print("Rest player are: \(playerList.keys)")
            }
            outerVStack.removeAllArrangedSubviews()
            redrawStackView()
        }
        
    }
    
    func redrawStackView(){
        for num in 0...(playerList.count-1)/5{
            let HStack = UIStackView()
            HStack.tag = num
            HStack.axis  = .horizontal
            HStack.alignment = .center
            HStack.distribution = .fill
            HStack.spacing = 10
            outerVStack.addArrangedSubview(HStack)
        }
        var index = 0
        for (name, dic) in playerList{
            if let assignedStack = outerVStack.viewWithTag(index/5) as? UIStackView{
                let emoji = dic["emoji"] ?? "No emoji got."
                let attributedText = NSMutableAttributedString(string: "\(emoji)\n", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)])
                attributedText.append(NSAttributedString(string: "\(name)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)]))
                let label = UILabel()
                label.attributedText = attributedText
                label.numberOfLines = 2
                label.textAlignment = .center
                assignedStack.addArrangedSubview(label)
            }
            index += 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberList.count
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: numberList[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
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
