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
    
    var isLeftKeyDown = false
    var isRightKeyDown = false
    
    private var car: SKSpriteNode?
    private var background: SKSpriteNode?
    private var droppers = [SKSpriteNode]()
    private var environment = [SKSpriteNode?]()
    
    override func didMove(to view: SKView) {
        
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
        
        let width = (size.width + size.height) * 0.05
        car = SKSpriteNode(texture: SKTexture(imageNamed: "yellowMini"), color: .black, size: CGSize(width: width * 2.4, height: width))
        if let car = car, let floor = environment[0] {
            car.position = CGPoint(
                x: floor.anchorPoint.x,
                y: floor.position.y + ((floor.size.height + width) / 2)
            )
            car.name = "car"
            car.zPosition = 10
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody?.affectedByGravity = true
            car.physicsBody!.contactTestBitMask = car.physicsBody!.collisionBitMask
            addChild(car)
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        // a is 0, d is 2
        switch event.keyCode {
        case 123: // Left arrow
            isLeftKeyDown = true
        case 124: // Right arrow
            isRightKeyDown = true
        default: break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        // a is 0, d is 2
        switch event.keyCode {
        case 123: // Left arrow
            isLeftKeyDown = false
        case 124: // Right arrow
            isRightKeyDown = false
        case 53: // Escape
            exit(0)
        default: break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        switch (contact.bodyA.node?.name, contact.bodyB.node?.name) {
        case ("car", "leftWall"), ("leftWall", "car"):
            print("car and wall collided")
        case ("car", "rightWall"), ("rightWall", "car"):
            print("car and wall collided")
        case ("floor", "note"):
            contact.bodyB.node?.removeFromParent()
        case ("note", "floor"):
            contact.bodyA.node?.removeFromParent()
        case ("car", "note"):
            contact.bodyB.node?.removeFromParent()
        case ("note", "car"):
            contact.bodyA.node?.removeFromParent()
        default: break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Driving
        if !(isLeftKeyDown && isRightKeyDown) {
            let rate: CGFloat = 0.05
            let relativeVelocity = CGVector(
                dx: 200 - (car!.physicsBody?.velocity.dx)!,
                dy: 200 - (car!.physicsBody?.velocity.dy)!
            )
            if isLeftKeyDown || isRightKeyDown {
                car!.physicsBody!.velocity = CGVector(
                    dx: car!.physicsBody!.velocity.dx + relativeVelocity.dx * rate * (isLeftKeyDown ? -1 : 1),
                    dy: car!.physicsBody!.velocity.dy + relativeVelocity.dy * rate
                )
            }
        }
        
        // Note spawning
        let spawnChance = Float.random(in: 0...1)
        guard spawnChance < 0.025 else { return }
        let dropper = droppers.randomElement()!
        guard dropper.children == [] else { return }
        let note = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 200, height: 200))
        note.physicsBody = SKPhysicsBody(rectangleOf: note.size)
        note.physicsBody?.restitution = 0.4
        note.position = dropper.convert(dropper.position, to: self)
        note.name = "note"
        note.zPosition = 5
        dropper.addChild(note)
    }
    
}
