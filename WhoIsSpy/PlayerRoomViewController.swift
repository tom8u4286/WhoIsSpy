//
//  PlayerRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit
import Firebase

class PlayerRoomViewController: UIViewController {
    
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var gameStatusLabel: UILabel!
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var outerVStack: UIStackView!
    
    var playerEmoji = ""
    var playerName = ""
    var roomId = ""
    var gameIsOn = false
    var playerInRoom = false
    
    //資料長相：["Alice":["emoji": "😎", "word": "something"]]
    var playerList = [String:[String:String]]()
    
    var roomDocRef: DocumentReference!
    var docListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerInRoom = true
        playerNameLabel.attributedText = attributedPlayerNameLable()
        roomId = title!
        roomDocRef = Firestore.firestore().document("GameRooms/\(roomId)")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "離開遊戲", style: .plain, target: self,action: #selector(leaveRoom))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        docListener = roomDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
                if self.playerInRoom{
                    self.checkIfGameIsOn(data)
                        self.checkIfNewPlayerEnteredOrLeaved(data)
                }
            }
        }
    }
    
    func checkIfNewPlayerEnteredOrLeaved(_ data: [String: Any]){
        //此function檢查是否有玩家進入房間或是離開房間，若有，要重畫Emoji圖
        //同時，如果發現離開的是host，則表示遊戲式被關閉，主動segue回PlayerVC
        let newNameList = Array(data.keys)
        let oldNameList = Array(self.playerList.keys)
        let difference = newNameList.difference(from: oldNameList)
        
        if difference.count != 0{
            //有新玩家進入遊戲間
            if newNameList.count - oldNameList.count > 0{
                print("👏 PlayerRoomVC: \(difference) entered this room!")
                for name in difference{
                    let dic = data[name] as! [String: Any]
                    let emoji = dic["emoji"] as! String
                    self.playerList[name] = ["emoji": emoji]
                }
            }
            //有玩家離開遊戲
            if oldNameList.count - newNameList.count > 0{
                print("👋 PlayerRoomVC: \(difference) leaved this room!")
                //如果發現離開的是host，則表示遊戲式被關閉，主動segue回PlayerVC
                if difference.contains("host"){
                    let ac = UIAlertController(title: "遊戲結束", message: "主持人已關閉遊戲室", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "確定", style: .default, handler: {_ in self.leaveRoom()}))
                    present(ac, animated: true)
                    return
                }
                for name in difference{
                    self.playerList.removeValue(forKey: name)
                }
            }
            outerVStack.removeAllArrangedSubviews()
            redrawStackView()
        }
        
        
    }
    
    func checkIfGameIsOn(_ data: [String: Any]){
        if let hostData = data["host"] as? [String: Any]{
            if hostData["gameIsOn"]! as! Bool{
                print("✅ PlayerRoomVC.chekIfGameIsOn(): The game is on!")
                gameIsOn = true
                
                let dic = data[self.playerName] as! [String: Any]
                if let playerWord = dic["word"] as? String {
                    self.wordLabel.text = playerWord
                }
                
                self.gameStatusLabel.isHidden = true
                self.hintLabel.isHidden = false
                self.wordLabel.isHidden = false
            }else{
                print("❌ PlayerRoomVC.chekIfGameIsOn(): The game is off!")
                gameIsOn = false
                self.gameStatusLabel.isHidden = false
                self.hintLabel.isHidden = true
                self.wordLabel.isHidden = true
                wordLabel.text = ""
            }
        }
    }
    func attributedPlayerNameLable() -> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: "\(playerEmoji)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70)])
        attributedText.append(NSAttributedString(string: "\(playerName)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]))
        return attributedText
    }
    
    
    func redrawStackView(){
        for num in 0...(playerList.count-1)/6{
            let HStack = UIStackView()
            HStack.tag = num
            HStack.axis  = .horizontal
            HStack.alignment = .center
            HStack.distribution = .fillEqually
            HStack.spacing = 10
            outerVStack.addArrangedSubview(HStack)
        }
        
        var index = 0
        for (name, dic) in playerList{
            if let assignedStack = outerVStack.viewWithTag(index/6) as? UIStackView{
                let emoji = dic["emoji"] ?? "No emoji got."
                
                let attributedText = NSMutableAttributedString(string: "\(emoji)\n", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)])
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.preferredFont(forTextStyle: .title2),
                    .foregroundColor: UIColor.black,
                ]
                attributedText.append(NSAttributedString(string: "\(name)", attributes: attributes))
                
                let label = UILabel()
                label.attributedText = attributedText
                label.numberOfLines = 2
                label.textAlignment = .center
                assignedStack.addArrangedSubview(label)
            }
            index += 1
        }
    }
    @objc func leaveRoom(){
        roomDocRef.updateData(["\(playerName)": FieldValue.delete()])
        playerEmoji = ""
        playerName = ""
        roomId = ""
        gameIsOn = false
        playerInRoom = false
        self.navigationController?.popViewController(animated: true)
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
extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
