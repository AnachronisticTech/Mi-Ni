//
//  Car.swift
//  Mi-Ni
//
//  Created by Daniel Marriner on 26/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SpriteKit

class Car {
    private var sprite: SKSpriteNode
    private var score : SKLabelNode
    var scoreValue = 0 {
        didSet {
            if scoreValue < 0 { scoreValue = 0 }
            score.text = "\(scoreValue)"
        }
    }
    
    var isLeftMovementKeyDown = false
    var isRightMovementKeyDown = false
    
    var currentVelocity: CGFloat = 0 {
        didSet {
            if oldValue <= 0 && currentVelocity > 0.1 { // point right
                sprite.run(SKAction.scaleX(to: 0.2, duration: 0.4))
            } else if oldValue >= 0 && currentVelocity < -0.1 { // point left
                sprite.run(SKAction.scaleX(to: -0.2, duration: 0.4))
            }
        }
    }
    
    init(_ spriteNode: SKSpriteNode, _ scoreLabelNode: SKLabelNode, _ categoryBitMaskOverride: Int = 1) {
        sprite = spriteNode
        sprite.zPosition = 10
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = true
        sprite.physicsBody!.categoryBitMask = UInt32(categoryBitMaskOverride)
        sprite.physicsBody!.collisionBitMask = UInt32(1) | UInt32(2)
        sprite.physicsBody!.contactTestBitMask = sprite.physicsBody!.collisionBitMask
        
        score = scoreLabelNode
    }
    
    func update(_ currentTime: TimeInterval) {
        let rate:CGFloat = 0.05
        if !(isLeftMovementKeyDown && isRightMovementKeyDown) && (isLeftMovementKeyDown || isRightMovementKeyDown) {
            sprite.physicsBody!.velocity = CGVector(dx: 5000 * rate * (isLeftMovementKeyDown ? -1 : 1), dy: 0)
        }
        currentVelocity = sprite.physicsBody!.velocity.dx
    }
}
