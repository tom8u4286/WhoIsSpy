//
//  HostRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/23.
//

import UIKit
import Firebase

class HostRoomViewController: UITableViewController {
    var roomId = ""
    var citizenWord = ""
    var spyWord = ""
    var citizenList = [String]()
    var spyList = [String]()
    var playerList = [String]()
    var tableList = [[String: String]]()
    
    var roomDocRef: DocumentReference!
    var docListener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        roomId = title ?? "roomId not set."
        roomDocRef = Firestore.firestore().document("GameRooms/\(roomId)")
        playerList = spyList + citizenList
        
        for spy in spyList{
            let dic = ["name": spy, "emoji": "😈", "word": spyWord]
            tableList.append(dic)
        }
        for citizen in citizenList{
            let dic = ["name": citizen, "emoji": "🤔", "word": citizenWord]
            tableList.append(dic)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "新遊戲", style: UIBarButtonItem.Style.plain, target: self, action: #selector(newGame))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        docListener = roomDocRef.addSnapshotListener{ (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            if let data = docSnapshot.data(){
                self.checkIfPlayerLeaved(data)
            }
        }
    }
    
    func checkIfPlayerLeaved(_ data: [String: Any]){
        let newNameList = Array(data.keys.filter { $0 != "host" })
        let oldNameList = Array(playerList)
        let difference = newNameList.difference(from: oldNameList)
        
        //有玩家離開遊戲
        if oldNameList.count - newNameList.count > 0{
            print("👋 HostRoomVC: \(difference) leaved this room!")
            for name in difference{
                playerList = playerList.filter { $0 != name }
                spyList = spyList.filter { $0 != name }
                citizenList = citizenList.filter { $0 != name }
            }
            print("The rest player are: \(playerList)")
        }
    }
    @objc func newGame(){
        self.navigationController?.popViewController(animated: true)
        
        let data = ["host.gameIsOn": false,
                    "host.playerNumber": -1,
                    "host.spyNumber": -1,
                    "host.citizenWord": "",
                    "host.spyWord": ""] as [String : Any]
        roomDocRef.updateData(data)
        
        //Firebase將所有人的題目改成""
        print("New Game button tapped!")
        print("playerList: \(playerList)")
        for name in playerList{
            roomDocRef.updateData(["\(name).word": ""])
        }
        docListener.remove()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citizenList.count + spyList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! TableCell
        cell.emojiLabel.text = tableList[indexPath.row]["emoji"]
        cell.nameLabel.text = tableList[indexPath.row]["name"]
        cell.wordLabel.text = tableList[indexPath.row]["word"]
        
        if cell.emojiLabel.text == "😈"{
            cell.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 193/255, alpha: 1)
        }else{
            cell.backgroundColor = UIColor(red: 240/255, green: 255/255, blue: 240/255, alpha: 1)
        }
        return cell
    }
}
