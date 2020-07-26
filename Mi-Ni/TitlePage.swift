//
//  TitlePage.swift
//  Mi-Ni
//
//  Created by Daniel Marriner on 26/07/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import SpriteKit

class TitlePage: SKScene {
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFit
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        if let node = nodes(at: location).first {
            switch node.name {
                case "singleplayer":
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    let worldScene = World(fileNamed: "World.sks")!
                    worldScene.scaleMode = .aspectFit
                    worldScene.isSingleplayerMode = true
                    scene?.view?.presentScene(worldScene, transition: transition)
                case "multiplayer":
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    let worldScene = World(fileNamed: "World.sks")!
                    worldScene.scaleMode = .aspectFit
                    worldScene.isSingleplayerMode = false
                    scene?.view?.presentScene(worldScene, transition: transition)
                default: break
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            case 53: exit(0)
            default: break
        }
    }
    
}
