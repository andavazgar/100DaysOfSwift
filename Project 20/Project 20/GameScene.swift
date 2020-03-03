//
//  GameScene.swift
//  Project 20
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var fireworks = [SKNode]()
    var gameTimer: Timer?
    var remainingLaunchesLabel: SKLabelNode!
    var remainingLaunches = 10 {
        didSet {
            remainingLaunchesLabel.text = "Launches: \(remainingLaunches)"
            
            if remainingLaunches == 0 {
                gameTimer?.invalidate()
            }
        }
    }
    
    
    let leftEdge = -22
    let bottomEdge = -22
    lazy var rightEdge = Int(frame.width + 22)
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: frame.width - 50, y: frame.height - 50)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        remainingLaunchesLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingLaunchesLabel.position = CGPoint(x: frame.width - 50, y: frame.height - 100)
        remainingLaunchesLabel.horizontalAlignmentMode = .right
        remainingLaunchesLabel.text = "Launches: \(remainingLaunches)"
        addChild(remainingLaunchesLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, speed: 200)
        node.run(move)
        
        if let fuseEmitter = SKEmitterNode(fileNamed: "fuse") {
            fuseEmitter.position = CGPoint(x: 0, y: -22)
            node.addChild(fuseEmitter)
        }
        
        fireworks.append(node)
        addChild(node)
    }
    
    @objc private func launchFireworks() {
        remainingLaunches -= 1
        let movementAmount: CGFloat = 1800
        let middleWidth = Int(frame.width / 2)
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire fire, straight up
            for i in 0..<5 {
                let xPosition = (middleWidth - 200) + (i * 100)
                createFirework(xMovement: 0, x: xPosition, y: bottomEdge)
            }
        case 1:
            // fire fire, in a fan
            for i in 0..<5 {
                let xMovement = CGFloat(-200 + (i * 100))
                let xPosition = (middleWidth - 200) + (i * 100)
                createFirework(xMovement: xMovement, x: xPosition, y: bottomEdge)
            }
        case 2:
            // fire five, from the left to the right
            for i in 0..<5 {
                let yPosition = bottomEdge + (i * 100)
                createFirework(xMovement: movementAmount, x: leftEdge, y: yPosition)
            }
        default:
            // fire five, from the right to the left
            for i in 0..<5 {
                let yPosition = bottomEdge + (i * 100)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: yPosition)
            }
        }
    }
    
    private func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtLocation {
            guard node.name == "firework" else { continue }
            
            for fireworkParent in fireworks {
                guard let firework = fireworkParent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    private func explode(firework: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "explode") {
            explosion.position = firework.position
            
            let delayedRemoval = SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.removeFromParent()
            ])
            
            explosion.run(delayedRemoval)
            addChild(explosion)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFirework() {
        var fireworksCount = 0
        
        for (index, fireworkParent) in fireworks.enumerated().reversed() {
            guard let firework = fireworkParent.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkParent)
                fireworks.remove(at: index)
                fireworksCount += 1
            }
            
        }
        
        switch fireworksCount {
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        case 5:
            score += 4000
        default:
            break
        }
    }
}
