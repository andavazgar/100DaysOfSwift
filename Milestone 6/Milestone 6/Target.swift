//
//  Target.swift
//  Milestone 6
//
//  Created by Andres Vazquez on 2020-03-01.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit

class Target: SKNode {
    var target: SKSpriteNode!
    var stick: SKSpriteNode!
    var value: Int!

    func setup() {
        let stickType = Int.random(in: 0...2)
        let targetType = Int.random(in: 0...3)

        stick = SKSpriteNode(imageNamed: "stick\(stickType)")
        target = SKSpriteNode(imageNamed: "target\(targetType)")

        target.name = "target"
        target.position.y += 116

        addChild(stick)
        addChild(target)
    }

    func hit() {
        removeAllActions()
        target.name = nil

        let animationTime = 0.2
        target.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        stick.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        run(SKAction.fadeOut(withDuration: animationTime))
        run(SKAction.moveBy(x: 0, y: -30, duration: animationTime))
        run(SKAction.scaleX(by: 0.8, y: 0.7, duration: animationTime))
    }
}

