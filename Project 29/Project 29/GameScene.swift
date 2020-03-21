//
//  GameScene.swift
//  Project 29
//
//  Created by Andres Vazquez on 2020-03-19.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController?
    
    var player1: MonkeyNode!
    var player2: MonkeyNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    // MARK: - Life cycle methods
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuildings()
        createPlayers()
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    
    // MARK: - SKPhysicsContactDelegate methods
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        } else if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: secondNode)
        } else if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: secondNode)
        }
    }
    
    
    // MARK: - Custom methods
    private func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < frame.width {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10
        let radians = deg2rad(degrees: angle)
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = MonkeyNode.createBanana()
        banana.name = "banana"
        addChild(banana)
        
        if currentPlayer == 1 {
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            player1.throw(banana, toThe: .right, withImpulse: impulse)
        } else {
            let impulse = CGVector(dx: -cos(radians) * speed, dy: sin(radians) * speed)
            player2.throw(banana, toThe: .left, withImpulse: impulse)
        }
    }
    
    private func createPlayers() {
        // Player 1
        player1 = MonkeyNode()
        player1.name = "player1"
        
        let player1Building = buildings[1]
        
        player1.setup(onTopOf: player1Building)
        player1.arrow.isHidden = false
        addChild(player1)
        
        // Player 2
        player2 = MonkeyNode()
        player2.name = "player2"
        
        let player2Building = buildings[buildings.count - 2]
        
        player2.setup(onTopOf: player2Building)
        addChild(player2)
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180
    }
    
    private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    private func destroy(player: SKNode) {
        if let explision = SKEmitterNode(fileNamed: "hitPlayer") {
            explision.position = player.position
            addChild(explision)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            newGame.viewController?.setDefaultValues()
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    private func changePlayer() {
        currentPlayer = (currentPlayer == 1) ? 2 : 1
        
        if currentPlayer == 1 {
            player1.arrow.isHidden = false
            player2.arrow.isHidden = true
        } else {
            player1.arrow.isHidden = true
            player2.arrow.isHidden = false
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }
}
