//
//  GameScene.swift
//  Project 11
//
//  Created by Andres Vazquez on 2020-02-20.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var remainingBallsLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var remainingBalls = 5 {
        didSet {
            remainingBallsLabel.text = "Balls: \(remainingBalls)"
        }
    }
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            }
            else {
                editLabel.text = "Edit"
            }
        }
    }
    let ballColors = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        // scoreLabel
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        // remainingBallsLabel
        remainingBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingBallsLabel.text = "Balls: 5"
        remainingBallsLabel.horizontalAlignmentMode = .right
        remainingBallsLabel.position = CGPoint(x: 980, y: 660)
        addChild(remainingBallsLabel)
        
        // editLabel
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        var slotXPos = 0
        var isGood = false
        
        for xPos  in stride(from: 0, through: 1024, by: 256) {
            makeBounder(at: CGPoint(x: xPos, y: 0))
            
            if slotXPos + 128  < 1024 {
                slotXPos = xPos + 128
                isGood.toggle()
                
                makeSlot(at: CGPoint(x: slotXPos, y: 0), isGood: isGood)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        }
        else {
            if editingMode {
                // Creates a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.name = "obstacle"
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            }
            else {
                // Only creates a ball if touch is in top 30% of the screen
                if location.y > frame.height * 0.70 && remainingBalls > 0 {
                    // Creates a ball
                    let ball = SKSpriteNode(imageNamed: ballColors.randomElement()!)
                    ball.position = location
                    ball.name = "ball"
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    
                    addChild(ball)
                }
            }
        }
        
    }
    
    private func makeBounder(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.position = position
        addChild(bouncer)
    }
    
    private func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            
            slotBase.name = "good"
        }
        else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        slotGlow.position = position
        slotGlow.zPosition = -1
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
        addChild(slotBase)
        addChild(slotGlow)
    }
    
    private func collision(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        }
        else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            remainingBalls -= 1
        }
        else if object.name == "obstacle" {
            object.removeFromParent()
        }
    }
    
    private func destroy(ball: SKNode) {
        if let fireEmiter = SKEmitterNode(fileNamed: "FireParticles") {
            fireEmiter.position = ball.position
            addChild(fireEmiter)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(ball: nodeA, object: nodeB)
        }
        else if nodeB.name == "ball" {
            collision(ball: nodeB, object: nodeA)
        }
    }
}
