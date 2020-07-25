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
    
    var yellowScore = 0
    var greenScore = 0
    
    override func didMove(to view: SKView) {
        
        scaleMode = .aspectFit
        physicsWorld.contactDelegate = self
        
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
        
        yellowMini = childNode(withName: "//yellowMini") as? SKSpriteNode
        if let car = yellowMini {
            car.zPosition = 10
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody!.affectedByGravity = true
            car.physicsBody!.contactTestBitMask = car.physicsBody!.collisionBitMask
        }
        
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
                yellowScore += 1
                print("Yellow score: \(yellowScore)")

            /// Yellow catches niNote: -1
            case ("niNote", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                if yellowScore > 0 { yellowScore -= 1 }
                print("Yellow score: \(yellowScore)")

            /// Green catches niNote: +1
            case ("niNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                greenScore += 1
                print("Green score: \(greenScore)")

            /// Green catches miNote: -1
            case ("miNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "miNote"):
                contact.bodyB.node?.removeFromParent()
                if greenScore > 0 { greenScore -= 1 }
                print("Green score: \(greenScore)")
            default: break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Driving
        let rate: CGFloat = 0.05 // BUG: Moving left faster than moving right
        if !(isLeftKeyDown && isRightKeyDown) && (isLeftKeyDown || isRightKeyDown) {
            let relativeVelocity = CGVector(
                dx: 200 - yellowMini!.physicsBody!.velocity.dx,
                dy: 200 - yellowMini!.physicsBody!.velocity.dy
            )
            yellowMini!.physicsBody!.velocity = CGVector(
                dx: yellowMini!.physicsBody!.velocity.dx + relativeVelocity.dx * rate * (isLeftKeyDown ? -1 : 1),
                dy: yellowMini!.physicsBody!.velocity.dy + relativeVelocity.dy * rate
            )
        }
        if !(isAKeyDown && isDKeyDown) && (isAKeyDown || isDKeyDown) {
            let relativeVelocity = CGVector(
                dx: 200 - greenMini!.physicsBody!.velocity.dx,
                dy: 200 - greenMini!.physicsBody!.velocity.dy
            )
            greenMini!.physicsBody!.velocity = CGVector(
                dx: greenMini!.physicsBody!.velocity.dx + relativeVelocity.dx * rate * (isAKeyDown ? -1 : 1),
                dy: greenMini!.physicsBody!.velocity.dy + relativeVelocity.dy * rate
            )
        }
        
        // Note spawning
        let spawnChance = Float.random(in: 0...1)
        guard spawnChance < 0.025 else { return }
        let dropper = droppers.randomElement()!
        guard dropper.children == [] else { return }
        let noteType = ["mi", "ni"].randomElement()!
        let note = SKSpriteNode(
            texture: SKTexture(imageNamed: noteType),
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
