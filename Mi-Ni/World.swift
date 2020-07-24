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
    
    private var floor: SKSpriteNode?
    private var leftWall: SKSpriteNode?
    private var rightWall: SKSpriteNode?
    private var car: SKSpriteNode?
    private let velocity: CGFloat = 10
    private var droppers = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
//        let background = SKSpriteNode(imageNamed: "background.jpg")
//        background.position = CGPoint(x: 512, y: 384)
//        background.blendMode = .replace
//        background.zPosition = -1
//        addChild(background)
        
        floor = childNode(withName: "//floor") as? SKSpriteNode
        if let floor = floor {
            floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
            floor.physicsBody?.affectedByGravity = false
            floor.physicsBody?.isDynamic = false
            floor.physicsBody!.contactTestBitMask = floor.physicsBody!.collisionBitMask
        }
        leftWall = childNode(withName: "//leftWall") as? SKSpriteNode
        if let leftWall = leftWall {
            leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
            leftWall.physicsBody?.affectedByGravity = false
            leftWall.physicsBody?.isDynamic = false
            leftWall.physicsBody!.contactTestBitMask = leftWall.physicsBody!.collisionBitMask
        }
        rightWall = childNode(withName: "//rightWall") as? SKSpriteNode
        if let rightWall = rightWall {
            rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
            rightWall.physicsBody?.affectedByGravity = false
            rightWall.physicsBody?.isDynamic = false
            rightWall.physicsBody!.contactTestBitMask = rightWall.physicsBody!.collisionBitMask
        }
        
        let dropperGroup = childNode(withName: "//droppers")
        droppers = dropperGroup?.children as? [SKSpriteNode] ?? []
        
        let width = (size.width + size.height) * 0.05
        car = SKSpriteNode(texture: SKTexture(imageNamed: "yellowMini"), color: .black, size: CGSize(width: width * 2.4, height: width))
        if let car = car, let floor = floor {
            car.position = CGPoint(
                x: floor.anchorPoint.x,
                y: floor.position.y + ((floor.size.height + width) / 2)
            )
            car.name = "car"
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
            if let car = car {
                car.position.x -= velocity
            }
        case 124: // Right arrow
            if let car = car {
                car.position.x += velocity
            }
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
        let spawnChance = Float.random(in: 0...1)
        guard spawnChance < 0.025 else { return }
        let dropper = droppers.randomElement()!
        guard dropper.children == [] else { return }
        let ball = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 200, height: 200))
        ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
        ball.physicsBody?.restitution = 0.4
        ball.position = dropper.convert(dropper.position, to: self)
        ball.name = "note"
        dropper.addChild(ball)
    }
    
}
