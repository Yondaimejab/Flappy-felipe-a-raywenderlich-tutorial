//
//  TutorialState.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import GameplayKit
import SpriteKit

class TutorialState: GKState {
    let scene: GameScene!
    
    init(scene: SKScene) {
        guard let gameScene = scene as? GameScene else { fatalError("failed") }
        self.scene = gameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        setupTutorial()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is PlayingState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    
    }
    
    func setupTutorial() {
        scene.setupBackground()
        scene.setupForeground()
        scene.setupPlayerEntity()
        scene.setupScoreLabel()
        
        // Tutorial
        let tutorialNode = SKSpriteNode(imageNamed: "Tutorial")
        tutorialNode.position = CGPoint(x: scene.size.width * 0.5, y: scene.playableHeight * 0.4 + scene.playableStart)
        tutorialNode.name = "Tutorial"
        tutorialNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(tutorialNode)
        
        // Ready
        let readyNode = SKSpriteNode(imageNamed: "Ready")
        readyNode.position = CGPoint(x: scene.size.width * 0.5, y: scene.playableHeight * 0.7 + scene.playableStart)
        readyNode.name = "Tutorial"
        readyNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(readyNode)
    }
    
    override func willExit(to nextState: GKState) {
        scene.worldNode.enumerateChildNodes(withName: "Tutorial", using: { node, stop in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        })
    }
}
