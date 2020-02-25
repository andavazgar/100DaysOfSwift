//
//  ViewController.swift
//  Milestone 2
//
//  Created by Andres Vazquez on 2019-12-15.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var shoppingList = [ShoppingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping List"
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationController?.isToolbarHidden = false
        
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        
        toolbarItems = [share, flexibleSpace, trash]
    }
    
    @objc private func trashTapped() {
        let alertCtrl = UIAlertController(title: "Clear list?", message: "Are you sure that you want to clear the shopping list?", preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { [weak self] _ in
            self?.clearList()
        }))
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertCtrl, animated: true)
    }
    
    @objc private func shareTapped() {
        let list = shoppingList.map({ $0.bought ? "- [x] \($0.name)" : "- [ ] \($0.name)"}).joined(separator: "\n")

        let activityCtrl = UIActivityViewController(activityItems: [list], applicationActivities: nil)
        activityCtrl.popoverPresentationController?.barButtonItem = toolbarItems![0]
        
        present(activityCtrl, animated: true)
    }
    
    
    @objc private func addTapped() {
        let alertCtrl = UIAlertController(title: "Add item", message: nil, preferredStyle: .alert)
        alertCtrl.addTextField()
        alertCtrl.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak alertCtrl] _ in
            if let item = alertCtrl?.textFields?[0].text {
                let shoppingItem = ShoppingItem(name: item, bought: false)
                self?.addItem(shoppingItem)
            }
        }))
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertCtrl, animated: true)
    }
    
    private func clearList() {
        shoppingList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    private func addItem(_ item: ShoppingItem) {
        shoppingList.append(item)
        
        let index = IndexPath(row: shoppingList.count - 1, section: 0)
        tableView.insertRows(at: [index], with: .automatic)
    }
}


// MARK: - UITableView DataSource methods

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)
        
        cell.textLabel?.text = shoppingList[indexPath.row].name
        cell.accessoryType = shoppingList[indexPath.row].bought ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shoppingList[indexPath.row].bought.toggle()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = shoppingList[indexPath.row].bought ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = shoppingList[sourceIndexPath.row]
        shoppingList.remove(at: sourceIndexPath.row)
        shoppingList.insert(item, at: destinationIndexPath.row)
    }
}

