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
    
    
    func setup(onTopOf building: BuildingNode) {
        monkey = SKSpriteNode(imageNamed: "player")
        monkey.position = CGPoint(x: building.position.x, y: building.size.height + monkey.size.height / 2)
        
        monkey.physicsBody = SKPhysicsBody(circleOfRadius: monkey.size.width / 2)
        monkey.physicsBody?.isDynamic = false
        monkey.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        monkey.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        monkey.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        addChild(monkey)
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
}
