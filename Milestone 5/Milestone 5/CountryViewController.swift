//
//  CountryViewController.swift
//  Milestone 5
//
//  Created by Andres Vazquez on 2020-02-26.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class CountryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var flag: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    var country: Country?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        
        _ = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if let country = country {
            title = country.name
            
            setupViews()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let country = country else {
            fatalError("No country selected")
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        
        flag.image = UIImage(named: country.flag)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = country.name
        case 1:
            cell.textLabel?.text = "Capital"
            cell.detailTextLabel?.text = country.capital
        case 2:
            cell.textLabel?.text = "Area"
            cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: country.area))! + " km²"
        case 3:
            cell.textLabel?.text = "Population"
            cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: country.population))!
        default:
            break
        }
        
        return cell
    }
    
    private func setupViews() {
        view.addSubview(flag)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            flag.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flag.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            flag.widthAnchor.constraint(equalToConstant: 375),
            flag.heightAnchor.constraint(equalTo: flag.widthAnchor, multiplier: 4/7)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: flag.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
