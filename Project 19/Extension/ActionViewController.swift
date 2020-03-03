//
//  ActionViewController.swift
//  Extension
//
//  Created by Andres Vazquez on 2020-03-01.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet var scriptTextView: UITextView!
    var actionBtn: UIBarButtonItem!
    var script: Script?
    var scriptIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems([flexibleSpace], animated: true)
        
        if let script = script {
            scriptTextView.text = script.code
            title = script.name
            
            toolbarItems?.append(UIBarButtonItem(title: "Update template", style: .plain, target: self, action: #selector(updateTemplateBtnTapped)))
            actionBtn = UIBarButtonItem(title: "Update template", style: .plain, target: self, action: #selector(updateTemplateBtnTapped))
        } else {
            toolbarItems?.append(UIBarButtonItem(title: "Save as template", style: .plain, target: self, action: #selector(saveTemplateBtnTapped)))
            actionBtn = UIBarButtonItem(title: "Save as template", style: .plain, target: self, action: #selector(saveTemplateBtnTapped))
        }
        
        setupAccessoryView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Run script!", style: .done, target: self, action: #selector(runScript))
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemsDictionary = dict as? NSDictionary else { return }
                    guard let jsValues = itemsDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    
                    if self?.title == nil {
                        DispatchQueue.main.async {
                            self?.title = jsValues["title"] as? String ?? ""
                            self?.title = "Unsaved sctipt"
                        }
                    }
                }
            }
        }
    }
    
    @objc private func updateTemplateBtnTapped() {
        var scriptsLibrary = ScriptsLibrary.getSavedScripts()
        let alertTitle: String
        let alertMessage: String
        if var script = script, let scriptIndex = scriptIndex {
            script.code = scriptTextView.text
            script.dateModified = Date()
            scriptsLibrary.update(script: script, atIndex: scriptIndex)
            
            alertTitle = "Successful"
            alertMessage = "The script was updated successfully!"
        }
        else {
            scriptsLibrary.append(script: Script(name: "Untitled", code: scriptTextView.text, dateCreated: Date(), dateModified: Date()))
            
            alertTitle = "Something went wrong!"
            alertMessage = "The template couldn't be updated. A new template was created instead."
        }
        
        let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc private func saveTemplateBtnTapped() {
        let ac = UIAlertController(title: "Script name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            guard let scriptName = ac?.textFields?.first?.text else { return }
            
            self?.title = scriptName
            self?.saveTemplate(named: scriptName)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func saveTemplate(named name: String) {
        var scriptsLibrary = ScriptsLibrary.getSavedScripts()
        script = Script(name: name, code: scriptTextView.text, dateCreated: Date(), dateModified: Date())
        
        scriptsLibrary.append(script: script!)
        
        scriptIndex = scriptsLibrary.scripts.count - 1
        
        actionBtn = UIBarButtonItem(title: "Update template", style: .plain, target: self, action: #selector(updateTemplateBtnTapped))
    }

    @objc private func runScript() {
        let dataDict: NSDictionary = ["customJavaScript": scriptTextView.text ?? ""]
        let jsDict: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: dataDict]
        let itemProvider = NSItemProvider(item: jsDict, typeIdentifier: kUTTypePropertyList as String)
        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [itemProvider]
        
        extensionContext?.completeRequest(returningItems: [extensionItem])
    }
    
    private func setupAccessoryView() {
        let hideKeyboardBtn = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(hideKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let accessoryView = UIInputView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        let accessoryViewToolbar = UIToolbar(frame: accessoryView.frame)
        accessoryViewToolbar.tintColor = .darkGray
        accessoryViewToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)  // This is the only way I found to make the background clear (transparent)
        accessoryViewToolbar.items = [hideKeyboardBtn, flexibleSpace, actionBtn]
        accessoryView.addSubview(accessoryViewToolbar)
        scriptTextView.inputAccessoryView = accessoryView
    }
    
    @objc private func hideKeyboard() {
        scriptTextView.resignFirstResponder()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scriptTextView.contentInset = .zero
        } else {
            scriptTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardScreenEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scriptTextView.scrollIndicatorInsets = scriptTextView.contentInset
        
        let selectedRange = scriptTextView.selectedRange
        scriptTextView.scrollRangeToVisible(selectedRange)
    }
}
