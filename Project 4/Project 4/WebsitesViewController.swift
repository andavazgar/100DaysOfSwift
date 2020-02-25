//
//  WebsitesViewController.swift
//  Project 4
//
//  Created by Andres Vazquez on 2019-12-11.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class WebsitesViewController: UITableViewController {
    
    let websites = ["9to5mac.com", "apple.com", "jw.org"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Easy Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "websiteCell", for: indexPath)
        
        cell.textLabel?.text = websites[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let browserVC = storyboard?.instantiateViewController(identifier: "BrowserViewController") as? BrowserViewController {
            browserVC.websites = websites
            browserVC.chosenWebsite = websites[indexPath.row]
            
            navigationController?.pushViewController(browserVC, animated: true)
        }
    }
}
