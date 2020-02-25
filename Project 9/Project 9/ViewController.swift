//
//  ViewController.swift
//  Project 7
//
//  Created by Andres Vazquez on 2019-12-15.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let urlStrings = ["https://api.whitehouse.gov/v1/petitions.json?limit=100", "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"]
    var apiURLIndex: Int!
    var petitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoBtnTapped))
        
        if  navigationController?.tabBarItem.tag == 0 {
            title = "Recent Petitions"
            apiURLIndex = 0
        }
        else {
            title = "Top Petitions"
            apiURLIndex = 1
        }
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc private func fetchJSON() {
        if let url = URL(string: urlStrings[apiURLIndex]) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    private func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc private func showError() {
        let alertCtrl = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default))
        
        alertCtrl.present(alertCtrl, animated: true)
    }
    
    @objc private func infoBtnTapped() {
        let alertCtrl = UIAlertController(title: "Information", message: "The data comes from the 'We The People' API of the Whitehouse", preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertCtrl, animated: true)
    }
}


// MARK: - TableView methods

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetitionCell", for: indexPath)
        
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.petition = petitions[indexPath.row]
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
