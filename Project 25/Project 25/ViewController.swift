//
//  ViewController.swift
//  Project 25
//
//  Created by Andres Vazquez on 2020-03-09.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate {
    
    var images = [UIImage]()
    
    var mcPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    var mcNearbyAdvertiser: MCNearbyServiceAdvertiser?
    
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie share"
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "antenna.radiowaves.left.and.right"), style: .plain, target: self, action: #selector(showConnectionPrompt)),
            UIBarButtonItem(image: UIImage(systemName: "person.2"), style: .plain, target: self, action: #selector(viewConnectedPeers))
            ]
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "text.bubble"), style: .plain, target: self, action: #selector(sendMessageTapped)),
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
            ]
        
        // Sets the hosting button to red
        navigationItem.leftBarButtonItems?.first?.tintColor = .red
        
        mcSession = MCSession(peer: mcPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    
    // MARK: UICollectionViewDataSource methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            images.insert(image, at: 0)
            collectionView?.insertItems(at: [IndexPath(item: 0, section: 0)])
            
            if let mcSession = mcSession, mcSession.connectedPeers.count > 0 {
                if let imageData = image.pngData() {
                    do {
                        try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                    } catch {
                        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                    }
                }
        }
        
        dismiss(animated: true)
        
        }
    }
    
    
    // MARK: MCSessionDelegate methods
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "Peer got disconected", message: "\(peerID.displayName) got disconnected", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
                
                if self?.mcSession?.connectedPeers.count == 0 {
                    self?.navigationItem.leftBarButtonItems?.first?.tintColor = .red
                }
            }
            
            print("Not connected: \(peerID.displayName)")
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .connected:
            print("Connected: \(peerID.displayName)")
            
        @unknown default:
            print("Unnown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            } else {
                let ac = UIAlertController(title: "Message received", message: String(data: data, encoding: .utf8), preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                self?.present(ac, animated: true)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate methods
    @available(iOS 13.0, *)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let ac = UIAlertController(title: "Project 25", message: "'\(peerID.displayName)' wants to connect.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.mcSession)
            self?.navigationItem.leftBarButtonItems?.first?.tintColor = .green
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { [weak self] _ in
            invitationHandler(false, nil)
            self?.navigationItem.leftBarButtonItems?.first?.tintColor = .red
        }))
        present(ac, animated: true)
    }
    
    
    // MARK: MCBrowserViewControllerDelegate methods
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        if mcSession != nil && mcSession!.connectedPeers.count > 0 {
            navigationItem.leftBarButtonItems?.first?.tintColor = .green
        }
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
    // MARK: Custom methods
    @objc private func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        
        let advertiserTitle: String
        if mcNearbyAdvertiser == nil && mcAdvertiserAssistant == nil {
            advertiserTitle = "Host a session"
        } else {
            advertiserTitle = "Stop hosting"
        }
        ac.addAction(UIAlertAction(title: advertiserTitle, style: .default, handler: { [weak self] _ in
            self?.updateHostingStatus()
        }))
        
        if mcSession?.connectedPeers.count == 0 {
            ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: { [weak self] _ in
                self?.joinSession()
            }))
        } else {
            ac.addAction(UIAlertAction(title: "Leave session", style: .default, handler: { [weak self] _ in
                self?.leaveSession()
            }))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func updateHostingStatus() {
        guard let mcSession = mcSession else { return }
        
        if #available(iOS 13.0, *) {
            if mcNearbyAdvertiser == nil {
                // Start advertising
                mcNearbyAdvertiser = MCNearbyServiceAdvertiser(peer: mcPeerID, discoveryInfo: nil, serviceType: "hws-project25")
                mcNearbyAdvertiser?.delegate = self
                mcNearbyAdvertiser?.startAdvertisingPeer()
                navigationItem.leftBarButtonItems?.first?.tintColor = .green
                
                let ac = UIAlertController(title: "Succesful", message: "You are now hosting a session.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                mcNearbyAdvertiser?.stopAdvertisingPeer()
                mcNearbyAdvertiser = nil
                navigationItem.leftBarButtonItems?.first?.tintColor = .red
                
                let ac = UIAlertController(title: "Succesful", message: "You stopped hosting a session.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        } else {
            if mcAdvertiserAssistant == nil {
                mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
                mcAdvertiserAssistant?.start()
                navigationItem.leftBarButtonItems?.first?.tintColor = .green
                
                let ac = UIAlertController(title: "Succesful", message: "You are now hosting a session.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                mcAdvertiserAssistant?.stop()
                mcAdvertiserAssistant = nil
                navigationItem.leftBarButtonItems?.first?.tintColor = .red
                
                let ac = UIAlertController(title: "Succesful", message: "You stopped hosting a session.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    private func joinSession() {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    private func leaveSession() {
        mcSession?.disconnect()
    }
    
    @objc private func viewConnectedPeers() {
        if let mcSession = mcSession {
            let title = mcSession.connectedPeers.count == 1 ? "1 peer connected" : "\(mcSession.connectedPeers.count) peers connected"
            var peersList = ""
            
            for peer in mcSession.connectedPeers {
                peersList += peer.displayName + "\n"
            }
            
            peersList = peersList.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let ac = UIAlertController(title: title, message: peersList, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc private func sendMessageTapped() {
        let ac = UIAlertController(title: "New text message\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        
        let textView = UITextView(frame: CGRect(x: 15, y: 50, width: 240, height: 135))
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        ac.view.addSubview(textView)
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self, weak textView] _ in
            guard let message = textView?.text else { return }
            self?.sendMessage(message)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func sendMessage(_ message: String) {
        guard let mcSession = mcSession else { return }
        
        let messageData = Data(message.utf8)
        
        do {
            try mcSession.send(messageData, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc private func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
}

