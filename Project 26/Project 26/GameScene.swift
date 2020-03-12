//
//  GameScene.swift
//  Project 26
//
//  Created by Andres Vazquez on 2020-03-10.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import CoreMotion
import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case wall = 2
    case vortex = 4
    case star = 8
    case portal = 16
    case finish = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchedPosition: CGPoint?
    var motionManager: CMMotionManager!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var currentLevelLabel: SKLabelNode!
    var currentLevel = 1 {
        didSet {
            currentLevelLabel.text = "Level: \(currentLevel)"
        }
    }
    let lastLevel = 3
    var portals = [SKSpriteNode]()
    var isFirstPortal = true
    var isTeleporting = false
    var startGameLabel: SKLabelNode!
    var isGameStarted = false
    var isGameOver = false
    
    // MARK: - Life cycle methods
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "background"
        background.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        startGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        startGameLabel.text = "Start Game"
        startGameLabel.position = CGPoint(x: frame.width - 16, y: 16)
        startGameLabel.zPosition = 2
        startGameLabel.horizontalAlignmentMode = .right
        addChild(startGameLabel)
        
        currentLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        currentLevelLabel.position = CGPoint(x: 16, y: frame.height - 40)
        currentLevelLabel.zPosition = 2
        currentLevelLabel.horizontalAlignmentMode = .left
        addChild(currentLevelLabel)
        
        currentLevel = 2
        score = 0
        
        loadLevel()
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted else { return }
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
        if let lastTouchedPosition = lastTouchedPosition {
            let diff = CGPoint(x: lastTouchedPosition.x - player.position.x, y: lastTouchedPosition.y - player.position.y)
            
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let motionData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: motionData.acceleration.y * -50, dy: motionData.acceleration.x * 50)
        }
        #endif
    }
    
    
    // MARK: - Touch-event mthods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchedPosition = touch.location(in: self)
        
        if isGameStarted == false && nodes(at: lastTouchedPosition!).contains(startGameLabel) {
            startGameLabel.isHidden = true
            isGameStarted = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchedPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    
    // MARK: SKPhysicsContactDelegate methods
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    
    // MARK: Custom methods
    private func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Could not find level\(currentLevel).txt in the app bundle.")
        }
        guard let level = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level\(currentLevel).txt from the app bundle.")
        }
        
        let lines = level.split(separator: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                switch letter {
                case "x":
                    createWall(at: position)
                case "v":
                    createVortex(at: position)
                case "s":
                    createStar(at: position)
                case "p":
                    createPortal(at: position)
                case "f":
                    createFinish(at: position)
                case " ":
                    // It's empty space
                    break
                default:
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    private func createWall(at position: CGPoint) {
        // It's a wall
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionType.wall.rawValue
        addChild(node)
    }
    
    private func createVortex(at position: CGPoint) {
        // It's a vortex
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionType.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.run(.repeatForever(.rotate(byAngle: .pi, duration: 1)))
        addChild(node)
    }
    
    private func createStar(at position: CGPoint) {
        // It's a star
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionType.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    private func createPortal(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "portal")
        node.name = "portal"
        node.position = position
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionType.portal.rawValue
        node.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        if isFirstPortal {
            node.texture = SKTexture(imageNamed: "portalOrange")
            portals.insert(node, at: 0)
        } else {
            portals.insert(node, at: 1)
        }
        
        node.run(.repeatForever(.rotate(byAngle: .pi, duration: 2)))
        
        addChild(node)
        
        isFirstPortal.toggle()
    }
    
    private func createFinish(at position: CGPoint) {
        // It's the finish point
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionType.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.vortex.rawValue | CollisionType.star.rawValue | CollisionType.portal.rawValue | CollisionType.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.wall.rawValue
        
        addChild(player)
    }
    
    private func removeFinishedLevelElements() {
        for node in self.children {
            if node is SKSpriteNode && node.name != "background" {
                node.removeFromParent()
            }
        }
    }
    
    private func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            player.run(.sequence([
                .move(to: node.position, duration: 0.25),
                .scale(to: 0.0001, duration: 0.25),
                .removeFromParent()
            ])) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "portal" {
            guard isTeleporting == false else { return }
            
            isTeleporting = true
            player.run(.sequence([
                .move(to: node.position, duration: 0.25),
                .scale(to: 0.0001, duration: 0.25),
            ])) { [weak self] in
                guard let self = self else { return }
                
                if node == self.portals[0] {
                    self.player.position = self.portals[1].position
                } else {
                    self.player.position = self.portals[0].position
                }
                
                self.player.run(.scale(to: 1, duration: 0.25))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isTeleporting = false
                }
            }
        } else if node.name == "finish" {
            score += 5
            isGameStarted = false
            startGameLabel.isHidden = false
            
            physicsWorld.gravity = .zero
            
            if currentLevel + 1 <= lastLevel {
                currentLevel += 1
                removeFinishedLevelElements()
                loadLevel()
                createPlayer()
            }
        }
    }
}
