//
//  TodayViewController.swift
//  Time Table
//
//  Created by Алексей Митькин on 01.01.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var txt_pair1: UILabel!
    @IBOutlet var txt_pair2: UILabel!
    @IBOutlet var txt_timeBreak: UILabel!
    @IBOutlet var txt_pair3: UILabel!
    @IBOutlet var txt_pair4: UILabel!
    @IBOutlet var txt_pair5: UILabel!
    @IBOutlet var txt_pair6: UILabel!
    
    @IBOutlet var txt_outTimePair1: UILabel!
    @IBOutlet var txt_outTimePair2: UILabel!
    @IBOutlet var txt_outTimePair3: UILabel!
    @IBOutlet var txt_outTimePair4: UILabel!
    @IBOutlet var txt_outTimePair5: UILabel!
    @IBOutlet var txt_outTimePair6: UILabel!
    
    
    let hour = Calendar.current.component(.hour, from: Date())
    let minutes = Calendar.current.component(.minute, from: Date())
    var time = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInvisibleOutTime()
        
        time = hour*100+minutes;
        print("Time \(hour):\(minutes) \n \(time)")
        
        
        if(time >= 800)&&(time <= 935){
            self.txt_pair1.textColor = UIColor.red
            
            self.txt_outTimePair1.textColor = UIColor.black
            self.txt_outTimePair1.text? += timeIsOut(whenAPairWasEnd: 9*60+35)
            
        }
        
        if(time >= 945)&&(time <= 1120){
            self.txt_pair2.textColor = UIColor.red
            
            self.txt_outTimePair2.textColor = UIColor.black
            self.txt_outTimePair2.text? += timeIsOut(whenAPairWasEnd: 11*60+20)
            
        }
        
        if (time >= 1120)&&(time <= 1159){
            self.txt_timeBreak.textColor = UIColor.red
            
        }
        
        if (time >= 1200)&&(time <= 1335) {
            self.txt_pair3.textColor = UIColor.red
            
            self.txt_outTimePair3.textColor = UIColor.black
            self.txt_outTimePair3.text? += timeIsOut(whenAPairWasEnd: 13*60+35)
            
            
        }
        
        if(time >= 1345)&&(time <= 1520){
            self.txt_pair4.textColor = UIColor.red
            
            self.txt_outTimePair4.textColor = UIColor.black
            self.txt_outTimePair4.text? += timeIsOut(whenAPairWasEnd: 15*60+20)
            
            
        }
        
        if(time >= 1530)&&(time <= 1705){
            self.txt_pair5.textColor = UIColor.red
            
            self.txt_outTimePair5.textColor = UIColor.black
            self.txt_outTimePair5.text? += timeIsOut(whenAPairWasEnd: 17*60+5)
        }
        
        if (time >= 1715)&&(time <= 1850){
            self.txt_pair6.textColor = UIColor.red
            
            self.txt_outTimePair6.textColor = UIColor.black
            self.txt_outTimePair6.text? += timeIsOut(whenAPairWasEnd: 18*60+50)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInvisibleOutTime() -> Void {
        self.txt_outTimePair1.textColor = UIColor.clear
        self.txt_outTimePair2.textColor = UIColor.clear
        self.txt_outTimePair3.textColor = UIColor.clear
        self.txt_outTimePair4.textColor = UIColor.clear
        self.txt_outTimePair5.textColor = UIColor.clear
        self.txt_outTimePair6.textColor = UIColor.clear
        
    }
    
    //вернёт нам оставшееся количесво минут, если их менее 60
    //В противном случае вернёт "больше часа"
    func timeIsOut(whenAPairWasEnd: Int) -> String {
        var timeIsOutInt = 0
        timeIsOutInt = whenAPairWasEnd-(hour*60+minutes)
        print("Pair was end: \(whenAPairWasEnd) \n Current time: \(hour*60+minutes)")
        if timeIsOutInt>60{
            return " больше часа"
        } else {
            return String(timeIsOutInt)+" минут(ы)"
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
