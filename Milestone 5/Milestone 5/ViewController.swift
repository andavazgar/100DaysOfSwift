//
//  ViewController.swift
//  Milestone 5
//
//  Created by Andres Vazquez on 2020-02-26.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var countries = [Country]()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Country Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadCountries()
        tableView.rowHeight = 70
    }
    
    
    // MARK: - TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as? CountryTableViewCell else {
            fatalError("Cell is not a CountryTableViewCell")
        }
        
        let country = countries[indexPath.row]
        cell.flag.image = UIImage(named: country.flag)
        cell.countryName.text = country.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CountryViewController()
        vc.country = countries[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Custom methods
    private func loadCountries() {
        guard let countriesFile = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            print("File (countries.json) not found.")
            return
            
        }
        guard let jsonData = try? Data(contentsOf: countriesFile) else {
            print("Could not load file as String.")
            return
            
        }
        
        let decoder = JSONDecoder()
        
        if let countriesArray = try? decoder.decode([Country].self, from: jsonData) {
            countries = countriesArray
            tableView.reloadData()
        }
    }
}

