//
//  MenuState.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import GameplayKit
import SpriteKit

class MainMenuState: GKState {
    let scene: GameScene!
    
    init(scene: SKScene) {
        guard let gameScene = scene as? GameScene else { fatalError("failed") }
        self.scene = gameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.setupBackground()
        scene.setupForeground()
        scene.setupPlayerEntity()
        scene.setupScoreLabel()
        setupMainMenu()
        scene.playerEntity.movementAllowed = false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is TutorialState.Type
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        scene.updateForeground()
        scene.updateScore()
    }
    
    // Behavior
    func setupMainMenu() {
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.8)
        logo.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(logo)
        
        let playButton = SKSpriteNode(imageNamed: "Button")
        playButton.position = CGPoint(x: scene.size.width * 0.25, y: scene.size.height * 0.25)
        playButton.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(playButton)
        let playButtonText = SKLabelNode(text: "Play")
        playButtonText.position = CGPoint(x: 0, y: -5)
        playButton.addChild(playButtonText)
        
        let rateButton = SKSpriteNode(imageNamed: "Rate")
        rateButton.position = CGPoint(x: scene.size.width * 0.75, y: scene.size.height * 0.25)
        rateButton.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(rateButton)
        
        let learnButton = SKSpriteNode(imageNamed: "button_learn")
        learnButton.position = CGPoint(x: scene.size.width * 0.5, y: learnButton.size.height / 2 + scene.margin)
        learnButton.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(learnButton)
        
        // animation scale
        let scaleUp = SKAction.scale(by: 1.02, duration: 0.75)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(by: 0.98, duration: 0.75)
        scaleDown.timingMode = .easeInEaseOut
        learnButton.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }
}
