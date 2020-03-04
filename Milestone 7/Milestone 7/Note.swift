//
//  Note.swift
//  Milestone 7
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import Foundation

class Note: Codable {
    private(set) var id = UUID().uuidString
    private(set) var dateCreated = Date()
    private(set) var dateModified: Date = Date()
    var content: String
    
    init(content: String = "") {
        self.content = content
    }
    
    func save() {
        let notesDirectory = NotesLibrary.getNotesDirectory()
        let noteURL = notesDirectory.appendingPathComponent(id + ".json", isDirectory: false)
        let encoder = JSONEncoder()
        
        do {
            self.dateModified = Date()
            let encodedNote = try encoder.encode(self)
            
            if FileManager.default.fileExists(atPath: noteURL.path) {
                try encodedNote.write(to: noteURL)
            } else {
                FileManager.default.createFile(atPath: noteURL.path, contents: encodedNote, attributes: nil)
            }
            
        } catch {
            print("Note.save(): " + error.localizedDescription)
        }
    }
    
    func delete() {
        let notesDirectory = NotesLibrary.getNotesDirectory()
        let noteURL = notesDirectory.appendingPathComponent(id + ".json", isDirectory: false)
        
        do {
            if FileManager.default.fileExists(atPath: noteURL.path) {
                try FileManager.default.removeItem(at: noteURL)
            }
        } catch {
            print("Note.delete(): " + error.localizedDescription)
        }
    }
}
