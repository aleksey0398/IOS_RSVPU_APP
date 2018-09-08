//
//  myGroupViewController.swift
//  RSVPU
//
//  Created by Алексей Митькин on 31.01.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit
import Kanna

class myGroupViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var URL_TimeTable = "http://www.rsvpu.ru/raspisanie-zanyatij-ochnoe-otdelenie/"
    
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var mySelector: UISegmentedControl!
    @IBOutlet weak var myPickerGroup: UIPickerView!
    @IBOutlet weak var myLabelSelectedGroup: UILabel!
    @IBOutlet weak var tableSearchResult: UITableView!
    @IBOutlet weak var closeSearch: UIButton!
    
    let animationDiration = 0.2
    
    var timeTableElements = [elementsTimeTable]()
    
    var searchedElements = [elementsTimeTable]()
    
    //аргументы для получения списка елементов расписания
    //0: группа
    //1: преподаватели
    //2: кабинеты
    let arguments = ["option[name='gr']","option[name='prep']","option[name='aud']"]
    
    struct defaultKeys{
        static let groupURL = "URLGroup"
        static let groupNumber = "NumberOfGroup"
        static let groupName = "NameOfGroup"
        static let numberSegment = "SavedSegment"
        static let savePosition = "SavePosition"
        static let getRequest = "getRequest"
        static let type = "type"
        static let previosRequest = "previousRequest"
    }
    
    //struct for array
    struct elementsTimeTable{
        var name:String
        var getRequest:String
        var type:Int
        var position:Int
    }
    
    /*
     * тут обрабативаем события при нажатии на "поиск"
     *
     *
     *
     *
     *
     *
     *
     */
    
    @IBAction func searchStart(_ sender: Any) {
        tableSearchResult.isHidden = false
        
        let widthForSearch = field.frame.width - closeSearch.frame.width - 10
        
        UIView.animate(withDuration: animationDiration, animations: {
            self.field.frame.size.width = widthForSearch
            self.closeSearch.center.x -= 76
        })
        
        
        
    }
    
    //обработка нажатия кнопки "закрыть" в поиске
    @IBAction func closeSearch(_ sender: Any) {
        tableSearchResult.isHidden = true
        UIView.animate(withDuration: animationDiration, animations: {
            self.closeSearch.center.x += 76
            self.field.resignFirstResponder()
        })
        
        
    }
    
    
    
    @IBAction func search(_ sender: Any) {
        searching()
    }
    
    func searching()->Void{
          searchedElements.removeAll()
        
        var hasResult = false
        
        for i in 0..<timeTableElements.count{
            
            if timeTableElements[i].name.lowercased().range(of: field.text!.lowercased()) != nil{
                print(timeTableElements[i].name)
                searchedElements.append(timeTableElements[i])
                hasResult = true
            }
        }
        if !hasResult{
            print("Нет результатов")
            searchedElements.append(elementsTimeTable(name: "Нет результатов", getRequest: "empty", type: -1 ,position: -1))
        }
        tableSearchResult.reloadData()
    }
    
    /*
     *
     *
     *
     *
     *
     *
     */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeTableElements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeTableElements[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        myLabelSelectedGroup.text = timeTableElements[row].name
        if timeTableElements[row].getRequest == "empty" || timeTableElements[row].getRequest == ""{
            myPickerGroup.selectRow(row+1, inComponent: 0, animated: true)
            saveGroupURL(row: row+1)
        } else {
            saveGroupURL(row: row)
        }
    }
    
    
    /*
     *
     *
     *
     *
     *
     *
     *
     *
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedElements.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = searchedElements[row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableSearchResult.deselectRow(at: indexPath, animated: true)
        let n = searchedElements[indexPath.row].getRequest
        print("Request from selected item: \(n)")
        
        if n == "" || n == "empty"{
            print("Не будем обрабатывать это дерьмо")
        } else{
            print("Всё огонь! Сейчас будет!")
            
        }
        
        if n == "" || n == "empty"{
            print("По непонятным причинам пришлось обработку дедать через ==, а не через != ")
        } else {
            
            UIView.animate(withDuration: animationDiration, animations: {
                self.field.resignFirstResponder()
                self.closeSearch.center.x += 76
            })
            myLabelSelectedGroup.text = searchedElements[indexPath.row].name
            saveGroupFromSearching(elementForSave: searchedElements[indexPath.row])
            myPickerGroup.selectRow(searchedElements[indexPath.row].position, inComponent: 0, animated: true)
        }
    }
    
    //функция для сохранения выбранной группы
    func saveGroupURL(row:Int)->Void{
        let defaults = UserDefaults.standard
        
        defaults.set(defaults.string(forKey: defaultKeys.getRequest), forKey: defaultKeys.previosRequest)
        defaults.set(row, forKey: defaultKeys.groupNumber)
        defaults.set(timeTableElements[row].getRequest, forKey: defaultKeys.getRequest)
        defaults.set(timeTableElements[row].type, forKey: defaultKeys.type)
        defaults.set(timeTableElements[row].name, forKey: defaultKeys.groupName)
        
        
        defaults.synchronize()
        
    }
    
    func saveGroupFromSearching(elementForSave:elementsTimeTable) -> Void {
        let defaults = UserDefaults.standard
        
        defaults.set(defaults.string(forKey: defaultKeys.getRequest), forKey: defaultKeys.previosRequest)
        defaults.set(elementForSave.name, forKey: defaultKeys.groupName)
        defaults.set(elementForSave.getRequest, forKey: defaultKeys.getRequest)
        defaults.set(elementForSave.position, forKey: defaultKeys.groupNumber)
        
        defaults.synchronize()
    }
    
    //получаем необходимые элементы
    //парсинг html
    func getSelectedSegment(selected:Int) -> Void {
        timeTableElements.removeAll()
        searchedElements.removeAll()
        let htmlPage = UserDefaults.standard.string(forKey: "html")
        
        if let docHTML = try? HTML(html: htmlPage!, encoding: String.Encoding.utf8) {
            
            var i = 0
            
            for element in docHTML.css(arguments[selected]){
                //проверка на пустую строку
                if element.text! != ""{
                    
                    var elementCollection = elementsTimeTable(name: element.text!, getRequest:"empty", type: mySelector.selectedSegmentIndex,position: i)
                    
                    //если элемент содержит в HTML "value", то выводим значени
                    if element.toHTML?.range(of: "value") != nil{
                        //print(element["value"]!)
                        elementCollection.getRequest = element["value"]!
                    }
                    timeTableElements.append(elementCollection)
                    i+=1
                }
                
            }
        }
        
    }
    
    //обработка выбора сегментов
    @IBAction func changeSelector(_ sender: Any) {
        print("Segment selected: \(mySelector.selectedSegmentIndex)")
        
        let defaults = UserDefaults.standard
        defaults.set(mySelector.selectedSegmentIndex, forKey: defaultKeys.numberSegment)
        defaults.synchronize()
        
        print(mySelector.selectedSegmentIndex)
        getSelectedSegment(selected: mySelector.selectedSegmentIndex)
        searching()
        
        myPickerGroup.reloadAllComponents()
        myPickerGroup.selectRow(0, inComponent: 0, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //get last position of saved group
        let savePos = UserDefaults.standard.integer(forKey: defaultKeys.groupNumber)
        let savePosSegment = UserDefaults.standard.integer(forKey: defaultKeys.numberSegment)
        mySelector.selectedSegmentIndex = savePosSegment
        getSelectedSegment(selected: savePosSegment)
        myLabelSelectedGroup.text = UserDefaults.standard.string(forKey: defaultKeys.groupName)
        myPickerGroup.selectRow(savePos, inComponent: 0, animated: true)
        tableSearchResult.isHidden = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
