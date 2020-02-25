//
//  DetailViewController.swift
//  Project 1
//
//  Created by Andres Vazquez on 2019-12-09.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var titleLabel: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = titleLabel
        navigationItem.largeTitleDisplayMode = .never
        
        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.hidesBarsOnTap = false
    }
}
