//
//  CustomCellTableViewCell.swift
//  WhoIsSpy
//
//  Created by 曲奕帆 on 2021/4/27.
//

import UIKit

class TableCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
