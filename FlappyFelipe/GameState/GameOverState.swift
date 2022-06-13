//
//  PausedState.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 5/6/22.
//

import GameplayKit
import SpriteKit

class GameOverState: GKState {
    let scene: GameScene!
    let hitGroundAction = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let animationDelay = 0.3
    
    init(scene: SKScene) {
        guard let gameScene = scene as? GameScene else { fatalError("could not load") }
        self.scene = gameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.run(hitGroundAction)
        scene.stopSpawning()
        showScoreCard()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is PlayingState.Type
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
    func setBestScore(_ bestScore: Int) {
        UserDefaults.standard.set(bestScore, forKey: "bestScore")
        UserDefaults.standard.synchronize()
    }
    
    var bestScore: Int {
       return UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    func showScoreCard() {
        if scene.score > bestScore {
            setBestScore(scene.score)
        }
        
        // ScoreCard
        let scorecardNode = SKSpriteNode(imageNamed: "Scorecard")
        scorecardNode.position = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.5)
        scorecardNode.name = "Tutorial"
        scorecardNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(scorecardNode)
        
        // Last Score label
        let lastScoreLabel = SKLabelNode()
        lastScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1)
        lastScoreLabel.position = CGPoint(x: -scorecardNode.size.width * 0.25, y: -scorecardNode.size.height * 0.2)
        lastScoreLabel.name = "Tutorial"
        lastScoreLabel.text = scene.scoreLabelText
        lastScoreLabel.zPosition = GameScene.Layer.ui.rawValue
        scorecardNode.addChild(lastScoreLabel)
        
        // best Score label
        let bestScoreLabel = SKLabelNode()
        bestScoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1)
        bestScoreLabel.position = CGPoint(x: scorecardNode.size.width * 0.25, y: -scorecardNode.size.height * 0.2)
        bestScoreLabel.name = "Tutorial"
        bestScoreLabel.text = bestScore == 0 ? scene.scoreLabelText : "\(bestScore / 2)"
        bestScoreLabel.zPosition = GameScene.Layer.ui.rawValue
        scorecardNode.addChild(bestScoreLabel)
        
        // gameOver
        let gameOverNode = SKSpriteNode(imageNamed: "GameOver")
        gameOverNode.position = CGPoint(
            x: scene.size.width * 0.5,
            y: scene.size.height * 0.5 + scorecardNode.size.height / 2 + scene.margin + gameOverNode.size.height / 2
        )
        gameOverNode.name = "Tutorial"
        gameOverNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(gameOverNode)
        
        // okButton
        let okButtonNode = SKSpriteNode(imageNamed: "Button")
        okButtonNode.position = CGPoint(
            x: scene.size.width * 0.25,
            y: scene.size.height / 2 - scorecardNode.size.height / 2 - scene.margin - okButtonNode.size.height / 2
        )
        okButtonNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(okButtonNode)
        let okButtonText = SKSpriteNode(imageNamed: "OK")
        okButtonText.position = .zero
        okButtonNode.addChild(okButtonText)
        
        // shareButton
        let shareButtonNode = SKSpriteNode(imageNamed: "Button")
        shareButtonNode.position = CGPoint(
            x: scene.size.width * 0.75,
            y: scene.size.height / 2 - scorecardNode.size.height / 2 - scene.margin - shareButtonNode.size.height / 2
        )
        shareButtonNode.zPosition = GameScene.Layer.ui.rawValue
        scene.worldNode.addChild(shareButtonNode)
        let shareButtonText = SKSpriteNode(imageNamed: "Share")
        shareButtonText.position = .zero
        shareButtonNode.addChild(shareButtonText)
        
        // Animations
        gameOverNode.setScale(.zero)
        gameOverNode.alpha = .zero
        let group = SKAction.group([
            SKAction.fadeIn(withDuration: animationDelay),
            SKAction.scale(to: 1.0, duration: animationDelay)
        ])
        group.timingMode = .easeInEaseOut
        gameOverNode.run(SKAction.sequence([SKAction.wait(forDuration: animationDelay), group]))
        
        // let scorecard
        scorecardNode.position = CGPoint(x: scene.size.width / 2, y: -scorecardNode.size.height / 2)
        let moveTo = SKAction.move(to: CGPoint(x: scene.size.width / 2, y: scene.size.height * 0.5), duration: animationDelay)
        scorecardNode.run(SKAction.sequence([SKAction.wait(forDuration: animationDelay), moveTo]))
        
        // OK button & Share button
        okButtonNode.alpha = 0
        shareButtonNode.alpha = 0
        let fadeIn = SKAction.sequence([
            SKAction.wait(forDuration: animationDelay * 3),
            SKAction.fadeIn(withDuration: animationDelay)
        ])
        okButtonNode.run(fadeIn)
        shareButtonNode.run(fadeIn)
        
        let pop = SKAction.sequence([
            SKAction.wait(forDuration: animationDelay),
            scene.popSoundAction,
            SKAction.wait(forDuration: animationDelay),
            scene.popSoundAction,
            SKAction.wait(forDuration: animationDelay),
            scene.popSoundAction
        ])
        scene.run(pop)
    }
}
