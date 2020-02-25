//
//  Petition.swift
//  Project 7
//
//  Created by Andres Vazquez on 2019-12-15.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import Foundation

struct Petition: Codable {
    let title: String
    let body: String
    let signatureCount: Int
}
