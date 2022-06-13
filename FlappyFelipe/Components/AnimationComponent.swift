//
//  AnimationComponent.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 10/6/22.
//

import GameplayKit
import SpriteKit

class AnimationComponent: GKComponent {
    let spriteComponent: SpriteComponent
    var textures: Array<SKTexture> = []
    
    init(entity: GKEntity, textures: [SKTexture]) {
        spriteComponent = entity.component(ofType: SpriteComponent.self)!
        self.textures = textures
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let player = entity as? PlayerEntity else { return }
        if player.movementAllowed {
            startAnimation()
        } else {
            stopAnimation(forKey: "Flap")
        }
    }
    
    func startAnimation() {
        guard nil == spriteComponent.node.action(forKey: "Flap") else { return }
        let playerAction = SKAction.animate(with: textures, timePerFrame: 0.07)
        let repetitionAction = SKAction.repeatForever(playerAction)
        spriteComponent.node.run(repetitionAction, withKey: "Flap")
    }
    
    func stopAnimation(forKey key: String) {
        spriteComponent.node.removeAction(forKey: key)
    }
    
}
