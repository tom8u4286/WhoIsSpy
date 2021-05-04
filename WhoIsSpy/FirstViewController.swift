//
//  ViewController.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/22.
//

import UIKit

class FirstViewController: UIViewController {

    
    @IBOutlet var spyImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spyImageView.image = UIImage(named: "spy.png")
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSegue" {
            let controller = segue.destination as! PlayerViewController
            controller.title = "加入遊戲"
        }
        if segue.identifier == "hostSegue" {
            let controller = segue.destination as! CreateRoomViewController
            controller.title = "建立遊戲"
        }
        
    }

}

