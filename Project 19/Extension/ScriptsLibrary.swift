//
//  ScriptsLibrary.swift
//  Extension
//
//  Created by Andres Vazquez on 2020-03-02.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import Foundation

struct ScriptsLibrary: Codable {
    var scripts: [Script]
    
    func save() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        do {
            let savedScriptsAsJSON = try encoder.encode(self)
            defaults.set(savedScriptsAsJSON, forKey: "savedScripts")
        } catch {
            fatalError("Unable to encode the scripts")
        }
    }
    
    mutating func append(script: Script) {
        scripts.append(script)
        save()
    }
    
    mutating func update(script: Script, atIndex index: Int) {
        scripts[index] = script
        save()
    }
    
    mutating func deleteScript(atIndex index: Int) {
        scripts.remove(at: index)
        save()
    }
    
    static func getSavedScripts() -> ScriptsLibrary {
        let defaults = UserDefaults.standard
        
        if let savedScripts = defaults.object(forKey: "savedScripts") as? Data {
            let decoder = JSONDecoder()
            
            do {
                return try decoder.decode(ScriptsLibrary.self, from: savedScripts)
            } catch {
                fatalError("Couldn't decode the savedScripts")
            }
        }
        
        return ScriptsLibrary(scripts: [Script]())
    }
}
