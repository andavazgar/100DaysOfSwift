//
//  BuildingNode.swift
//  Project 29
//
//  Created by Andres Vazquez on 2020-03-19.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
    
    func setup() {
        self.name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
        
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let color: UIColor
            
            switch Int.random(in: 0...2) {
                case 0:
                    color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
                case 1:
                    color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
                
                default:
                    color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            color.setFill()
            
            context.cgContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            // draw windows
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    context.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        return image
    }
    
    private func configurePhysics() {
        guard let texture = texture else {
            print("ERROR: BuildingNode[ConfigurePhysics] - The building has no texture")
            return
        }
        
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionType.building.rawValue
        physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
    }
    
    func hit(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - size.height / 2))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            currentImage.draw(at: .zero)
            
            context.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            context.cgContext.setBlendMode(.clear)
            context.cgContext.drawPath(using: .fill)
        }
        
        currentImage = image
        texture = SKTexture(image: currentImage)
        configurePhysics()
    }
}
