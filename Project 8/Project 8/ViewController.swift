//
//  ViewController.swift
//  Project 8
//
//  Created by Andres Vazquez on 2019-12-15.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "Score: 0"
        
        return label
    }()
    
    let cluesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "CLUES"
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        return label
    }()
    
    let answersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "ANSWERS"
        label.numberOfLines = 0
        label.textAlignment = .right
        label.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        return label
    }()
    
    let currentAnswer: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = UIFont.systemFont(ofSize: 44)
        textfield.placeholder = "Tap letters to guess"
        textfield.isUserInteractionEnabled = false
        textfield.textAlignment = .center
        
        return textfield
    }()
    
    let submitBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SUBMIT", for: .normal)
        button.addTarget(self, action: #selector(submitBtnTapped), for: .touchUpInside)
        return button
    }()
    
    let clearBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CLEAR", for: .normal)
        button.addTarget(self, action: #selector(clearBtnTapped), for: .touchUpInside)
        return button
    }()
    
    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
       return view
    }()
    
    var letterButtons = [UIButton]()
    var hiddenButtons = [UIButton]()
    var solutions = [String]()
    var level = 1
    var numberOfSolutionsFound = 0
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: - Methods
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        [scoreLabel, cluesLabel, answersLabel, currentAnswer, submitBtn, clearBtn, buttonsView].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }
    
    private func loadLevel() {
        var cluesString = ""
        var answersString = ""
        var answersBits = [String]()
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let lineParts = line.components(separatedBy: ": ")
                    let wordWithPipes = lineParts[0]
                    let clue = lineParts[1]
                    let word = wordWithPipes.replacingOccurrences(of: "|", with: "")
                    
                    cluesString += "\(index + 1). \(clue)\n"
                    answersString += "\(word.count) letters\n"
                    
                    solutions.append(word)
                    answersBits += wordWithPipes.components(separatedBy: "|")
                }
                
                cluesLabel.text = cluesString.trimmingCharacters(in: .whitespacesAndNewlines)
                answersLabel.text = answersString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                answersBits.shuffle()
                
                if letterButtons.count == answersBits.count {
                    for i in 0 ..< letterButtons.count {
                        letterButtons[i].setTitle(answersBits[i], for: .normal)
                    }
                }
            }
        }
    }
    
    @objc private func letterBtnTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        sender.isHighlighted = false
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        
        hiddenButtons.append(sender)
        UIView.animate(withDuration: 0.5) {
            sender.alpha = 0
        }
    }
    
    @objc private func letterBtnTouchDown(_ sender: UIButton) {
        sender.isHighlighted = false
    }
    
    @objc private func submitBtnTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            hiddenButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            numberOfSolutionsFound += 1
            score += 1
            
            if numberOfSolutionsFound % 7 == 0 {
                let alertCtrl = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                alertCtrl.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: { [weak self] _ in
                    self?.levelUp()
                }))
                
                present(alertCtrl, animated: true)
            }
        }
        else {
            score -= 1
            
            let alertCtrl = UIAlertController(title: "D'oh!", message: "The word you entered is not one of the solutions.", preferredStyle: .alert)
            alertCtrl.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertCtrl, animated: true)
        }
    }
    
    private func levelUp() {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        for button in letterButtons {
            button.alpha = 1
        }
        
        loadLevel()
    }
    
    @objc private func clearBtnTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        UIView.animate(withDuration: 0.5) {
            for button in self.hiddenButtons {
                button.alpha = 1
            }
        }
        
        hiddenButtons.removeAll()
    }
    
    private func setupConstraints() {
        // scoreLabel
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ])
        
        // cluesLabel
        NSLayoutConstraint.activate([
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6, constant: -100)
        ])

        // answersLabel
        NSLayoutConstraint.activate([
            answersLabel.topAnchor.constraint(equalTo: cluesLabel.topAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor)
        ])

        // currentAnswer
        NSLayoutConstraint.activate([
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])

        // submitBtn
        NSLayoutConstraint.activate([
            submitBtn.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submitBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // clearBtn
        NSLayoutConstraint.activate([
            clearBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearBtn.centerYAnchor.constraint(equalTo: submitBtn.centerYAnchor),
            clearBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // buttonsView
        NSLayoutConstraint.activate([
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.topAnchor.constraint(equalTo: submitBtn.bottomAnchor, constant: 20),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        // Creates and lays out letterButtons
        
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterBtnTapped), for: .touchUpInside)
                letterButton.addTarget(self, action: #selector(letterBtnTouchDown), for: .touchDown)
                letterButton.frame  = CGRect(x: column * width, y: row * height, width: width, height: height)
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }
}

