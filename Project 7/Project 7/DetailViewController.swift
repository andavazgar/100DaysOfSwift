//
//  DetailViewController.swift
//  Project 7
//
//  Created by Andres Vazquez on 2019-12-15.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webview: WKWebView!
    var petition: Petition?
    
    override func loadView() {
        webview = WKWebView()
        view = webview
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let petition = petition {
            let htmlString = """
                <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <style> body { font-size: 120%; } </style>
                </head>
                <body>
                    <h1>\(petition.title)</h1>
                    \(petition.body)
                </body>
                </html>
            """
            
            webview.loadHTMLString(htmlString, baseURL: nil)
        }

        // Do any additional setup after loading the view.
    }
}
