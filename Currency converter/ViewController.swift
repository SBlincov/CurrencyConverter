//
//  ViewController.swift
//  Currency converter
//
//  Created by Блинцов Сергей on 09/02/2018.
//  Copyright © 2018 Блинцов Сергей. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Тут будет курс"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

