//
//  DetailViewController.swift
//  Project 3
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        
        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
    }
    
    @objc private func shareImage() {
        guard let image = imageView.image?.pngData(), let imageName = selectedImage else {
            print("No image was found")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image, imageName], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityVC, animated: true)
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
