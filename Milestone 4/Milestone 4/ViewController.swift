//
//  ViewController.swift
//  Milestone 4
//
//  Created by Andres Vazquez on 2020-02-21.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellID = "photoCell"
    var memories = [Memory]()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Camera Interests"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtnTapped))
        
        loadMemories()
    }
    
    
    // MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let memory = memories[indexPath.row]
        let imagePath = getDocumentDirectory().appendingPathComponent(memory.image)
        
        cell.imageView?.image = UIImage(contentsOfFile: imagePath.path)
        cell.textLabel?.text = memory.caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ImageDetailViewController()
        let imagePath = getDocumentDirectory().appendingPathComponent(memories[indexPath.row].image)
        vc.imageView.image = UIImage(contentsOfFile: imagePath.path)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let imageName = UUID().uuidString
            let path = getDocumentDirectory().appendingPathComponent(imageName)
            
            if let imageData = image.pngData() {
                try? imageData.write(to: path)
                
                memories.append(Memory(image: imageName, caption: ""))
                saveMemories()
                tableView.insertRows(at: [IndexPath(row: memories.count - 1, section: 0)], with: .automatic)
            }
        }
        
        dismiss(animated: true)
    }
    
    
    // MARK: - Custom methods
    @objc private func addBtnTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadMemories() {
        let defaults = UserDefaults.standard
        if let memoriesData = defaults.object(forKey: "memories") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                memories = try jsonDecoder.decode([Memory].self, from: memoriesData)
            } catch {
                print("Failed to load memories")
            }
        }
    }
    
    private func saveMemories() {
        let jsonEncoder = JSONEncoder()
        
        do {
            let memoriesData = try jsonEncoder.encode(memories)
            let defaults = UserDefaults.standard
            defaults.set(memoriesData, forKey: "memories")
        } catch {
            print("Failed to save memories")
        }
        
    }
}

