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
        
//        if let imageToLoad = "spy.png"{
//            spyImageView.image = UIImage(named: imageToLoad)
//        }
        spyImageView.image = UIImage(named: "spy.png")
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        print(items)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hostSegue" {
            let controller = segue.destination as! CreateRoomViewController
            controller.title = "遊戲主持人"
        }
        if segue.identifier == "playerSegue" {
            let controller = segue.destination as! PlayerViewController
            controller.title = "玩家"
        }
    }

}

