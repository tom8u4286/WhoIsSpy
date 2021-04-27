//
//  HostRoomViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/23.
//

import UIKit

class HostRoomViewController: UITableViewController {
    var citizenWord = ""
    var spyWord = ""
    var citizenList = [String]()
    var spyList = [String]()
    var tableList = [[String: String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for spy in spyList{
            let dic = ["name": spy, "emoji": "😈", "word": spyWord]
            tableList.append(dic)
        }
        for citizen in citizenList{
            let dic = ["name": citizen, "emoji": "🤔", "word": citizenWord]
            tableList.append(dic)
        }
        print(tableList)
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
