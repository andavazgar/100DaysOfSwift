//
//  GameViewController.swift
//  Project 29
//
//  Created by Andres Vazquez on 2020-03-19.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var currentGame: GameScene?
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    
    var currentPlayer = 1
    var player1Values = [String: Float]()
    var player2Values = [String: Float]()
    
    var animationDisplayLink: CADisplayLink!
    var animationStartDate: Date!
    var animationDuration = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        setDefaultValues()
        angleChanged(self)
        velocityChanged(self)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
        transformThrowingArrow()
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
        transformThrowingArrow()
    }
    
    @IBAction func launch(_ sender: Any) {
        toggleUIElements()
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
        if currentPlayer == 1 {
            player1Values["angle"] = angleSlider.value
            player1Values["velocity"] = velocitySlider.value
        } else {
            player2Values["angle"] = angleSlider.value
            player2Values["velocity"] = velocitySlider.value
        }
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            currentPlayer = 1
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            currentPlayer = 2
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        toggleUIElements()
        launchButton.isEnabled = false
        
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(animateAngleVelocityChanges))
        animationDisplayLink.add(to: .main, forMode: .default)
        animationStartDate = Date()
    }
    
    /* Animates the angle and velocity UILabels such that when the UISliders change value they are reflected by increasing or decreasing the value in the UILabel.
        This is needed when the players change turns (activatePlayer)
     */
    @objc private func animateAngleVelocityChanges() {
        let elapsedTime = Date().timeIntervalSince(animationStartDate)
        
        if elapsedTime > animationDuration {
            animationDisplayLink.invalidate()
            
            angleSlider.value = (currentPlayer == 1 ? player1Values["angle"] : player2Values["angle"]) ?? 0
            velocitySlider.value = (currentPlayer == 1 ? player1Values["velocity"] : player2Values["velocity"]) ?? 0
            angleChanged(self)
            velocityChanged(self)
            
            launchButton.isEnabled = true
            return
        }

        let percentageOfAnimation = elapsedTime / animationDuration

        let initialAngle: Float!
        let endAngle: Float!
        let initialVelocity: Float!
        let endVelocity: Float!

        if currentPlayer == 1 {
            initialAngle = player2Values["angle"]
            endAngle = player1Values["angle"]
            initialVelocity = player2Values["velocity"]
            endVelocity = player1Values["velocity"]
        } else {
            initialAngle = player1Values["angle"]
            endAngle = player2Values["angle"]
            initialVelocity = player1Values["velocity"]
            endVelocity = player2Values["velocity"]
        }

        angleSlider.value = initialAngle + Float(percentageOfAnimation) * (endAngle - initialAngle)
        velocitySlider.value = initialVelocity + Float(percentageOfAnimation) * (endVelocity - initialVelocity)
        angleChanged(self)
        velocityChanged(self)
    }
    
    private func transformThrowingArrow() {
        if currentPlayer == 1 {
            currentGame?.player1.transformArrow(withRotationAngle: angleSlider.value, velocity: velocitySlider.value, throwingDirection: .right)
        } else {
            currentGame?.player2.transformArrow(withRotationAngle: angleSlider.value, velocity: velocitySlider.value, throwingDirection: .left)
        }
    }
    
    func setDefaultValues() {
        player1Values = ["angle": 45, "velocity": 125]
        player2Values = ["angle": 45, "velocity": 125]
    }
    
    private func toggleUIElements() {
        [angleSlider, angleLabel, velocitySlider, velocityLabel, launchButton].forEach { $0.isHidden.toggle() }
    }
}
