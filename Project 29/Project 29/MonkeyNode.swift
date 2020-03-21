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
    private let arrowCanvasSize = 192 * 2
    private var arrowImage: UIImage!        // Image of only the arrow [Size: 50 x 40]
    private var rotatedImage: UIImage?      // Image of arrow in canvas (rotated) [Size: 384 x 384]
    private var stretchedImage: UIImage?    // Image of arrow in canvas (stretched) [Size: 384 x 384]
    
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
        var renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 40))
        arrowImage = renderer.image { context in
            UIColor.black.setFill()
            
            // Arrow body
            context.cgContext.fill(CGRect(x: 0, y: 10, width: 40, height: 20))
            
            // Arrow head
            context.cgContext.move(to: CGPoint(x: 30, y: 0))
            context.cgContext.addLine(to: CGPoint(x: 30, y: 40))
            context.cgContext.addLine(to: CGPoint(x: 50, y: 20))
            context.cgContext.addLine(to: CGPoint(x: 30, y: 0))
            context.cgContext.drawPath(using: .fill)
        }
        
        renderer = UIGraphicsImageRenderer(size: CGSize(width: arrowCanvasSize, height: arrowCanvasSize))
        let canvasWithArrow = renderer.image { context in
            // Move origin to center
            context.cgContext.translateBy(x: CGFloat(arrowCanvasSize / 2), y: CGFloat(arrowCanvasSize / 2))
            
            arrowImage.draw(at: CGPoint(x: 46, y: -20))
        }
        
        arrow = SKSpriteNode(texture: SKTexture(image: canvasWithArrow))
        arrow.position = monkey.position
        arrow.zPosition = 1
        arrow.isHidden = true
        addChild(arrow)
        
        arrow.run(.repeatForever(.sequence([
            .fadeOut(withDuration: 1),
            .fadeIn(withDuration: 0)
        ])))
    }
    
    func transformArrow(withRotationAngle rotationAngle: Float, velocity: Float, throwingDirection: ThrowDirection) {
        let radians: CGFloat
        
        if throwingDirection == .right {
            radians = CGFloat(-rotationAngle * Float.pi / 180)
        } else {
            radians = CGFloat((rotationAngle + 180) * Float.pi / 180)
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: arrowCanvasSize, height: arrowCanvasSize))
        let rotatedArrowImage = renderer.image { context in
            // Move origin to center
            context.cgContext.translateBy(x: CGFloat(arrowCanvasSize / 2), y: CGFloat(arrowCanvasSize / 2))
            
            // Rotation
            context.cgContext.rotate(by: radians)
            
            // Stretch
            let imageWidth = arrowImage.size.width + CGFloat(velocity / 250) * arrowImage.size.width
            let imageHeight = arrowImage.size.height + CGFloat(velocity / 250) * arrowImage.size.height
            arrowImage.draw(in: CGRect(x: 46, y: -imageHeight / 2, width: imageWidth, height: imageHeight))
        }
        
        arrow.texture = SKTexture(image: rotatedArrowImage)
    }
}
