//
//  ViewController.swift
//  Project 6
//
//  Created by Andres Vazquez on 2019-12-14.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var label1: UILabel!
    var label2: UILabel!
    var label3: UILabel!
    var label4: UILabel!
    var label5: UILabel!
    var labels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1 = labelMaker(labelText: "THESE", labelColor: .red)
        label2 = labelMaker(labelText: "ARE", labelColor: .cyan)
        label3 = labelMaker(labelText: "SOME", labelColor: .yellow)
        label4 = labelMaker(labelText: "AWESOME", labelColor: .green)
        label5 = labelMaker(labelText: "LABELS", labelColor: .orange)
        
        labels = [label1, label2, label3, label4, label5]
        
        labels.forEach {
            view.addSubview($0)
        }
        
//        autoLayoutWithVFL()
        autoLayoutWithAnchors()
    }
    
    private func labelMaker(labelText: String, labelColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelText
        label.backgroundColor = labelColor
        return label
    }
    
    private func autoLayoutWithVFL() {
        let viewsDictionary = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5]
        let metrics = ["labelHeight": 88]
        
        for label in viewsDictionary.keys {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
    }
    
    private func autoLayoutWithAnchors() {
        var previousLabel: UILabel?
        
        for label in labels {
            view.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1/5, constant: -10).isActive = true
            
            if let previousLabel = previousLabel {
                label.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: 10).isActive = true
            }
            else {
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            }
            
            previousLabel = label
        }
    }
}

