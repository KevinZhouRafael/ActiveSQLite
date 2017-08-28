//
//  ViewController.swift
//  Sample
//
//  Created by yuhan on 20/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import UIKit
import ActiveSQLite

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let model:DBModel = DBModel()
         DBModel.createTable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

