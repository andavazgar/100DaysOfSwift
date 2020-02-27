//
//  Capital.swift
//  Project 16
//
//  Created by Andres Vazquez on 2020-02-27.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var wikiPageURL: String?
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, wikiPageURL: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.wikiPageURL = wikiPageURL
    }
}
