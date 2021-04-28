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
    
    @IBOutlet var outerVerticalStackView: UIStackView!
    @IBOutlet var allPlayersStackView: UIStackView!
    
    var playerEmoji = ""
    var playerName = ""
    var roomId = ""
    var gameIsOn = false
    var allPlayerList = [String:[String:String]]()//["Alice":["emoji": "😎"]]
    @IBOutlet var playerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text =  playerEmoji + playerName
        roomId = title!
        hostDocRef = Firestore.firestore().document("\(roomId)/host")
        playerDocRef = Firestore.firestore().document("\(roomId)/players")
        
        outerVerticalStackView.distribution = .fillEqually
        allPlayersStackView.alignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerListener = playerDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){

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
                
                let dic = data[self.playerName] as! [String: Any]
                if let playerWord = dic["word"] as? String {
                    self.wordLabel.text = playerWord
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
    
    func stackViewUpdate(name: String, emoji: String){
        let attributedText = NSMutableAttributedString(string: "\(emoji)\n", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)])
        attributedText.append(NSAttributedString(string: "\(name)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)]))
        let label = UILabel()
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .center
        
        print("count: \(allPlayerList.count)")
        if allPlayerList.count < 5{
            allPlayersStackView.addArrangedSubview(label)
        }
        if allPlayerList.count == 5{
            let newHStack = UIStackView()
            newHStack.tag = 1
            newHStack.addArrangedSubview(label)
            outerVerticalStackView.addArrangedSubview(newHStack)
        }
        if allPlayerList.count > 5{
            let HStack = outerVerticalStackView.viewWithTag(1) as! UIStackView
            HStack.addArrangedSubview(label)
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

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
