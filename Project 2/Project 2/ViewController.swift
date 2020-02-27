//
//  ViewController.swift
//  Project 2
//
//  Created by Andres Vazquez on 2019-12-09.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var questionBarButtonItem: UIBarButtonItem!
    @IBOutlet var scoreBarButtonItem: UIBarButtonItem!
    private var buttons = [UIButton]()
    private var flags = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    private var correctAnswer = 0
    private var score = 0 {
        didSet {
            scoreBarButtonItem.title = "Score: \(score)"
        }
    }
    private var currentQuestion = 0 {
        didSet {
            questionBarButtonItem.title = "Question: \(currentQuestion)/\(numberOfQuestions)"
        }
    }
    private let numberOfQuestions = 10
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons = [button1, button2, button3]
        
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        askQuestion()
    }
    
    private func askQuestion() {
        currentQuestion += 1
        flags.shuffle()
        correctAnswer = Int.random(in: 0..<buttons.count)
        
        for i in 0..<buttons.count {
            buttons[i].setImage(UIImage(named: flags[i]), for: .normal)
        }
        
        title = flags[correctAnswer].uppercased()
    }

    @IBAction func checkSelection(_ sender: UIButton) {
        var alertTitle: String
        var alertMessage: String?
        var alertDuration = 0.75
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        if sender.tag == correctAnswer {
            alertTitle = "Correct"
            score += 1
        }
        else {
            alertTitle = "Wrong"
            alertMessage = "That’s the flag of \(flags[sender.tag].uppercased())"
            alertDuration = 2.5
        }
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertDuration) {
            alert.dismiss(animated: true) {
                if self.currentQuestion < self.numberOfQuestions {
                    self.askQuestion()
                }
                else {
                    self.endOfGame()
                }
            }
        }
    }
    
    private func endOfGame() {
        let alert = UIAlertController(title: "Final Result: \(score)/10", message: "Would you like to start over?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { _ in
            self.startOver()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func startOver() {
        score = 0
        currentQuestion = 0
        askQuestion()
    }
    
}

