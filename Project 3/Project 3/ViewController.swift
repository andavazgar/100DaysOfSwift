//
//  ViewController.swift
//  Project 3
//
//  Created by Andres Vazquez on 2019-12-09.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var pictures = [String]()
    private let cellID = "PictureCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        
        let fm = FileManager.default
        let resourcePath = Bundle.main.resourcePath! // iOS always have a resourcePath
        let items = try! fm.contentsOfDirectory(atPath: resourcePath)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        pictures = pictures.sorted()
    }
}


// MARK: - TableView methods

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.selectedImage = pictures[indexPath.row]
            detailVC.titleLabel = "Picture \(indexPath.row + 1) of \(pictures.count)"
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

