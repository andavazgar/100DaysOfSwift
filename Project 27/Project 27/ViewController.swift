//
//  ViewController.swift
//  Project 27
//
//  Created by Andres Vazquez on 2020-03-12.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }

    @IBAction func redrawBtnTapped(_ sender: UIButton) {
        currentDrawType = (currentDrawType + 1) % 7
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawStar()
        default:
            break
        }
    }
    
    private func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    private func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    private func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        context.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = image
    }
    
    private func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            let numOfRotations = 16
            let amountToRotate = Double.pi / Double(numOfRotations)
            
            context.cgContext.translateBy(x: 256, y: 256)
            
            for _ in 0 ..< numOfRotations {
                context.cgContext.rotate(by: CGFloat(amountToRotate))
                context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    private func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                context.cgContext.rotate(by: .pi / 2)
                
                if first {
                    context.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    private func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .title1),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            let attrString = NSAttributedString(string: string, attributes: attrs)
            
            attrString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            
            let image = UIImage(named: "mouse")
            image?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = image
    }
    
    private func drawStar() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)
            
            var isFirstPoint = true
            
            // This is needed to make the star point to the top
            context.cgContext.rotate(by: .pi / 5)
            
            for _ in 0 ..< 5 {
                if isFirstPoint {
                    context.cgContext.move(to: CGPoint(x: 93, y: 128))
                    isFirstPoint = false
                }
                context.cgContext.addLine(to: CGPoint(x: 0, y: 256))
                context.cgContext.addLine(to: CGPoint(x: -93, y: 128))
                
                context.cgContext.rotate(by: 2 * .pi / 5)
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setFillColor(UIColor.systemYellow.cgColor)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
}

