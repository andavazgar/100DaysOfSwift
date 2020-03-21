//
//  MonkeyNode.swift
//  Project 29
//
//  Created by Andres Vazquez on 2020-03-20.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit
import UIKit

enum ThrowDirection {
    case left, right
}

class MonkeyNode: SKSpriteNode {
    private var monkey: SKSpriteNode!
    var arrow: SKSpriteNode!
    private var arrowImage: UIImage!
    
    func setup(onTopOf building: BuildingNode) {
        monkey = SKSpriteNode(imageNamed: "player")
        monkey.position = CGPoint(x: building.position.x, y: building.size.height + monkey.size.height / 2)
        monkey.zPosition = 1
        
        monkey.physicsBody = SKPhysicsBody(circleOfRadius: monkey.size.width / 2)
        monkey.physicsBody?.isDynamic = false
        monkey.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        monkey.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        monkey.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        addChild(monkey)
        
        createArrow()
    }
    
    func `throw`(_ banana: SKSpriteNode, toThe direction: ThrowDirection, withImpulse impulse: CGVector) {
        let movementImg: String
        
        if direction == .right {
            movementImg = "player1Throw"
            
            banana.position = CGPoint(x: monkey.position.x - 30, y: monkey.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            movementImg = "player2Throw"
            
            banana.position = CGPoint(x: monkey.position.x + 30, y: monkey.position.y + 40)
            banana.physicsBody?.angularVelocity = +20
            banana.physicsBody?.applyImpulse(impulse)
        }
        
        monkey.run(.sequence([
            .setTexture(SKTexture(imageNamed: movementImg)),
            .wait(forDuration: 0.15),
            .setTexture(SKTexture(imageNamed: "player"))
        ]))
    }
    
    static func createBanana() -> SKSpriteNode {
        let banana = SKSpriteNode(imageNamed: "banana")
        
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        
        return banana
    }
    
    private func createArrow() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 192, height: 192))
        arrowImage = renderer.image { context in
            UIColor.black.setFill()
            
            // Arrow body
            context.cgContext.fill(CGRect(x: 146, y: 88, width: 40, height: 16))
            
            // Arrow head
            context.cgContext.move(to: CGPoint(x: 172, y: 76))
            context.cgContext.addLine(to: CGPoint(x: 172, y: 116))
            context.cgContext.addLine(to: CGPoint(x: 192, y: 96))
            context.cgContext.addLine(to: CGPoint(x: 172, y: 76))
            context.cgContext.drawPath(using: .fill)
        }
        
        arrow = SKSpriteNode(texture: SKTexture(image: arrowImage))
        arrow.position = monkey.position
        arrow.zPosition = 1
        arrow.isHidden = true
        addChild(arrow)
        
        arrow.run(.repeatForever(.sequence([
            .fadeOut(withDuration: 1),
            .fadeIn(withDuration: 0)
        ])))
    }
    
    func setRotation(to angle: Float, withThrowingDirection throwingDirection: ThrowDirection) {
        let radians: CGFloat
        
        if throwingDirection == .right {
            radians = CGFloat(-angle * Float.pi / 180)
        } else {
            radians = CGFloat((angle + 180) * Float.pi / 180)
        }
        
        let renderer = UIGraphicsImageRenderer(size: arrowImage.size)
        let rotatedArrowImage = renderer.image { context in
            context.cgContext.translateBy(x: arrowImage.size.width / 2, y: arrowImage.size.height / 2)
            context.cgContext.rotate(by: radians)
            arrowImage.draw(at: CGPoint(x: -arrowImage.size.width / 2, y: -arrowImage.size.height / 2))
        }
        
        arrow.texture = SKTexture(image: rotatedArrowImage)
    }
}
