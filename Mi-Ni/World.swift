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
    
    private var background: SKSpriteNode?
    private var droppers = [SKSpriteNode]()
    private var environment = [SKSpriteNode?]()
    
    var yellowCar: Car?
    var greenCar : Car?
    
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
                element.physicsBody!.categoryBitMask = UInt32(1)
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
        
        yellowCar = Car(
            childNode(withName: "//yellowMini") as! SKSpriteNode,
            childNode(withName: "yellowIcon")?.childNode(withName: "//yellowScore") as! SKLabelNode as SKLabelNode, 4
        )
        greenCar = Car(
            childNode(withName: "//greenMini") as! SKSpriteNode,
            childNode(withName: "greenIcon")?.childNode(withName: "//greenScore") as! SKLabelNode as SKLabelNode, 8
        )
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 0: greenCar!.isLeftMovementKeyDown = true
            case 2: greenCar!.isRightMovementKeyDown = true
            case 123: yellowCar!.isLeftMovementKeyDown = true
            case 124: yellowCar!.isRightMovementKeyDown = true
            default: break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            case 0: greenCar!.isLeftMovementKeyDown = false
            case 2: greenCar!.isRightMovementKeyDown = false
            case 123: yellowCar!.isLeftMovementKeyDown = false
            case 124: yellowCar!.isRightMovementKeyDown = false
            case 53: exit(0)
            default: break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        switch (contact.bodyA.node?.name, contact.bodyB.node?.name) {
            case ("floor", "miNote"), ("floor", "niNote"):
                contact.bodyB.node?.removeFromParent()
            case ("miNote", "floor"), ("niNote", "floor"):
                contact.bodyA.node?.removeFromParent()
            case ("floor", "miNoteBonus"), ("floor", "niNoteBonus"):
                contact.bodyB.node?.removeFromParent()
            case ("miNoteBonus", "floor"), ("niNoteBonus", "floor"):
                contact.bodyA.node?.removeFromParent()

            /// Yellow catches miNote: +1
            case ("miNote", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "miNote"):
                contact.bodyB.node?.removeFromParent()
                yellowCar!.scoreValue += 1

            /// Yellow catches niNote: -1
            case ("niNote", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                yellowCar!.scoreValue -= 1

            /// Yellow catches miNoteBonus: +3
            case ("miNoteBonus", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "miNoteBonus"):
                contact.bodyB.node?.removeFromParent()
                yellowCar!.scoreValue += 3

            /// Yellow catches niNoteBonus: -3
            case ("niNoteBonus", "yellowMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("yellowMini", "niNoteBonus"):
                contact.bodyB.node?.removeFromParent()
                yellowCar!.scoreValue -= 3

            /// Green catches niNote: +1
            case ("niNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "niNote"):
                contact.bodyB.node?.removeFromParent()
                greenCar!.scoreValue += 1

            /// Green catches miNote: -1
            case ("miNote", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "miNote"):
                contact.bodyB.node?.removeFromParent()
                greenCar!.scoreValue -= 1

            /// Green catches niNoteBonus: +3
            case ("niNoteBonus", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "niNoteBonus"):
                contact.bodyB.node?.removeFromParent()
                greenCar!.scoreValue += 3

            /// Green catches miNoteBonus: -3
            case ("miNoteBonus", "greenMini"):
                contact.bodyA.node?.removeFromParent()
                fallthrough
            case ("greenMini", "miNoteBonus"):
                contact.bodyB.node?.removeFromParent()
                greenCar!.scoreValue -= 3
            
            default: break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Driving
        yellowCar!.update(currentTime)
        greenCar!.update(currentTime)
        
        // Note spawning
        let spawnChance = Float.random(in: 0...1)
        guard spawnChance < 0.025 else { return }
        let dropper = droppers.randomElement()!
        guard dropper.children == [] else { return }
        let noteType = ["mi", "ni"].randomElement()!
        let note = SKSpriteNode(
            texture: SKTexture(imageNamed: "\(noteType)\(spawnChance > 0.005 ? "Alt" : "Bonus")"),
            size: CGSize(width: 120, height: 150)
        )
        note.physicsBody = SKPhysicsBody(rectangleOf: note.size)
        note.physicsBody!.categoryBitMask = UInt32(2)
        note.physicsBody!.contactTestBitMask = UInt32(1) | UInt32(4) | UInt32(8)
        note.position = dropper.convert(dropper.position, to: self)
        note.name = "\(noteType)Note\(spawnChance <= 0.005 ? "Bonus" : "")"
        note.zPosition = 5
        dropper.addChild(note)
        if spawnChance <= 0.005 {
            note.addChild(SKSpriteNode(texture: SKTexture(imageNamed: "noteBackground"), size: CGSize(width: 200, height: 200)))
            note.children.first!.zPosition = -1
            note.children.first!.run(
                SKAction.repeatForever(SKAction.rotate(byAngle: 10, duration: 2))
            )
        }
    }
    
}
