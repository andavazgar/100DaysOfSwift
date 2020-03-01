//
//  GameScene.swift
//  Milestone 6
//
//  Created by Andres Vazquez on 2020-02-29.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -2
        background.blendMode = .replace
        addChild(background)
        
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        curtains.zPosition = -1
//        back rground.blendMode = .replace
        addChild(curtains)
    }
}
