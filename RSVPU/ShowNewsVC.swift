//
//  ShowNewsVC.swift
//  RSVPU
//
//  Created by Алексей Митькин on 19.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit
import Kanna

class ShowNewsVC: UIViewController {
    
    
    @IBOutlet weak var myWeb: UIWebView!
    
    var urlNews:String?
    var indicator:UIActivityIndicatorView?
    var label:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = createIndicator()
        indicator?.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            let html = self.getNews()
            DispatchQueue.main.async {
            self.myWeb.loadHTMLString(html, baseURL: nil)
            }
            
            
            DispatchQueue.main.async {
                self.indicator?.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        }
    }
    
    
    func getNews()->String{
        
        let urlNewsLocal = URL(string:urlNews!)
        var stringHTML = ""
        
        
        if let kannaDoc = try? HTML(html: getHTMLString(url: urlNewsLocal!), encoding: String.Encoding.utf8){
            let htmlFromPage = kannaDoc.at_css("div[class='content']")?.toHTML
            let gallery = kannaDoc.at_css("div[id='gallery']")?.toHTML
            let upTag = kannaDoc.at_css("p[class='upTag2']")?.toHTML
            
            let htmlWithOutUpTag = htmlFromPage?.replacingOccurrences(of: upTag!, with: "")
            stringHTML = htmlWithOutUpTag!
            
            if gallery != nil{
                let htmlWithOutGallery = htmlWithOutUpTag?.replacingOccurrences(of: gallery!, with: "")
                stringHTML = htmlWithOutGallery!
            }
            
           stringHTML = stringHTML.replacingOccurrences(of: "<img", with:"<img style=\"max-width: 100%; width: auto; height: auto\"")
            
        }
        //print(stringHTML)
        return stringHTML
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
    
    
    func createIndicator()->UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return indicator
    }
    
    
    @IBAction func sharedNews(_ sender: Any) {
        shared(url:urlNews!)
    }
    
    func shared(url:String) -> Void {
        
        // set up activity view controller
        let textToShare = [ url ]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
