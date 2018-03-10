//
//  TimeTableOneDayVC.swift
//  RSVPU
//
//  Created by Алексей Митькин on 25.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit

class TimeTableOneDayVC: UITableViewController {
    
    let timeStart = ["8:00","9:45","12:00","13:45","15:30","17:15","19:00"]
    let timeEnd = ["9:35","11:20","13:35","15:20","17:05","18:50","20:35"]
    
    var TimeTable:myTimeTableViewController.TimeTableOneDay?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = TimeTable?.date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let optionMenu = UIAlertController(title:nil,message:"Открыть расписание", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title:"Закрыть", style: UIAlertActionStyle.cancel, handler: {
            action in print("Cancel Sheet")
        })
        
        let count = TimeTable?.lessons[indexPath.row].teacher.count ?? 0
        
        for i in 0..<count{
            
            optionMenu.addAction(UIAlertAction(title:TimeTable?.lessons[indexPath.row].teacher[i].teacher, style: UIAlertActionStyle.default, handler:{action in
                
                let viewController: myTimeTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "timeTable" ) as! myTimeTableViewController
                
                viewController.showCurrentDay = false
                viewController.showAlertLoading = true
                viewController.presentMode = true
                viewController.presentName = (self.TimeTable?.lessons[indexPath.row].teacher[i].teacher)!
                viewController.presentRequest = (self.TimeTable?.lessons[indexPath.row].teacher[i].teacherRequest)!
                
                self.navigationController!.pushViewController(viewController, animated:true)
                
                print(self.TimeTable?.lessons[indexPath.row].teacher[i].teacherRequest ?? "action sheet teacher error")
            }))
            
            optionMenu.addAction(UIAlertAction(title:TimeTable?.lessons[indexPath.row].classRoom[i].classRoom, style: UIAlertActionStyle.default, handler:{action in
                
                let viewController: myTimeTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "timeTable" ) as! myTimeTableViewController
                
                viewController.showCurrentDay = false
                viewController.showAlertLoading = true
                viewController.presentMode = true
                viewController.presentName = (self.TimeTable?.lessons[indexPath.row].classRoom[i].classRoom)!
                viewController.presentRequest = (self.TimeTable?.lessons[indexPath.row].classRoom[i].classRoomRequest)!
                self.navigationController!.pushViewController(viewController, animated:true)
                
                print(self.TimeTable?.lessons[indexPath.row].classRoom[i].classRoomRequest ?? "action sheet classRoom error")
            }))
        }
       
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if TimeTable?.lessons[indexPath.row].lesson[0] != "-" {
        return 144
        } else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTableOneDayCell", for: indexPath) as! TimeTableOneDayCell
        
        let i = indexPath.row
        
        if TimeTable?.lessons[i].lesson[0] != "-"{
            
            let iPrep = TimeTable?.lessons[i].teacher.count ?? 0
            let iClass = TimeTable?.lessons[i].lesson.count ?? 0
            let iNameOfLesson = TimeTable?.lessons[i].typeOfLesson.count ?? 0
            
            var text_teacher = ""
            var text_class = ""
            var text_typeOfLesson = ""
            
            //три циикла, заполняющие текстовые переменные, для отображения всех групп и преподавателей 
            for i_prep in 0..<iPrep  {
                text_teacher += (TimeTable?.lessons[i].teacher[i_prep].teacher)! + ", "
            }
            
            for i_class in 0..<iClass {
                text_class += (TimeTable?.lessons[i].classRoom[i_class].classRoom)! + ", "
            }
            
            for i_typeOfLesson in 0..<iNameOfLesson {
                text_typeOfLesson += (TimeTable?.lessons[i].typeOfLesson[i_typeOfLesson])! + "\n"
                }
            
            cell.lbl_nameOfLesson.text = TimeTable?.lessons[i].lesson[0]
            cell.lbl_nameOfPrep.text = text_teacher
            cell.lbl_typeOfLesson.text = text_typeOfLesson
            cell.lbl_numberOfClass.text = text_class
            
            cell.lbl_typeOfLesson.sizeToFit()
            cell.lbl_nameOfPrep.sizeToFit()
            cell.lbl_nameOfLesson.sizeToFit()
            cell.lbl_numberOfClass.sizeToFit()
            
        }
        cell.lbl_lessonsStart.text = timeStart[i]
        cell.lbl_lessonsEnd.text = timeEnd[i]
        
        return cell
    }
    


}
