//
//  MyTableViewCell.swift
//  RSVPU
//
//  Created by Алексей Митькин on 13.01.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txt_time1: UILabel!
    @IBOutlet weak var txt_time2: UILabel!
    @IBOutlet weak var txt_time3: UILabel!
    @IBOutlet weak var txt_time4: UILabel!
    @IBOutlet weak var txt_time5: UILabel!
    @IBOutlet weak var txt_time6: UILabel!
    @IBOutlet weak var txt_time7: UILabel!
    
    @IBOutlet weak var txt_day: UILabel!
    @IBOutlet weak var txt_date: UILabel!

    @IBOutlet weak var txt_subject1: UILabel!
    @IBOutlet weak var txt_subject2: UILabel!
    @IBOutlet weak var txt_subject3: UILabel!
    @IBOutlet weak var txt_subject4: UILabel!
    @IBOutlet weak var txt_subject5: UILabel!
    @IBOutlet weak var txt_subject6: UILabel!
    @IBOutlet weak var txt_subject7: UILabel!
    
    @IBOutlet weak var lbl_class1: UILabel!
    @IBOutlet weak var lbl_class2: UILabel!
    @IBOutlet weak var lbl_class3: UILabel!
    @IBOutlet weak var lbl_class4: UILabel!
    @IBOutlet weak var lbl_class5: UILabel!
    @IBOutlet weak var lbl_class6: UILabel!
    @IBOutlet weak var lbl_class7: UILabel!
    
    @IBOutlet weak var lbl_prep1: UILabel!
    @IBOutlet weak var lbl_prep2: UILabel!
    @IBOutlet weak var lbl_prep3: UILabel!
    @IBOutlet weak var lbl_prep4: UILabel!
    @IBOutlet weak var lbl_prep5: UILabel!
    @IBOutlet weak var lbl_prep6: UILabel!
    @IBOutlet weak var lbl_prep7: UILabel!
    
    @IBOutlet weak var img_today: UIImageView!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_today.isHidden = true
        
        let radius:CGFloat = 3
        
       
        txt_subject1.layer.masksToBounds = true
        txt_subject1.layer.cornerRadius = radius
        
        
        txt_subject2.layer.masksToBounds = true
        txt_subject2.layer.cornerRadius = radius
        
        
        txt_subject3.layer.masksToBounds = true
        txt_subject3.layer.cornerRadius = radius
        
        
        txt_subject4.layer.masksToBounds = true
        txt_subject4.layer.cornerRadius = radius
        
        
        txt_subject5.layer.masksToBounds = true
        txt_subject5.layer.cornerRadius = radius
        
        
        txt_subject6.layer.masksToBounds = true
        txt_subject6.layer.cornerRadius = radius
        
    
        txt_subject7.layer.masksToBounds = true
        txt_subject7.layer.cornerRadius = radius
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
