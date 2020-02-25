//
//  ViewController.swift
//  Milestone 1
//
//  Created by Andres Vazquez on 2019-12-11.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private let cellID = "FlagCell"
    private let flags = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = flags[indexPath.row].uppercased()
        cell.imageView?.image = UIImage(named: flags[indexPath.row])
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController {
            detailVC.selectedFlag = flags[indexPath.row]
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

