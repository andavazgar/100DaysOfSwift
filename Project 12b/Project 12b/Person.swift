//
//  Person.swift
//  Project 12b
//
//  Created by Andres Vazquez on 2020-02-12.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class Person: Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
