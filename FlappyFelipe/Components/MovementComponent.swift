//
//  MovementComponent.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 2/6/22.
//

import GameplayKit
import SpriteKit
import Foundation

class MovementComponent: GKComponent {
    
    // Constants
    let spriteComponent: SpriteComponent
    private let gravity = CGFloat(-1500)
    private let impulse = CGFloat(400)
    
    // Properties
    private var velocity = CGPoint.zero
    var playableStart: CGFloat = 0.0
    
    // More on Velocity
    var velocityModifier: CGFloat = 1000
    var angularVelocity: CGFloat = 0.0
    let minDegrees: CGFloat = -90
    let maxDegrees: CGFloat = 25
    
    var lastTouchTime: TimeInterval = 0.0
    var lasyTouchY: CGFloat = 0.0
    
    // Lifecycle
    init(entity: GKEntity) {
        guard let newComponent = entity.component(ofType: SpriteComponent.self) else {
            fatalError("Could not create entity component from type \(SpriteComponent.self)")
        }
        spriteComponent = newComponent
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Behavior
    func applyMovement(_ seconds: TimeInterval) {
        let spriteNode = spriteComponent.node
        let gravityStep = CGPoint(x: 0.0, y: gravity * CGFloat(seconds))
        velocity = CGPoint(x: velocity.x + gravityStep.x, y: velocity.y + gravityStep.y)
        let velocityStep = CGPoint(x: velocity.x * CGFloat(seconds), y: velocity.y * CGFloat(seconds))
        spriteNode.position = CGPoint(x: spriteNode.position.x + velocityStep.x, y: spriteNode.position.y + velocityStep.y)
        if spriteNode.position.y < lasyTouchY {
            angularVelocity = CGFloat(GLKMathDegreesToRadians(-Float(velocityModifier)))
        }
        let angularStep = angularVelocity * CGFloat(seconds)
        spriteNode.zRotation += angularStep
        spriteNode.zRotation = min(
            max(spriteNode.zRotation, CGFloat(GLKMathDegreesToRadians(Float(minDegrees)))),
            CGFloat(GLKMathDegreesToRadians(Float(maxDegrees)))
        )
        // ground hit
        if (spriteNode.position.y - spriteNode.size.height / 2) < playableStart {
            spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableStart + (spriteNode.size.height / 2))
        }
    }
    
    func applyInitialImpulse() {
        velocity = CGPoint(x: 0, y: impulse * 2)
    }
    
    func applyImpulse(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: impulse)
        angularVelocity = CGFloat(GLKMathDegreesToRadians(Float(velocityModifier)))
        lastTouchTime = lastUpdateTime
        lasyTouchY = spriteComponent.node.position.y
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerEntity = entity as? PlayerEntity else { return }
        guard playerEntity.movementAllowed else { return }
        applyMovement(seconds)
    }
}
