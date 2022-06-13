//
//  PlayingState.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import GameplayKit
import SpriteKit

class PlayingState: GKState {
    let scene: GameScene!
    
    init(scene: SKScene) {
        guard let gameScene = scene as? GameScene else { fatalError("failed") }
        self.scene = gameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.startSpawning()
        scene.playerEntity.movementAllowed = true
        scene.playerEntity.animationComponent.startAnimation()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == FallingState.self || stateClass == GameOverState.self
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        scene.updateForeground()
        scene.updateScore()
    }
}
