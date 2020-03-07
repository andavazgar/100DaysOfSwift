//
//  GameScene.swift
//  Project 23
//
//  Created by Andres Vazquez on 2020-03-06.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, TwoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var livesSprites = [SKSpriteNode]()
    var lives = 3 {
        didSet {
            if lives >= 0 && lives < livesSprites.count {
                let lifeLost = livesSprites[livesSprites.count - (lives + 1)]
                lifeLost.texture = SKTexture(imageNamed: "sliceLifeGone")
                lifeLost.xScale = 1.3
                lifeLost.yScale = 1.3
                lifeLost.run(SKAction.scale(to: 1, duration: 0.1))
            }
        }
    }
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    var isGameOver = false
    var gameOverSprite: SKSpriteNode!
    var restartGameLabel: SKLabelNode!
    var shouldSubtractLives = true
    
    // MARK: - Life cycle methods
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        createScore()
        createLives()
        createSlices()
        
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                        
                        if shouldSubtractLives {
                            subtractLife()
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    
    // MARK: - Touch-event methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isGameOver {
            if nodes(at: location).contains(restartGameLabel) {
                restartGame()
            }
        } else {
            activeSlicePoints.append(location)
            
            redrawActiveSlice()
            
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameOver == false else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        let nodesAtPosition = nodes(at: location)
        
        let scaleDown = SKAction.scale(by: 0.001, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let disapearAction = SKAction.group([scaleDown, fadeOut])
        
        for case let node as SKSpriteNode in nodesAtPosition {
            if node.name == "enemy" {
                node.name = ""
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    emitter.run(.sequence([
                        .wait(forDuration: 1),
                        .removeFromParent()
                    ]))
                    addChild(emitter)
                }
                
                node.physicsBody?.isDynamic = false
                
                node.run(SKAction.sequence([
                    disapearAction,
                    SKAction.removeFromParent()
                ]))
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                node.name = ""
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = node.position
                    emitter.run(.sequence([
                        .wait(forDuration: 1),
                        .removeFromParent()
                    ]))
                    addChild(emitter)
                }
                
                bombContainer.physicsBody?.isDynamic = false
                
                bombContainer.run(SKAction.sequence([
                    disapearAction,
                    SKAction.removeFromParent()
                ]))
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                
                gameOver(triggeredByBomb: true)
            }
        }
        
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
        activeSlicePoints.removeAll(keepingCapacity: true)
    }
    
    
    // MARK: - Custom methods
    private func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    private func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        run(SKAction.playSoundFileNamed(soundName, waitForCompletion: true)) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    private func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        if lives == 0 {
            gameOver(triggeredByBomb: false)
        }
    }
    
    private func startGame() {
        score = 0
        popupTime = 0.9
        chainDelay = 3.0
        physicsWorld.speed = 0.85
        
        sequencePosition = 0
        sequence = [.oneNoBomb, .oneNoBomb, .TwoWithOneBomb, .TwoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...500 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.tossEnemies()
            self?.shouldSubtractLives = true
        }
    }
    
    private func gameOver(triggeredByBomb: Bool) {
        guard isGameOver == false else { return }
        isGameOver = true
        physicsWorld.speed = 0
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            for lifeSprite in livesSprites {
                lifeSprite.texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
        
        gameOverSprite = SKSpriteNode(imageNamed: "game-over")
        gameOverSprite.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        gameOverSprite.zPosition = 5
        gameOverSprite.xScale = 4
        gameOverSprite.yScale = 4
        gameOverSprite.run(SKAction.scale(to: 2, duration: 0.2))
        addChild(gameOverSprite)
        
        restartGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartGameLabel.text = "Restart Game?"
        restartGameLabel.fontSize = 35
        restartGameLabel.position = CGPoint(x: gameOverSprite.position.x, y: gameOverSprite.position.y - 120)
        restartGameLabel.zPosition = 5
        addChild(restartGameLabel)
        
        let sequenceBigSmall = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.75),
            SKAction.scale(to: 0.9, duration: 0.75)
        ])
        
        restartGameLabel.run(SKAction.repeatForever(sequenceBigSmall))
    }
    
    private func restartGame() {
        isGameOver = false
        
        gameOverSprite.run(.sequence([
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
        
        restartGameLabel.removeAllActions()
        restartGameLabel.run(.sequence([
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
        
        lives = 3
        for lifeSprite in livesSprites {
            lifeSprite.texture = SKTexture(imageNamed: "sliceLife")
        }
        
        shouldSubtractLives = false
        startGame()
    }
    
    
    private func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
    }
    
    private func createLives() {
        for i in 0..<3 {
            let lifeSprite = SKSpriteNode(imageNamed: "sliceLife")
            lifeSprite.position = CGPoint(x: frame.width - 190 + (CGFloat(i) * 70), y: frame.height - 48)
            addChild(lifeSprite)
            
            livesSprites.append(lifeSprite)
        }
    }
    
    private func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        activeSliceBG.strokeColor = UIColor.init(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        addChild(activeSliceBG)
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        addChild(activeSliceFG)
    }
    
    private func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        // Bomb == 0
        // Penguin == 1-6
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .always {
            enemyType = 0
        } else if forceBomb == .never {
            enemyType = 1
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    bombSoundEffect?.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = "enemy"
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        }
        
        // Enemy position
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        // Velocity and Angular velocity
        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        let randomXVelocity: Int

        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        
        let randomYVeleocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVeleocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        activeEnemies.append(enemy)
        addChild(enemy)
    }
    
    private func tossEnemies() {
        guard isGameOver == false else { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .TwoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            for _ in 0..<2 {
                createEnemy()
            }
            
        case .three:
            for _ in 0..<3 {
                createEnemy()
            }
            
        case .four:
            for _ in 0..<4 {
                createEnemy()
            }
            
        case .chain:
            createEnemy()
            
            for i in 1..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay / 5 * Double(i)) { [weak self] in
                    self?.createEnemy()
                }
            }
            
        case .fastChain:
            createEnemy()
            
            for i in 1..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay / 10 * Double(i)) { [weak self] in
                    self?.createEnemy()
                }
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
