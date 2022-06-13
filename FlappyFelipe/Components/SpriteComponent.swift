//
//  SpriteComponent.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 2/6/22.
//

import GameplayKit
import SpriteKit

class SpriteComponent: GKComponent {
    var node: EntityNode
    
    init(entity: GKEntity, texture: SKTexture, size: CGSize) {
        node = EntityNode(texture: texture, color: SKColor.cyan, size: size)
        node.entity = entity
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("This method has not been implemented yet")
    }
}
