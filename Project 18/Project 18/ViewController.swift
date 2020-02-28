//
//  ViewController.swift
//  Project 18
//
//  Created by Andres Vazquez on 2020-02-28.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I'm inside the viewDidLoad() method!")
        print(1, 2, 3, 4, 5, separator: "-")

        assert(1 == 1, "Maths failure!")

        for i in 1 ... 100 {
            print("Got number \(i)")
        }
    }


}

