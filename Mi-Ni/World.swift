//
//  World.swift
//  Mi-Ni
//
//  Created by Daniel Marriner on 24/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SpriteKit
import GameplayKit

class World: SKScene, SKPhysicsContactDelegate {
    
    var isAKeyDown = false
    var isDKeyDown = false
    var isLeftKeyDown = false
    var isRightKeyDown = false
    
    private var greenMini: SKSpriteNode?
    private var yellowMini: SKSpriteNode?
    private var background: SKSpriteNode?
    private var droppers = [SKSpriteNode]()
    private var environment = [SKSpriteNode?]()
    private var yellowScore: SKLabelNode!
    private var greenScore: SKLabelNode!
    
    var yellowScoreValue = 0 {
        didSet { yellowScore.text = "\(yellowScoreValue)" }
    }
    var greenScoreValue = 0 {
        didSet { greenScore.text = "\(greenScoreValue)" }
    }
    
    override func didMove(to view: SKView) {
        
        scaleMode = .aspectFit
        physicsWorld.contactDelegate = self
        physicsWorld.gravity.dy = -2
        
        environment = [
            childNode(withName: "//floor") as? SKSpriteNode,
            childNode(withName: "//leftWall") as? SKSpriteNode,
            childNode(withName: "//rightWall") as? SKSpriteNode
        ]
        for element in environment {
            if let element = element {
                element.physicsBody = SKPhysicsBody(rectangleOf: element.size)
                element.physicsBody!.affectedByGravity = false
                element.physicsBody!.isDynamic = false
                element.physicsBody!.contactTestBitMask = element.physicsBody!.collisionBitMask
            }
        }
        
        let locations = [
            "amsterdam", "athens", "berlin", "london",
            "newYork", "paris", "rome", "washington"
        ]
        background = childNode(withName: "//background") as? SKSpriteNode
        background?.texture = SKTexture(imageNamed: locations.randomElement()!)
        
        let dropperGroup = childNode(withName: "//droppers")
        droppers = dropperGroup?.children as? [SKSpriteNode] ?? []
        
        yellowScore = childNode(withName: "yellowIcon")?.childNode(withName: "//yellowScore") as! SKLabelNode as SKLabelNode
        yellowMini = childNode(withName: "//yellowMini") as? SKSpriteNode
        if let car = yellowMini {
            car.zPosition = 10
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody!.affectedByGravity = true
            car.physicsBody!.contactTestBitMask = car.physicsBody!.collisionBitMask
        }
        
        greenScore = childNode(withName: "greenIcon")?.childNode(withName: "//greenScore") as! SKLabelNode as SKLabelNode
        greenMini = childNode(withName: "//greenMini") as? SKSpriteNode
        if let car = greenMini {
            car.zPosition = 10
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody!.affectedByGravity = true
            car.physicsBody!.contactTestBitMask = car.physicsBody!.collisionBitMask
        }
        // cars should ignore each other's collisions
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 0: isAKeyDown = true
            case 2: isDKeyDown = true
            case 123: isLeftKeyDown = true
            case 124: isRightKeyDown = true
            default: break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            case 0: isAKeyDown = false
            case 2: isDKeyDown = false
            case 123: isLeftKeyDown = false
            case 124: isRightKeyDown = false
            case 53: exit(0)
            default: break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        switch (contact.bodyA.node?.name, contact.bodyB.node?.name) {
    //        case ("yellowMini", "leftWall"), ("leftWall", "yellowMini"):
    //            print("car and wall collided")
    //        case ("yellowMini", "rightWall"), ("rightWall", "yellowMini"):
    //            print("yellowMini and wall collided")
            case ("floor", "miNote"), ("floor", "niNote"):
                contact.bodyB.node?.removeFromParent()
            case ("miNote", "floor"), ("niNote", "floor"):
                contact.bodyA.node?.removeFromParent()

            /// Yellow catches miNote: +1
            case ("miNote", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "miNote"):
                contact.bodyB.node?.removeFromParent()
                yellowScoreValue += 1

            /// Yellow catches niNote: -1
            case ("niNote", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                if yellowScoreValue > 0 { yellowScoreValue -= 1 }

            /// Green catches niNote: +1
            case ("niNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                greenScoreValue += 1

            /// Green catches miNote: -1
            case ("miNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "miNote"):
                contact.bodyB.node?.removeFromParent()
                if greenScoreValue > 0 { greenScoreValue -= 1 }
            default: break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Driving
        let rate: CGFloat = 0.05
        if !(isLeftKeyDown && isRightKeyDown) && (isLeftKeyDown || isRightKeyDown) {
            yellowMini!.physicsBody!.velocity = CGVector(dx: 5000 * rate * (isLeftKeyDown ? -1 : 1), dy: 0)
        }
        if !(isAKeyDown && isDKeyDown) && (isAKeyDown || isDKeyDown) {
            greenMini!.physicsBody!.velocity = CGVector(dx: 5000 * rate * (isAKeyDown ? -1 : 1), dy: 0)
        }
        
        // Note spawning
        let spawnChance = Float.random(in: 0...1)
        guard spawnChance < 0.025 else { return }
        let dropper = droppers.randomElement()!
        guard dropper.children == [] else { return }
        let noteType = ["mi", "ni"].randomElement()!
        let note = SKSpriteNode(
            texture: SKTexture(imageNamed: "\(noteType)Alt"),
            color: .red,
            size: CGSize(width: 100, height: 100)
        )
        note.physicsBody = SKPhysicsBody(rectangleOf: note.size)
        note.position = dropper.convert(dropper.position, to: self)
        note.name = "\(noteType)Note"
        note.zPosition = 5
        dropper.addChild(note)
    }
    
}
