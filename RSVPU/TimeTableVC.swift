//
//  myTableViewController.swift
//  RSVPU
//
//  Created by Алексей Митькин on 13.01.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit
import Kanna

class myTimeTableViewController: UITableViewController {
    
    var URLTimeTable = "http://www.rsvpu.ru/raspisanie-zanyatij-ochnoe-otdelenie/"
    let URLTimeTableConst = "http://www.rsvpu.ru/raspisanie-zanyatij-ochnoe-otdelenie/?v_gru=2734&v_date="
    
    
    var HTMLFromPage:String?
    var showAlertLoading = false
    var dayOfWeek:Int?
    var showCurrentDay = true
    var TimeTable = [TimeTableOneDay]()
    var day = 0,month = 0,year = 0
    
    var offlineMode = false
    
    var presentMode = false
    
    
    var presentName:String = ""
    var presentRequest:String = ""
    
    var indicator:UIActivityIndicatorView?
    
    //varibles for test
    var parsingTime:Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = createIndicator()
        
        if day == 0 {
            getCurrentDate()
        } else {
            plus14DayForWeak()
        }
        
        //если мы не смотрим расписание по выбору
        if !presentMode {
            
            self.navigationItem.title = UserDefaults.standard.string(forKey: myGroupViewController.defaultKeys.groupName) ?? "ИЭ-203п"
            
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            self.navigationController?.navigationBar.tintColor = .white
            
            
            //Инициализирует возможность pull_to_refresh
            self.refreshControl?.addTarget(self, action: #selector(myTimeTableViewController.handlerRefresh(_:)), for: UIControl.Event.valueChanged)
            
            if showAlertLoading {
                indicator?.startAnimating()
            } else {
                let defaults = UserDefaults.standard
                let type = defaults.integer(forKey: myGroupViewController.defaultKeys.numberSegment)
                let value = defaults.string(forKey: myGroupViewController.defaultKeys.getRequest)
                //print("type: \(type)    value: \(String(describing: value))")
                if value == nil{
                    getTimeTable(myURL: URLTimeTableConst)
                } else {
                    indicator?.startAnimating()
                    DispatchQueue.global(qos: .background).async {
                        self.getTimeTable(myURL: self.URLTimeTable+self.generationGetRequets(type: type, value: value!)+self.converDateForString(day: self.day, month: self.month, year: self.year))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.indicator?.stopAnimating()
                        }
                        
                    }
                }
                
            }
        } else {
            self.navigationItem.title = presentName
            indicator?.startAnimating()
            DispatchQueue.global(qos: .background).async {
                self.getTimeTable(myURL: self.URLTimeTable + self.presentRequest)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicator?.stopAnimating()
                }
                
            }
            
        }
        
        // debugTimeTablePareser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !presentMode{
            let defaults = UserDefaults.standard
            
            let value = defaults.string(forKey: myGroupViewController.defaultKeys.getRequest)
            let type = defaults.integer(forKey: myGroupViewController.defaultKeys.numberSegment)
            
            groupChange(defaults: defaults)
            
            if showAlertLoading {
                showAlertLoading = false
                
                getTimeTable(myURL: URLTimeTable+generationGetRequets(type: type, value: value!)+converDateForString(day: day, month: month, year: year))
                self.tableView.reloadData()
                indicator?.stopAnimating()
                
            }
            
            defaults.synchronize()
        }
    }
    
    
    func groupChange(defaults:UserDefaults) -> Void {
        
        //если мы поменяли группу
        var previousValue = defaults.string(forKey: myGroupViewController.defaultKeys.previosRequest)
        let value = defaults.string(forKey: myGroupViewController.defaultKeys.getRequest)
        let type = defaults.integer(forKey: myGroupViewController.defaultKeys.numberSegment)
        
        // если это первый раз реализации функции
        if previousValue == nil{
            previousValue = value
            defaults.set(value, forKey: myGroupViewController.defaultKeys.previosRequest)
            
        }
        
        if (previousValue != value){
            //тут код на случай смены значения
            //print("Group change from: \(String(describing: previousValue)) to: \(String(describing: value))")
            defaults.set(value, forKey: myGroupViewController.defaultKeys.previosRequest)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame.origin.x += self.tableView.frame.width
            })
            
            indicator?.startAnimating()
            DispatchQueue.global(qos: .background).async {
                self.getTimeTable(myURL: self.URLTimeTable+self.generationGetRequets(type: type, value: value!))
                DispatchQueue.main.async {
                    self.navigationItem.title = UserDefaults.standard.string(forKey: myGroupViewController.defaultKeys.groupName)
                    self.tableView.reloadData()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.tableView.frame.origin.x -= self.tableView.frame.width
                    })
                    self.indicator?.stopAnimating()
                }
            }
            
        } else {
            //print("Group no change")
        }
    }
    
    
    @IBAction func nextWeak(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        let type = defaults.integer(forKey: myGroupViewController.defaultKeys.numberSegment)
        let value = defaults.string(forKey: myGroupViewController.defaultKeys.getRequest)
        
        print(URLTimeTable+generationGetRequets(type: type, value: value!)+converDateForString(day: day, month: month, year: year))
        
        let viewController: myTimeTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "timeTable" ) as! myTimeTableViewController
        
        viewController.day = day
        viewController.month = month
        viewController.year = year
        viewController.showCurrentDay = false
        viewController.showAlertLoading = true
        viewController.presentMode = self.presentMode
        
        self.navigationController!.pushViewController(viewController, animated:true)
        
    }
    
    
    func getCurrentDate() -> Void{
        
        //получаем текущую дату устройства
        let date = NSDate()
        let calendar = NSCalendar.current
        day = calendar.component(.day, from: date as Date)
        month = calendar.component(.month, from: date as Date)
        year = calendar.component(.year, from: date as Date)
        
        //print(" Current day = \(day) \n Current month = \(month) \n Current year = \(year)")
        
    }
    
    //получение расписания на две недели вперёд
    func plus14DayForWeak()->Void{
        
        //для получения количества дней в месяце
        let dateComponent = DateComponents(year:year,month:month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponent)!
        let range = calendar.range(of: .day, in: .month, for: date)
        let numDays = range?.count
        //print("Count day in month: \(numDays!)")
        
        //прибавляем 14 дней
        if day+14 > numDays! {
            day = (day+14) - numDays!
            if month + 1 > 12{
                year+=1
                month = 1
            } else {
                month += 1
            }
        } else {
            day += 14
        }
        
    }
    
    //выполняет преобразование даты для get запроса на сайт http://www.rsvpu.ru
    func converDateForString(day:Int,month:Int,year:Int) -> String {
        
        var stringDate = ""
        
        if day < 10 {
            stringDate += "0\(day)."
        } else {
            stringDate += "\(day)."
        }
        
        if month < 10 {
            stringDate += "0\(month)."
        } else {
            stringDate += "\(month)."
        }
        
        stringDate += String(year)
        
        return stringDate
        
    }
    
    //формируем get запрос
    func generationGetRequets(type:Int, value:String) -> String{
        var getRequest:String = "?"
        if type == 0{
            getRequest += "v_gru="
        } else if type == 1{
            getRequest += "v_prep="
        } else if type == 2{
            getRequest += "v_aud="
        }
        
        getRequest += value
        getRequest += "&v_date="
        
        
        return getRequest
    }
    
    // потянуть чтобы обновить
    @objc func handlerRefresh(_ refresh:UIRefreshControl){
        
        navigationItem.title = UserDefaults.standard.string(forKey: myGroupViewController.defaultKeys.groupName)
        
        DispatchQueue.global(qos: .background).async {
            
            let defaults = UserDefaults.standard
            let type = defaults.integer(forKey: myGroupViewController.defaultKeys.numberSegment)
            let value = defaults.string(forKey: myGroupViewController.defaultKeys.getRequest)
            
            //print("type: \(type)    value: \(value!)")
            
            self.getTimeTable(myURL: self.URLTimeTable+self.generationGetRequets(type: type, value: value!)+self.converDateForString(day: self.day, month: self.month, year: self.year))
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing();
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TimeTable.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let pushViewController = self.storyboard!.instantiateViewController(withIdentifier: "timeTableOneDay") as! TimeTableOneDayVC
        pushViewController.TimeTable = TimeTable[indexPath.row]
        
        self.navigationController!.pushViewController(pushViewController, animated:true)
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        
        let maskLayer = CAShapeLayer()
        let bounds = cell.bounds
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 3, y: 3, width: bounds.width-6, height: bounds.height-8), cornerRadius: 5).cgPath
        cell.layer.mask = maskLayer
        
        
        if showCurrentDay {
            if(indexPath.row == dayOfWeek)||((dayOfWeek == -1)&&(indexPath.row == 6)){
                cell.txt_day?.textColor = UIColor.red.withAlphaComponent(0.5)
                cell.img_today.isHidden = false
                
            } else {
                cell.backgroundColor = UIColor.clear
                cell.txt_day?.textColor = UIColor.black
                cell.img_today.isHidden = true
            }}
        
        cell.txt_day?.text = TimeTable[indexPath.row].nameOfDay!
        cell.txt_date?.text = TimeTable[indexPath.row].date!
        
        
        let row = indexPath.row
        var tt = TimeTable[row].lessons
        let color = UIColor(red:0.850,green:0.850,blue:0.850, alpha: 1.0)
        
        cell.txt_time1?.text = tt[0].time[0]
        cell.txt_time2?.text = tt[1].time[0]
        cell.txt_time3?.text = tt[2].time[0]
        cell.txt_time4?.text = tt[3].time[0]
        cell.txt_time5?.text = tt[4].time[0]
        cell.txt_time6?.text = tt[5].time[0]
        cell.txt_time7?.text = tt[6].time[0]
        
        cell.txt_subject1?.text = tt[0].lesson[0]
        cell.txt_subject2?.text = tt[1].lesson[0]
        cell.txt_subject3?.text = tt[2].lesson[0]
        cell.txt_subject4?.text = tt[3].lesson[0]
        cell.txt_subject5?.text = tt[4].lesson[0]
        cell.txt_subject6?.text = tt[5].lesson[0]
        cell.txt_subject7?.text = tt[6].lesson[0]
        
        if tt[0].lesson[0] != "-"{
            cell.lbl_class1.isHidden = false
            cell.lbl_prep1.isHidden = false
            cell.lbl_prep1.text = tt[0].teacher[0].teacher
            cell.lbl_class1.text = tt[0].classRoom[0].classRoom
            cell.txt_subject1.backgroundColor = color
        }else {
            cell.txt_subject1.backgroundColor = .clear
            cell.lbl_class1.isHidden = true
            cell.lbl_prep1.isHidden = true
        }
        
        if tt[1].lesson[0] != "-"{
            cell.lbl_class2.isHidden = false
            cell.lbl_prep2.isHidden = false
            cell.lbl_class2.text = tt[1].classRoom[0].classRoom
            cell.lbl_prep2.text = tt[1].teacher[0].teacher
            cell.txt_subject2.backgroundColor = color
        } else {
            cell.txt_subject2.backgroundColor = .clear
            cell.lbl_class2.isHidden = true
            cell.lbl_prep2.isHidden = true
        }
        
        if tt[2].lesson[0] != "-"{
            cell.lbl_class3.isHidden = false
            cell.lbl_prep3.isHidden = false
            cell.lbl_class3.text = tt[2].classRoom[0].classRoom
            cell.lbl_prep3.text = tt[2].teacher[0].teacher
            cell.txt_subject3.backgroundColor = color
        }else {
            cell.txt_subject3.backgroundColor = .clear
            cell.lbl_class3.isHidden = true
            cell.lbl_prep3.isHidden = true
        }
        
        if tt[3].lesson[0] != "-"{
            cell.lbl_class4.isHidden = false
            cell.lbl_prep4.isHidden = false
            cell.lbl_class4.text = tt[3].classRoom[0].classRoom
            cell.lbl_prep4.text = tt[3].teacher[0].teacher
            cell.txt_subject4.backgroundColor = color
        }else {
            cell.txt_subject4.backgroundColor = .clear
            cell.lbl_class4.isHidden = true
            cell.lbl_prep4.isHidden = true
        }
        
        if tt[4].lesson[0] != "-"{
            cell.lbl_class5.isHidden = false
            cell.lbl_prep5.isHidden = false
            cell.lbl_class5.text = tt[4].classRoom[0].classRoom
            cell.lbl_prep5.text = tt[4].teacher[0].teacher
            cell.txt_subject5.backgroundColor = color
        }else {
            cell.txt_subject5.backgroundColor = .clear
            cell.lbl_class5.isHidden = true
            cell.lbl_prep5.isHidden = true
        }
        
        if tt[5].lesson[0] != "-"{
            cell.lbl_class6.isHidden = false
            cell.lbl_prep6.isHidden = false
            cell.lbl_class6.text = tt[5].classRoom[0].classRoom
            cell.lbl_prep6.text = tt[5].teacher[0].teacher
            cell.txt_subject6.backgroundColor = color
            
        }else {
            cell.txt_subject6.backgroundColor = .clear
            cell.lbl_class6.isHidden = true
            cell.lbl_prep6.isHidden = true
        }
        
        if tt[6].lesson[0] != "-"{
            cell.lbl_class7.isHidden = false
            cell.lbl_prep7.isHidden = false
            cell.lbl_class7.text = tt[6].classRoom[0].classRoom
            cell.lbl_prep7.text = tt[6].teacher[0].teacher
            cell.txt_subject7.backgroundColor = color
        }else {
            cell.txt_subject7.backgroundColor = .clear
            cell.lbl_class7.isHidden = true
            cell.lbl_prep7.isHidden = true
        }
        
        return cell
    }
    
    func createIndicator()->UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return indicator
    }
    
    func getTimeTable(myURL:String) -> Void {
        dayOfWeek = Calendar.current.component(.weekday, from: Date()) - 2
        let my_URL = URL(string:myURL)
        HTMLFromPage = getHTMLString(url: my_URL!)
        
        if(HTMLFromPage != "Error"){
            let defaults = UserDefaults.standard
            defaults.set(HTMLFromPage, forKey: "html")
            defaults.synchronize()
            parsingTimeTable()
        }
        
        print("day of week",dayOfWeek!);
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.dayOfWeek != -1 ? self.dayOfWeek!:6, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        //устанавливаем задний фон для таблицы
        self.tableView.backgroundColor = UIColor.init(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
    }
    
    @discardableResult
    func parsingTimeTable()->Int64{
        TimeTable.removeAll()
        let startFuncTime = Int64(Date().timeIntervalSince1970 * 1000)
        var TimeTableUncorrect = [TimeTableOneDay]()
        
        if let docHtml = try? HTML(html: HTMLFromPage!, encoding: String.Encoding.utf8){
            var i = 0
            
            
            //получаем один день из расписания
            for timeTable in docHtml.css("td[class='disciplina ']"){
                TimeTableUncorrect.append(getOneDayFromXML(XML: timeTable))
                // print("\n")
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
            
        }
        
        let stopFuncTime = Int64(Date().timeIntervalSince1970 * 1000)
        //print("Функция парсинга html выполнилась за: \(stopFuncTime-startFuncTime) mlSec \(Double((stopFuncTime-startFuncTime)/1000)) Sec")
        return stopFuncTime-startFuncTime
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
        // print("Count lesson: \(countLesson)")
        return timeTableDay
    }
    
    //получаем один предмет
    func getOneLesson(XML:XMLElement) -> TimeTableOneLesson {
        let timeTableLesson = TimeTableOneLesson()
        
        var countGroup = 0
        //кортеж, хранящий в себе номер кабинета и ссылку на него
        var classRoom = [(String,String)]()
        //кортеж, хранящий в себе имя учителя и ссылку на него
        var teacher = [(String,String)]()
        
        for lessons in XML.css("p"){
            //получили название предмета
            let lesson = getLessonName(str:lessons.text!)
            let typeOfLesson = getLessonType(str: lessons.text!)
            timeTableLesson.lesson.append(lesson)
            timeTableLesson.typeOfLesson.append(typeOfLesson)
            //print(lesson)
            
            var number = 0
            
            
            //кортеж, который заполняется в цикле
            var corteg:(String,String) = (" "," ")
            
            for other in lessons.css("nobr"){
                
                if other.text != "" {
                    number+=1
                    
                    
                    if number == 1{
                        corteg.0 = other.text!
                    }
                    if number == 2{
                        corteg.0 = other.text!
                    }
                    
                    
                    if other.at_css("a")?["href"] != nil {
                        
                        if number == 1{
                            corteg.1 = (other.at_css("a")?["href"])!
                            classRoom.append(corteg)
                        }
                        if number == 2 {
                            corteg.1 = (other.at_css("a")?["href"])!
                            teacher.append(corteg)
                        }
                    }
                    
                    if number == 3 {
                        timeTableLesson.podGroup.append(other.text!)
                        number = 0
                    }
                }
                
            }
            countGroup+=1
        }
        
        timeTableLesson.teacher = teacher
        timeTableLesson.classRoom = classRoom
        
        if countGroup > 1{
            timeTableLesson.haveManyGroup = true
        } else {
            timeTableLesson.haveManyGroup = false
        }
        
        //print("Count Group in lesson: \(countGroup)")
        
        return timeTableLesson
    }
    
    //получаем название предмета без группы, номера кабинета
    func getLessonName(str:String)->String{
        let char:Character = "("
        
        if let idx = str.index(of: char){
            
            let returnedString = String(str[idx...])
            return returnedString
        } else {
            return str
        }
    }
    
    //получаем тип предмета
    func getLessonType(str:String)->String{
        let charStart:Character = "(", charEnd:Character = ")"
        
        if let idxStart = str.index(of: charStart){
            let idxEnd = str.index(of: charEnd)
            let typeOfLessonDirty = str[idxStart...idxEnd!]
            let typeOfLesson = typeOfLessonDirty.replacingOccurrences(of: "(", with: " ").replacingOccurrences(of: ")", with: " ")
            
            return typeOfLesson
        }
        else {
            return "no type"
        }
    }
    
    func getHTMLString(url:URL) -> String {
        
        do {
            offlineMode = false
            let myHTMLString = try String(contentsOf: url, encoding: .utf8)
            return myHTMLString
        } catch {
            offlineMode = true
            let alert = UIAlertController(title:"Ошибка", message: "Произошла какая-то ошибка. Скорее всего отсутствует подключение к интренету.\nЯ могу загрузить последнее сохранившееся расписание", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title:"Пропустить",style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title:"Последнее расписание", style:UIAlertAction.Style.cancel, handler:{action in self.loadTimetableOld()}))
            self.present(alert, animated: true, completion: nil)
            self.refreshControl?.endRefreshing()
            return "Error"
        }
        
    }
    
    //загрузка последнего сохранённого расписания
    func loadTimetableOld() -> Void {
        HTMLFromPage = UserDefaults.standard.string(forKey:"html")
        parsingTimeTable()
        self.tableView.reloadData()
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
        var typeOfLesson = [String]()
        
        var time = [String]()
        
        var podGroup = [String]()
        
        var classRoom = [(classRoom:String,classRoomRequest:String)]()
        var teacher = [(teacher:String,teacherRequest:String)]()
        
        init(){}
        
    }
    
    
    //метод для получения среднего времени парсинга расписания 20.02.2017
    func debugTimeTablePareser()->Void{
        print("Выполняется сбор данных для отладки")
        for _ in 0..<50{
            self.parsingTime += parsingTimeTable()
        }
        print("Ср. время парсинга 50 раз: \(parsingTime/50)")
    }
    
}
