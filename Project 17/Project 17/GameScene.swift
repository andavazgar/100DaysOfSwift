//
//  GameScene.swift
//  Project 17
//
//  Created by Andres Vazquez on 2020-02-27.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false {
        didSet {
            if isGameOver {
                gameTimer?.invalidate()
            }
        }
    }
    var isTouchingPlayer = false
    var enemiesCounter = 0
    var enemyCreationDelay = 1.0
    
    // MARK: - Life cycle methods
    override func didMove(to view: SKView) {
        view.backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: frame.size.width, y: frame.size.height / 2)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: frame.size.height / 2)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        createEnemyTimer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        isTouchingPlayer = nodes(at: location).contains(player)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > frame.size.height - 100 {
            location.y = frame.size.height - 100
        }
        
        if isTouchingPlayer {
            player.position = location
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
    }
    
    
    // MARK: - Custom methods
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let enemySprite = SKSpriteNode(imageNamed: enemy)
        enemySprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        enemySprite.physicsBody = SKPhysicsBody(texture: enemySprite.texture!, size: enemySprite.size)
        enemySprite.physicsBody?.categoryBitMask = 1
        enemySprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemySprite.physicsBody?.angularVelocity = 5
        enemySprite.physicsBody?.linearDamping = 0
        enemySprite.physicsBody?.angularDamping = 0
        
        addChild(enemySprite)
        
        if enemiesCounter % 20 == 0 && enemiesCounter != 0 {
            enemyCreationDelay -= 0.1
            createEnemyTimer(invalidating: true)
        }
        
        enemiesCounter += 1
    }
    
    private func createEnemyTimer(invalidating previousTimer: Bool = false) {
        if previousTimer {
            gameTimer?.invalidate()
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: enemyCreationDelay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
}
