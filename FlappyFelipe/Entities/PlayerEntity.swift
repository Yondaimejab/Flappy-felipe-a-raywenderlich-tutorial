//
//  PlayerEntity.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 2/6/22.
//

import GameplayKit
import SpriteKit
import Foundation

class PlayerEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    var movementComponent: MovementComponent!
    var animationComponent: AnimationComponent!
    var movementAllowed = false
    var numberOfFrames = 3
    
    init(imageName: String) {
        super.init()
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        movementComponent = MovementComponent(entity: self)
        addComponent(movementComponent)
        movementComponent.applyInitialImpulse()
        var textures: [SKTexture] = (1...3).map({ SKTexture(imageNamed: "Bird\($0)") })
        for item in stride(from: numberOfFrames, to: 0, by: -1) {
            textures.append(SKTexture(imageNamed: "Bird\(item)"))
        }
        animationComponent = AnimationComponent(entity: self, textures: textures)
        addComponent(animationComponent)
        // Add Physics
        let spriteNode = spriteComponent.node
        spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: spriteNode.frame.size)
        spriteNode.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Player
        spriteNode.physicsBody?.collisionBitMask = 0
        spriteNode.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.Ground | GameScene.PhysicsCategory.Obstacle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
