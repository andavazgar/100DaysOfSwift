//
//  DetailViewController.swift
//  Milestone 1
//
//  Created by Andres Vazquez on 2019-12-11.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var flagImageView: UIImageView!
    var selectedFlag: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedFlag = selectedFlag {
            flagImageView.image = UIImage(named: selectedFlag)
            flagImageView.layer.borderWidth = 1
            flagImageView.layer.borderColor = UIColor.lightGray.cgColor
            
            title = selectedFlag.uppercased()
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFlag))
        }
    }
    
    @objc private func shareFlag() {
        if let image = flagImageView.image?.pngData(), let imageName = selectedFlag {
            let activityVC = UIActivityViewController(activityItems: [image, imageName.uppercased()], applicationActivities: [])
            activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            
            present(activityVC, animated: true)
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
