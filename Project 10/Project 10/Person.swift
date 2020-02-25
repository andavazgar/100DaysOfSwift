//
//  Person.swift
//  Project 10
//
//  Created by Andres Vazquez on 2020-02-12.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
