//
//  ViewController.swift
//  Project 12a
//
//  Created by Andres Vazquez on 2020-01-06.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        loadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else {
            fatalError("Unabele to type cast PersonCell")
        }
        
        let person = people[indexPath.item]
        
        cell.nameLabel.text = person.name
        
        let path = getDocumentsPath().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Perform action", message: "What do you want to do with the selected item?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renameItem(indexPath: indexPath)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteItem(indexPath: indexPath)
        })
        
        present(ac, animated: true)
    }
    
    private func renameItem(indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Rename item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func deleteItem(indexPath: IndexPath) {
        people.remove(at: indexPath.item)
        collectionView.reloadData()
    }
    
    @objc func addNewPerson() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Photo Library", style: .default) {
            [weak self] _ in
            self?.presentUIImagePicker(sourceType: .photoLibrary)
        })
        ac.addAction(UIAlertAction(title: "Camera", style: .default) {
            [weak self] _ in
            self?.presentUIImagePicker(sourceType: .camera)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        
        present(ac, animated: true)
    }
    
    private func presentUIImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = sourceType
            
            present(picker, animated: true)
        }
        else {
            let message: String
            
            if sourceType == .camera {
                message = "Your phone doesn't have a camera."
            }
            else {
                message = "The app doesn't have permission to access the photo library."
            }
            let ac = UIAlertController(title: "Option unavailable", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(ac, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let newImageName = UUID().uuidString
        let pathOfNewImage = getDocumentsPath().appendingPathComponent(newImageName)
        
        if let imageData = image.pngData() {
            try? imageData.write(to: pathOfNewImage)
        }
        
        people.append(Person(name: "Unknown", image: newImageName))
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    private func getDocumentsPath() -> URL {
        let documentsPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return documentsPaths[0]
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople
            }
        }
    }
    
    private func save() {
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: "people")
        }
    }
}

