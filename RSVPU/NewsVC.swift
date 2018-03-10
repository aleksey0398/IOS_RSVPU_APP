//
//  NewsVC.swift
//  RSVPU
//
//  Created by Алексей Митькин on 19.02.17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import Kanna

class NewsVC: UITableViewController {
    
    var URLweb = "http://www.rsvpu.ru/news/"
    var loadingMessage = "Загрузка новостей"
    
    var html:String?
    
    var news = [newsRSVPU]()
    
    var indicator:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = createIndicator()
        indicator?.startAnimating()
        //self.present(AlertLoadingFunc(), animated: false, completion: nil)
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.refreshControl?.addTarget(self, action: #selector(NewsVC.handlerRefresh(_:)), for: UIControlEvents.valueChanged)
        
        if news.count == 0{
            
            DispatchQueue.global(qos: .background).async {
                self.getNewsHTML()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicator?.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            }
            // self.getNewsHTML()
            // self.tableView.reloadData()
            // self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    func createIndicator()->UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return indicator
    }
    
    func createErrorAelrt(title:String, message:String)->UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default, handler: nil))
        
        return alert
    }
    
    func getNewsHTML()->Void{
        let url_news = URL(string: URLweb)
        self.html = getHTMLString(url: url_news!)
        parseNews()
        self.tableView.backgroundColor = UIColor.init(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
    }
    
    func getHTMLString(url:URL) -> String {
        
        do {
            let myHTMLString = try String(contentsOf: url, encoding: .utf8)
            return myHTMLString
        } catch let error {
            print("Error: \(error)")
            self.present(createErrorAelrt(title: "Ошибка", message: error.localizedDescription), animated: true, completion: nil)
            return error.localizedDescription
        }
        
    }
    
    func handlerRefresh(_ refresh:UIRefreshControl){
        
        DispatchQueue.global(qos: .background).async {
            self.getNewsHTML()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
        }
        
        
    }
    
    func parseNews()->Void {
        news.removeAll()
        if let docHtml = Kanna.HTML(html: html!, encoding:String.Encoding.utf8){
            for news in docHtml.css("dl[class='localNewsArtc']"){
                print("====new news====")
                let date = news.at_css("dt")?.text ?? "error time"
                print(date)
                let title = news.at_css("dd[class='newsname']")?.text ?? "error news"
                print(title)
                let url = news.at_css("a")?["href"]
                print(url ?? "error url")
                let urlImage = news.at_css("img")?["src"]
                
                let imageURL = URL(string: urlImage!)
                
                var textNews:String?
                for text in news.css("dd"){
                    if text.text! != ""{
                        textNews = text.text!
                        print(textNews!)
                    }
                }
                self.news.append(newsRSVPU(title: title, date: date, text: textNews!, urlGetNews: url!, urlImage:imageURL!))
                print("==================="+"\n")
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return news.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myNewsCell", for: indexPath) as! myNewsCell
        
        cell.myLabel_title.layer.masksToBounds = true
        cell.myLabel_title.layer.cornerRadius = 4
        
        let maskLayer = CAShapeLayer()
        let bounds = cell.bounds
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 3, y: 3, width: bounds.width-6, height: bounds.height-7), cornerRadius: 5).cgPath
        cell.layer.mask = maskLayer
        
        let row = indexPath.row
        cell.myLabel_date.text = news[row].date
        cell.myLabel_title.text = news[row].title
        cell.myLabel_textNews.text = news[row].text
        
        
        if !news[row].imageIsLoad{
            cell.img.alpha = 0
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: self.news[row].urlImage!)
                
                DispatchQueue.main.async {
                    let img = UIImage(data:data!)
                    cell.img.image = img
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.img.alpha = 1
                    })
                    self.news[row].imageIsLoad = true
                    
                    self.news[row].image = img
                }
                
            }
            
        } else {
            cell.img.image = news[row].image!
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController: ShowNewsVC = self.storyboard!.instantiateViewController(withIdentifier: "ShowNews" ) as! ShowNewsVC
        
        viewController.urlNews = news[indexPath.row].urlGetNews
        
        self.navigationController!.pushViewController(viewController, animated:true)
        //self.present(viewController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func showCategory(_ sender: Any) {
        let popeverViewController = self.storyboard?.instantiateViewController(withIdentifier:"popever") as UIViewController!
        popeverViewController?.modalPresentationStyle = .popover
        popeverViewController?.preferredContentSize = CGSize.init(width: 600, height: 600)

        let viewController = popeverViewController?.popoverPresentationController
    
        viewController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        
        
        present(popeverViewController!, animated: true, completion: nil)
    }
    
    
    class newsRSVPU {
        var title:String?
        var date:String?
        var text:String?
        var urlGetNews:String?
        var urlImage:URL?
        var imageIsLoad = false
        var image:UIImage?
        
        init() {
        }
        
        init(title:String, date:String, text:String, urlGetNews:String,urlImage:URL) {
            self.date = date
            self.title = title
            self.text = text
            self.urlGetNews = urlGetNews
            self.urlImage = urlImage
        }
    }
    
}
