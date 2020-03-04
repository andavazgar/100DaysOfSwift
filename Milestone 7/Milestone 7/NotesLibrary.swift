//
//  NotesLibrary.swift
//  Milestone 7
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import Foundation

struct NotesLibrary: Codable {
    var notes = [Note]()
    
    static func getNotes() -> NotesLibrary {
        var notesLibrary = NotesLibrary()
        let notesDirectory = getNotesDirectory()
        
        do {
            let noteNames = try FileManager.default.contentsOfDirectory(atPath: notesDirectory.path)
            let decoder = JSONDecoder()
            
            for noteName in noteNames {
                let noteURL = notesDirectory.appendingPathComponent(noteName, isDirectory: false)
                let noteData = try Data(contentsOf: noteURL)
                let note = try decoder.decode(Note.self, from: noteData)
                notesLibrary.notes.append(note)
            }
        } catch {
            print("NotesLibrary.getNotes(): " + error.localizedDescription)
        }
        
        return notesLibrary
    }
    
    static func getNotesDirectory() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let notesDirectory = documentsDirectory.appendingPathComponent("Notes")
        
        if !FileManager.default.fileExists(atPath: notesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: notesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("NotesLibrary.getNotesDirectory(): " + error.localizedDescription)
            }
        }
        
        return notesDirectory
    }
    
    mutating func deleteNote(at index: Int) {
        // This deletes the note from the documentDirectory (Permanent storage)
        self.notes[index].delete()
        // This removes the note from the notesLibrary object
        self.notes.remove(at: index)
    }
    
    mutating func sort(by condition: (Note, Note) -> Bool) {
        self.notes.sort(by: condition)
    }
    
    func sorted(by condition: (Note, Note) -> Bool) -> NotesLibrary {
        return NotesLibrary(notes: notes.sorted(by: condition))
    }
}
