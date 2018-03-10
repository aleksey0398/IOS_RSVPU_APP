//
//  AdvertisementVC.swift
//  RSVPU
//
//  Created by Алексей Митькин on 19.02.17.
//  Copyright © 2017 alekseymitkin.ru. All rights reserved.
//

import UIKit

class AdvertisementVC: NewsVC {
    
    

    override func viewDidLoad() {
        URLweb = "http://www.rsvpu.ru/notices/"
        loadingMessage = "Загрузка объявлений"
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
