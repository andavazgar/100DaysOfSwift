//
//  SavedScriptsTableViewController.swift
//  Extension
//
//  Created by Andres Vazquez on 2020-03-02.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class SavedScriptsTableViewController: UITableViewController {
    
    var scriptsLibrary = ScriptsLibrary.getSavedScripts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = self.editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewScript))
        
        title = "Saved Scripts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scriptsLibrary = ScriptsLibrary.getSavedScripts()
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptsLibrary.scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scriptCell", for: indexPath)
        
        let script = scriptsLibrary.scripts[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        cell.textLabel?.text = script.name
        cell.detailTextLabel?.text = dateFormatter.string(from: script.dateModified)
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let scriptName = scriptsLibrary.scripts[indexPath.row].name
            let ac = UIAlertController(title: "Confirmation", message: "Are you sure that you want to delete the script \"\(scriptName)\"?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.scriptsLibrary.deleteScript(atIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    
    // MARK: - UITableViewDelegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "scriptEditorVC") as? ActionViewController else { return }
        vc.script = scriptsLibrary.scripts[indexPath.row]
        vc.scriptIndex = indexPath.row
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Custom methods
    @objc private func createNewScript() {
        guard let vc = storyboard?.instantiateViewController(identifier: "scriptEditorVC") else { return }
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
