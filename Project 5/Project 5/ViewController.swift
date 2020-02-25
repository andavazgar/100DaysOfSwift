//
//  ViewController.swift
//  Project 5
//
//  Created by Andres Vazquez on 2019-12-13.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var allWords = [String]()
    private var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtnTapped))
        
        loadWordsFromFile()
        loadData()
        
        if title == nil {
            startGame()
        }
    }

    private func loadWordsFromFile() {
        if let wordFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: wordFileURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords.append("starfish")
        }
    }
    
    @objc private func startGame() {
        if !usedWords.isEmpty {
            usedWords.removeAll(keepingCapacity: true)
            tableView.reloadData()
        }
        
        title = allWords.randomElement()
    }
    
    @objc private func addBtnTapped() {
        let alertVC = UIAlertController(title: "Add anagram", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField()
        alertVC.addAction(UIAlertAction(title: "Add word", style: .default) { [weak self, weak alertVC] _ in
            if let word = alertVC?.textFields?[0].text {
                self?.checkAnagram(word)
            }
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertVC, animated: true)
    }
    
    private func checkAnagram(_ word: String) {
        let lowercasedWord = word.lowercased()
        
        if !isPossible(word: lowercasedWord) {
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'")
            return
        }
        else if !isOriginal(word: lowercasedWord) {
            showErrorMessage(title: "Word already used", message: "Be more original!")
            return
        }
        else if !isReal(word: lowercasedWord) {
            showErrorMessage(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        else if lowercasedWord.count < 3 {
            showErrorMessage(title: "Too short", message: "Try words that are at least 3 letters long!")
            return
        }
        else if lowercasedWord == title?.lowercased() {
            showErrorMessage(title: "Same word", message: "You can't use the same word as an anagram!")
            return
        }
        
        addAnagram(word)
    }
    
    private func addAnagram(_ word: String) {
        usedWords.insert(word, at: 0)
        save()
        
        // Inserts word in tableView
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func isPossible(word: String) -> Bool {
        guard var remainingLetters = title else { return false }
        
        for letter in word {
            if let indexOfLetter = remainingLetters.firstIndex(of: letter) {
                remainingLetters.remove(at: indexOfLetter)
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    private func isOriginal(word: String) -> Bool {
        return !usedWords.map({ $0.lowercased() }).contains(word)
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    private func showErrorMessage(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertCtrl, animated: true)
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        title = defaults.string(forKey: "selectedWord")
        usedWords = defaults.object(forKey: "usedWords") as? [String] ?? [String]()
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(title, forKey: "selectedWord")
        defaults.set(usedWords, forKey: "usedWords")
    }
}

// MARK: - TableView DataSource methods

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
}
