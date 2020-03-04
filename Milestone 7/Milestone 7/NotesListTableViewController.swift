//
//  ViewController.swift
//  Milestone 7
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class NotesListTableViewController: UITableViewController {
    var notesLibrary = NotesLibrary() {
        didSet {
            let numNotes = notesLibrary.notes.count
            
            if numNotes == 1 {
                numNotesLabel.text = "\(notesLibrary.notes.count) Note"
            } else {
                numNotesLabel.text = "\(notesLibrary.notes.count) Notes"
            }
        }
    }
    var numNotesLabel = UILabel()
    var indexPathOfNoteBeingModified: IndexPath?
    
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationController?.toolbar.tintColor = .systemYellow
        
        setupToolbar()
        notesLibrary = NotesLibrary.getNotes()
        notesLibrary.sort { $0.dateModified > $1.dateModified }
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(noteWasUpdated), name: NSNotification.Name("NoteWasUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noteWasDeleted), name: NSNotification.Name("NoteWasDeleted"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - TableViewDataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesLibrary.notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
        let note = notesLibrary.notes[indexPath.row]
        var noteContentLines = note.content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
        
        // Set Note title
        cell.titleLabel.text = noteContentLines.first
        
        // Set modified date
        if Calendar.current.isDateInYesterday(note.dateModified) {
            cell.dateModifiedLabel.text = "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            
            if Calendar.current.isDateInToday(note.dateModified) {
                dateFormatter.dateFormat = "hh:mm a"
            } else {
                dateFormatter.dateFormat = "yyyy-MM-dd"
            }
            
            cell.dateModifiedLabel.text = dateFormatter.string(from: note.dateModified)
        }
        
        // Set note preview
        if noteContentLines.count > 1 {
            noteContentLines.remove(at: 0)
            let previewText = noteContentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            cell.previewLabel.text = previewText
        } else {
            cell.previewLabel.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notesLibrary.deleteNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // MARK: - TableViewDelegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "NoteEditorViewController") as! NoteEditorViewController
        indexPathOfNoteBeingModified = indexPath
        vc.note = notesLibrary.notes[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Custom methods
    @objc private func composeBtnTapped() {
        let vc = storyboard?.instantiateViewController(identifier: "NoteEditorViewController") as! NoteEditorViewController
        vc.note = Note()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func noteWasUpdated(notification: Notification) {
        guard let noteFromEditor = notification.userInfo?["note"] as? Note else { return }
        
        // It's a modification to an existing note
        if let indexPathOfNoteBeingModified = indexPathOfNoteBeingModified {
            notesLibrary.notes.remove(at: indexPathOfNoteBeingModified.row)
            notesLibrary.notes.insert(noteFromEditor, at: 0)
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.moveRow(at: indexPathOfNoteBeingModified, to: IndexPath(row: 0, section: 0))
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            self.indexPathOfNoteBeingModified = nil
        } else {
            // It's a new note
            notesLibrary.notes.insert(noteFromEditor, at: 0)
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
    
    @objc private func noteWasDeleted(notification: Notification) {
        if let indexPathOfNoteBeingModified = indexPathOfNoteBeingModified {
            notesLibrary.notes.remove(at: indexPathOfNoteBeingModified.row)
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.deleteRows(at: [indexPathOfNoteBeingModified], with: .automatic)
            }
            self.indexPathOfNoteBeingModified = nil
        }
    }
    
    private func setupToolbar() {
        let attachmentsBtn = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2"), style: .plain, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        numNotesLabel.text = "\(notesLibrary.notes.count) Notes"
        numNotesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        let numNotesBtn = UIBarButtonItem(customView: numNotesLabel)
        let composeBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeBtnTapped))
        
        toolbarItems = [attachmentsBtn, flexibleSpace, numNotesBtn, flexibleSpace, composeBtn]
    }
}

