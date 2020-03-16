//
//  ViewController.swift
//  Milestone 9
//
//  Created by Andres Vazquez on 2020-03-15.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

enum CaptionPosition {
    case top, bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    var memeImage: UIImage?
    var topCaption: String?
    var bottomCaption: String?
    
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: @IBActions
    @IBAction func shareBtnTapped(_ sender: UIBarButtonItem) {
        if let image = imageView.image {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            
            present(activityVC, animated: true)
        }
    }
    
    @IBAction func importPhotoBtnTapped(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func addCaptionBtnTapped(_ sender: UIBarButtonItem) {
        if memeImage != nil {
            let ac = UIAlertController(title: "Add caption to image", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Top caption", style: .default) { [weak self] _ in
                self?.promptForCaption(at: .top)
            })
            ac.addAction(UIAlertAction(title: "Bottom caption", style: .default) { [weak self] _ in
                self?.promptForCaption(at: .bottom)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(ac, animated: true)
            
        } else {
            let ac = UIAlertController(title: "A base image is needed", message: "Please choose an image in order to add a caption.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(ac, animated: true)
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            memeImage = image
            updateMemeImage()
        }
        
        dismiss(animated: true)
    }
    
    
    // MARK: - Custom methods
    private func promptForCaption(at position: CaptionPosition) {
        let acTitle = position == .top ? "Top caption" : "Bottom caption"
        let ac = UIAlertController(title: acTitle, message: nil, preferredStyle: .alert)
        ac.addTextField { [weak self] textField in
            if position == .top, let currentTopCaption = self?.topCaption {
                textField.text = currentTopCaption
            } else if let currentBottomCaption = self?.bottomCaption {
                textField.text = currentBottomCaption
            }
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            if position == .top {
                self?.topCaption = ac?.textFields?.first?.text
            } else {
                self?.bottomCaption = ac?.textFields?.first?.text
            }
            
            self?.updateMemeImage()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func updateMemeImage() {
        let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)
        imageView.image = renderer.image { context in
            memeImage?.draw(in: imageView.bounds)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let captionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white,
                .strokeWidth: -5,
                .strokeColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            if let topCaption = topCaption {
                let topCaptionAS = NSAttributedString(string: topCaption, attributes: captionAttrs)
                let heightNeeded = computeTextHeight(for: topCaption, attributes: captionAttrs, width: imageView.frame.width)
                topCaptionAS.draw(with: CGRect(x: 5, y: 5, width: imageView.frame.width, height: heightNeeded), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            }
            
            if let bottomCaption = bottomCaption {
                let bottomCaptionAS = NSAttributedString(string: bottomCaption, attributes: captionAttrs)
                let heightNeeded = computeTextHeight(for: bottomCaption, attributes: captionAttrs, width: imageView.frame.width)
                bottomCaptionAS.draw(with: CGRect(x: 5, y: imageView.frame.height - heightNeeded - 5, width: imageView.frame.width, height: heightNeeded), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            }
        }
    }
    
    private func computeTextHeight(for text: String, attributes: [NSAttributedString.Key : Any], width: CGFloat) -> CGFloat {
        let nsText = NSString(string: text)
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let textRect = nsText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return ceil(textRect.size.height)
    }
}

