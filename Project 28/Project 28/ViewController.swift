//
//  ViewController.swift
//  Project 28
//
//  Created by Andres Vazquez on 2020-03-17.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import KeychainAccess
import LocalAuthentication
import UIKit

enum KeychainKey: String {
    case authenticationPass = "authenticationPass"
    case secretMessage = "secretMessage"
}

class ViewController: UIViewController {
    @IBOutlet var secretTextView: UITextView!
    
    let keychain = Keychain().accessibility(.whenUnlocked)
    var setupPasswordBtn: UIBarButtonItem!
    var changePasswordBtn: UIBarButtonItem!
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPasswordBtn = UIBarButtonItem(title: "Set up password", style: .plain, target: self, action: #selector(setupPassword))
        changePasswordBtn = UIBarButtonItem(title: "Change password", style: .plain, target: self, action: #selector(changePassword as ()->Void))
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - @IBActions
    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        if (try? self?.keychain.getString(KeychainKey.authenticationPass.rawValue)) != nil {
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Enter password", style: .default) { [weak self] _ in
                                self?.authenticateWithPassword()
                            })
                            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self?.present(ac, animated: true)
                            print("Authentication error: \(authenticationError?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    // MARK: - Custom methods
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretTextView.contentInset = .zero
        } else {
            secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secretTextView.scrollIndicatorInsets = secretTextView.contentInset
    }
    
    private func unlockSecretMessage() {
        secretTextView.isHidden = false
        title = "Secret stuff!"
        
        if (try? keychain.getString(KeychainKey.authenticationPass.rawValue)) != nil {
            navigationItem.leftBarButtonItem = changePasswordBtn
        } else {
            navigationItem.leftBarButtonItem = setupPasswordBtn
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        
        secretTextView.text = try? keychain.getString(KeychainKey.secretMessage.rawValue) ?? ""
    }
    
    @objc private func saveSecretMessage() {
        guard secretTextView.isHidden == false else { return }
        
        navigationItem.rightBarButtonItem = nil
        
        try? keychain.set(secretTextView.text, key: KeychainKey.secretMessage.rawValue)
        secretTextView.resignFirstResponder()
        secretTextView.isHidden = true
        title = "Nothing to see here"
    }
    
    private func authenticateWithPassword() {
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Password"
            textfield.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Authenticate", style: .default) { [weak self, weak ac] _ in
            guard let passwordEntered = ac?.textFields?.first?.text else { return }
            
            if let password = try? self?.keychain.getString(KeychainKey.authenticationPass.rawValue) {
                if password == passwordEntered {
                    self?.unlockSecretMessage()
                } else {
                    let ac = UIAlertController(title: "Wrong password", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc private func setupPassword() {
        let ac = UIAlertController(title: "Set up password", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Password"
            textfield.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            guard let password = ac?.textFields?.first?.text else { return }
            self?.savePasswordToKeychain(password)
            self?.navigationItem.leftBarButtonItem = self?.changePasswordBtn
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc private func changePassword() {
        changePassword(currentPassword: nil, newPassword: nil)
    }
    
    private func changePassword(currentPassword: String?, newPassword: String?) {
        let currentPass = try? keychain.getString(KeychainKey.authenticationPass.rawValue)
        
        let ac = UIAlertController(title: "Change password", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Current password"
            textfield.isSecureTextEntry = true
            textfield.text = currentPassword
        }
        ac.addTextField { textfield in
            textfield.placeholder = "New password"
            textfield.isSecureTextEntry = true
            textfield.text = newPassword
        }
        ac.addAction(UIAlertAction(title: "Change password", style: .default) { [weak self, weak ac] _ in
            guard let currentPassEntered = ac?.textFields?[0].text else { return }
            guard let newPassEntered = ac?.textFields?[1].text else { return }
            
            if currentPassEntered != currentPass {
                let acError = UIAlertController(title: "Wrong password", message: "The current password that you entered is not valid. Please, try again.", preferredStyle: .alert)
                acError.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.changePassword(currentPassword: currentPassEntered, newPassword: newPassEntered)
                })
                
                self?.present(acError, animated: true)
            } else {
                let ac = UIAlertController(title: "Successful", message: "Your password was changed successfully!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
                
                self?.savePasswordToKeychain(newPassEntered)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func savePasswordToKeychain(_ password: String) {
        do {
            try keychain.set(password, key: KeychainKey.authenticationPass.rawValue)
        } catch {
            let acError = UIAlertController(title: "Something went wrong!", message: "The password couldn't be updated. Please, try again.", preferredStyle: .alert)
            acError.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(acError, animated: true)
        }
    }
}

