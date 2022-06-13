//
//  ObstacleEntity.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import SpriteKit
import GameplayKit

class ObstacleEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    
    init(imageName: String) {
        super.init()
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        // Add Physics
        let spriteNode = spriteComponent.node
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Obstacle
        spriteNode.physicsBody?.collisionBitMask = 0
        spriteNode.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.Player
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
