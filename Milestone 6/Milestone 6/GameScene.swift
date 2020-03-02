//
//  GameScene.swift
//  Milestone 6
//
//  Created by Andres Vazquez on 2020-02-29.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var timeLabel: SKLabelNode!
    var gameTimer: Timer?
    var timeRemaining: Int! {
        didSet {
            timeLabel.text = "Time: \(timeRemaining!)"
            
            if timeRemaining == 0 {
                gameTimer?.invalidate()
            }
        }
    }
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var targetSpeed = 5.0
    var targetDelay = 1.0
    var isGameOver = false
    var gameOverTitle: SKSpriteNode!
    var restartLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        scene?.size = CGSize(width: 800, height: 600)
        createBackground()
        createWater()
        createOverlay()
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isGameOver {
            if nodes(at: location).contains(restartLabel) {
                restartGame()
            }
        } else {
            run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
            shot(at: location)
        }
    }
    
    private func startGame() {
        timeRemaining = 60
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timeRemaining -= 1
        }
        
        createTarget()
    }
    
    func createTarget() {
        let target = Target()
        target.setup()

        let level = Int.random(in: 0...2)
        var movingRight = true

        switch level {
        case 0:
            // in front of the grass
            target.value = 5
            target.zPosition = 15
            target.position.y = 280
            target.setScale(0.7)
        case 1:
            // in front of the water background
            target.value = 3
            target.zPosition = 25
            target.position.y = 190
            target.setScale(0.85)
            movingRight = false
        default:
            // in front of the water foreground
            target.value = 1
            target.zPosition = 35
            target.position.y = 100
        }

        let move: SKAction

        if movingRight {
            target.position.x = 0
            move = SKAction.moveTo(x: 800, duration: targetSpeed)
        } else {
            target.position.x = 800
            target.xScale = -target.xScale
            move = SKAction.moveTo(x: 0, duration: targetSpeed)
        }

        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        target.run(sequence)
        addChild(target)

        levelUp()
    }
    
    func levelUp() {
        targetSpeed *= 0.99
        targetDelay *= 0.99
        
        if timeRemaining > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [weak self] in
                self?.createTarget()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.gameOver()
            }
        }
    }
    
    func shot(at location: CGPoint) {
        let hitNodes = nodes(at: location).filter { $0.name == "target" }
        
        if let hitNode = hitNodes.first {
            guard let target = hitNode.parent as? Target else { return }

            target.hit()
            score += target.value
        } else {
            score -= 1
        }
    }
    
    func gameOver() {
        isGameOver = true

        gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        gameOverTitle.name = "gameOver"
        gameOverTitle.zPosition = 100
        gameOverTitle.alpha = 0
        gameOverTitle.setScale(2)
        addChild(gameOverTitle)
        
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.position = CGPoint(x: frame.size.width / 2, y: 90)
        restartLabel.name = "Restart"
        restartLabel.zPosition = 50
        restartLabel.text = "Restart Game"
        addChild(restartLabel)

        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 1, duration: 0.3)
        let group = SKAction.group([fadeIn, scaleDown])

        gameOverTitle.run(group)
        restartLabel.run(group)
    }
    
    private func restartGame() {
        targetSpeed = 5.0
        targetDelay = 1.0
        score = 0
        isGameOver = false
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        gameOverTitle.run(fadeOut)
        restartLabel.run(fadeOut)
        startGame()
    }

    private func createBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.blendMode = .replace
        addChild(background)

        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        grass.zPosition = 10
        addChild(grass)
    }

    private func createWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let movementUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let movementDown = movementUp.reversed()
            let sequence = SKAction.sequence([movementUp, movementDown])
            let repeatForever = SKAction.repeatForever(sequence)
            node.run(repeatForever)
        }

        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 - 120)
        waterBackground.zPosition = 20
        addChild(waterBackground)


        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 - 180)
        waterForeground.zPosition = 30
        addChild(waterForeground)

        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }

    private func createOverlay() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        curtains.zPosition = 40
        addChild(curtains)
        
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: 120, y: 50)
        timeLabel.zPosition = 50
        timeLabel.text = "Time: 60"
        addChild(timeLabel)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.size.width - 120, y: 50)
        scoreLabel.zPosition = 50
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
}
