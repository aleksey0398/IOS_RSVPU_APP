//
//  myNewsCell.swift
//  RSVPU
//
//  Created by Алексей Митькин on 19.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit

class myNewsCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var myLabel_title: UILabel!
    @IBOutlet weak var myLabel_textNews: UILabel!
    @IBOutlet weak var myLabel_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
