//
//  NoteEditorViewController.swift
//  Milestone 7
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class NoteEditorViewController: UIViewController {
    @IBOutlet var noteTextView: UITextView!
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBtnTapped)),
            UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"), style: .plain, target: self, action: nil)
        ]
        navigationItem.largeTitleDisplayMode = .never
        
        if let note = note {
            noteTextView.text = note.content
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNoteChanges()
    }
    
    @IBAction func trashBtnTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Are you sure that you want to delete this note?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.note?.delete()
            self?.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: NSNotification.Name("NoteWasDeleted"), object: nil)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.popoverPresentationController?.barButtonItem = sender
        
        present(ac, animated: true)
    }
    
    @IBAction func composeBtnTapped(_ sender: UIBarButtonItem) {
        saveNoteChanges()
        note = Note()
        noteTextView.text = note?.content
    }
    
    @objc private func shareBtnTapped(_ sender: UIBarButtonItem) {
        if let noteText = noteTextView.text {
            let activityVC = UIActivityViewController(activityItems: [noteText], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            present(activityVC, animated: true)
        }
    }
    
    private func saveNoteChanges() {
        if let note = note, note.content != noteTextView.text {
            note.content = noteTextView.text
            note.save()
            
            NotificationCenter.default.post(name: NSNotification.Name("NoteWasUpdated"), object: nil, userInfo: ["note": note])
        }
    }
}
