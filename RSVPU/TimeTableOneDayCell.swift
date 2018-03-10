//
//  TimeTableOneDayCell.swift
//  RSVPU
//
//  Created by Алексей Митькин on 25.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit

class TimeTableOneDayCell: UITableViewCell {
    
    
    @IBOutlet weak var lbl_typeOfLesson: UILabel!
    @IBOutlet weak var lbl_nameOfLesson: UILabel!
    @IBOutlet weak var lbl_nameOfPrep: UILabel!
    @IBOutlet weak var lbl_numberOfClass: UILabel!
    @IBOutlet weak var lbl_lessonsStart: UILabel!
    @IBOutlet weak var lbl_lessonsEnd: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        let radius:CGFloat = 5
        
        lbl_typeOfLesson.layer.masksToBounds = true
        lbl_typeOfLesson.layer.cornerRadius = radius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
