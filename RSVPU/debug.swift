//
//  debug.swift
//  RSVPU
//
//  Created by Алексей Митькин on 28.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit
import Kanna

class debug: UIViewController {
    
   // let url = "http://www.rsvpu.ru/raspisanie-zanyatij-ochnoe-otdelenie/?v_gru=1729"
     let url = "http://www.rsvpu.ru/raspisanie-zanyatij-ochnoe-otdelenie/?v_aud=281"
    var TimeTable = [TimeTableOneDay]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func parseURL()->Void{
        
        let url = URL(string:self.url)
        let htmlToParse = getHTMLString(url: url!)
        
        var TimeTableUncorrect = [TimeTableOneDay]()
        
        
        
        if let docHtml = Kanna.HTML(html: htmlToParse, encoding: String.Encoding.utf8){
            var i = 0
            //получаем один день из расписания
            for timeTable in docHtml.css("td[class='disciplina ']"){
                TimeTableUncorrect.append(getOneDayFromXML(XML: timeTable))
                print("\n")
                i+=1
            }
            
            // для получения даты и названия дней недели
            let docHTML2 = docHtml.at_css("table[class='tametable_ofo']")!
            
            i = 0
            
            for timeTable in docHTML2.css("tr[class='day']"){
                
                if i == 7{
                    break
                }
                
                TimeTableUncorrect[i+i].nameOfDay = timeTable.text!
                TimeTableUncorrect[i+i+1].nameOfDay = timeTable.text!
                i += 1
            }
            
            //меняем местами расписание чтобы оно было в хронологическом порядке
            
            for i in 0..<TimeTableUncorrect.count{
                if i%2 == 0{
                    TimeTable.append(TimeTableUncorrect[i])
                }
            }
            for i in 0..<TimeTableUncorrect.count{
                if i%2 != 0{
                    TimeTable.append(TimeTableUncorrect[i])
                }
            }

            
            i = 0
            //получаем дату текущей недели
            for timeTable4 in docHTML2.css("td[class='left']"){
                let showString = timeTable4.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                // print(showString)
                TimeTable[i].date = showString
                i+=1
            }
            
            //получаем дату следующей недели
            for timeTable5 in docHTML2.css("td[class='right']"){
                let showString = timeTable5.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                //print(showString)
                TimeTable[i].date = showString
                i+=1
            }


            
            print("Count Day: \(i)")
        }
    }
    
    //для получения одного дня из расписания
    func getOneDayFromXML(XML:XMLElement) ->TimeTableOneDay{
        let timeTableDay = TimeTableOneDay()
        
        var countLesson = 0
        for lesson in XML.css("td[class='disciplina_info']"){
            countLesson+=1
            timeTableDay.lessons.append(getOneLesson(XML: lesson))
        }
        
        countLesson = 0
        for time in XML.css("td[class='disciplina_time']"){
            timeTableDay.lessons[countLesson].time.append(time.text!)
            countLesson+=1
        }
        print("Count lesson: \(countLesson)")
        return timeTableDay
    }
    
    //получаем одиин предмет
    func getOneLesson(XML:XMLElement) -> TimeTableOneLesson {
        let timeTableLesson = TimeTableOneLesson()
        
        var countGroup = 0
        
        for lessons in XML.css("p"){
            //получили название предмета
            let lesson = getLessonName(str:lessons.text!)
            let typeOfLesson = getLessonType(str: lessons.text!)
            timeTableLesson.lesson.append(lesson)
            timeTableLesson.typeOfLesson.append(typeOfLesson)
            print(lesson)
            
            var number = 0
            //кортеж, хранящий в себе номер кабинета и ссылку на него
            var classRoom = [(String,String)]()
            //кортеж, хранящий в себе имя учителя и ссылку на него
            var teacher = [(String,String)]()
            
            //кортеж, который заполняется в цикле
            var corteg:(String,String) = ("","")
            
            for other in lessons.css("nobr"){
                
                if other.text != "" {
                    number+=1
                    
                    //получили 1: номер кабинета
                    //         2: ссылку на кабинет
                    //         3: имя преподавателя
                    //         4: ссылку на преподавателя
                    //         5: номер подгруппы
                        if number == 1{
                            corteg.0 = other.text!
                        }
                        if number == 3{
                            corteg.0 = other.text!
                        }
                    
                
                    print(other.text!)
                    if other.at_css("a")?["href"] != nil {
                        
                        if number == 2{
                            corteg.1 = (other.at_css("a")?["href"])!
                            classRoom.append(corteg)
                        }
                        if number == 4 {
                            corteg.1 = (other.at_css("a")?["href"])!
                            teacher.append(corteg)
                            }
                        print((other.at_css("a")?["href"])!)
                    }
                    
                    if number == 5 {
                        timeTableLesson.podGroup.append(other.text!)
                        number = 0
                    }
                }
                
            }
            countGroup+=1
        }
        
        if countGroup > 1{
            timeTableLesson.haveManyGroup = true
        }
        
        print("Count Group in lesson: \(countGroup)")
        
        return timeTableLesson
    }
    
    //получаем чисто название предмета без группы, номера кабинета
    func getLessonName(str:String)->String{
        let char:Character = "("
        
        if let idx = str.characters.index(of: char){
            
            let returnedString = str.substring(to: idx)
            return returnedString
            // return ("Found \(char) at \(position)")
        } else {
            return str
        }
    }
    
    //получаем тип придмета
    func getLessonType(str:String)->String{
        let charStart:Character = "(", charEnd:Character = ")"
        
        if let idxStart = str.characters.index(of: charStart){
            let idxEnd = str.characters.index(of: charEnd)
            let typeOfLesson = str[idxStart...idxEnd!]
            print("type of lesson: \(typeOfLesson)")
            return typeOfLesson
        }
        else {
            return "no type"
        }
    }
    
    func getHTMLString(url:URL) -> String {
        
        do {
            let myHTMLString = try String(contentsOf: url, encoding: .utf8)
            return myHTMLString
        } catch let error {
            print("Error: \(error)")
            return "Error: \(error)"
        }
        
    }
    
    class TimeTableOneDay {
        var nameOfDay:String?
        var date:String?
        var lessons = [TimeTableOneLesson]()
        var today:Bool?
        
        init(){}
        
    }
    
    class TimeTableOneLesson{
        
        var haveManyGroup:Bool?
        
        var lesson = [String]()
        var time = [String]()
        var typeOfLesson = [String]()
        
        var podGroup = [String]()
        
        var classRoom = [(classRoom:String,classRoomRequest:String)]()
        var teacher = [(teacher:String,teacherRequest:String)]()
        
        init(){}
        
    }
    
}
