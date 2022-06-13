//
//  FailingState.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import GameplayKit
import SpriteKit

class FallingState: GKState {
    let scene: GameScene!
    let whackAction = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let fallingAction = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    
    init(scene: SKScene) {
        guard let gameScene = scene as? GameScene else { fatalError("could not load") }
        self.scene = gameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        let sequence = SKAction.sequence([whackAction, SKAction.wait(forDuration: 0.1), fallingAction])
        scene.run(sequence)
        scene.stopSpawning()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOverState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
}
