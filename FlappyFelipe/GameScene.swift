//
//  GameScene.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 1/6/22.
//

import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum Layer: CGFloat {
        case background
        case obstacle
        case foreground
        case player
        case ui
    }
    
    enum PhysicsCategory {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1
        static let Obstacle: UInt32 = 0b10
        static let Ground: UInt32 = 0b100
    }
    
    let worldNode = SKNode()
    let bottomObstacleMinFraction: CGFloat = 0.1
    let bottomObstacleMaxFraction: CGFloat = 0.6
    let gapMultiplayer = CGFloat(4.5)
    let firstSpawnDelay = TimeInterval(1.75)
    let everySpawnDelay = TimeInterval(1.5)
    let popSoundAction = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
    var initialState: AnyClass
    lazy var stateMachine = GKStateMachine(states: [
        PlayingState(scene: self),
        FallingState(scene: self),
        GameOverState(scene: self),
        MainMenuState(scene: self),
        TutorialState(scene: self)
    ])
    var playableStart: CGFloat = 0.0
    var playableHeight: CGFloat = 0.0
    var numberOfForegrounds = 2
    var foregroundVelocity: CGFloat = 150
    var deltaTime: CGFloat = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    var playerEntity = PlayerEntity(imageName: "Bird0")
    
    // MARK: UI Properties
    var scoreLabel: SKLabelNode!
    var score = 0
    var scoreLabelText: String { "\(score / 2)" }
    var scoreLabelFont = "AmericanTypewriter-Bold"
    var margin = CGFloat(20.0)
    
    init(size: CGSize, stateClass: AnyClass) {
        initialState = stateClass
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        addChild(worldNode)
        stateMachine.enter(initialState)
    }
    
    // Initialization
    func setupBackground() {
        let backgroundSpriteNode = SKSpriteNode(imageNamed: "background")
        backgroundSpriteNode.anchorPoint = .init(x: 0.5, y: 1)
        backgroundSpriteNode.position = .init(x: size.width / 2, y: size.height)
        backgroundSpriteNode.zPosition = Layer.background.rawValue
        playableStart = size.height - backgroundSpriteNode.size.height
        playableHeight = backgroundSpriteNode.size.height
        worldNode.addChild(backgroundSpriteNode)
        // Add Physics
        let lowerLeft = CGPoint(x: 0, y: playableStart)
        let lowerRight = CGPoint(x: size.width, y: playableStart)
        physicsBody = SKPhysicsBody(edgeFrom: lowerLeft, to: lowerRight)
        physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Ground
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.Player
    }

    func setupForeground() {
        for index in 0..<numberOfForegrounds {
            let foregroundSpriteNode = SKSpriteNode(imageNamed: "Ground")
            foregroundSpriteNode.anchorPoint = .init(x: 0.0 , y: 1.0)
            foregroundSpriteNode.position =  .init(x: CGFloat(index) * size.width, y: playableStart)
            foregroundSpriteNode.zPosition = Layer.foreground.rawValue
            foregroundSpriteNode.name = "foreground"
            worldNode.addChild(foregroundSpriteNode)
        }
    }
    
    func setupPlayerEntity() {
        let playerNode = playerEntity.spriteComponent.node
        playerNode.position = CGPoint(
            x: size.width * 0.2,
            y: playableHeight * 0.4 + playableStart
        )
        playerNode.zPosition = Layer.player.rawValue
        worldNode.addChild(playerNode)
        playerEntity.movementComponent.playableStart = playableStart
    }
    
    func startSpawning() {
        let firstDelay = SKAction.wait(forDuration: firstSpawnDelay)
        let spawn = SKAction.run(spawnObstacle)
        let everyDelay = SKAction.wait(forDuration: everySpawnDelay)
        let spawnSequence = SKAction.sequence([spawn, everyDelay])
        let foreverSpawn = SKAction.repeatForever(spawnSequence)
        let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])
        run(overallSequence, withKey: "spawn")
    }
    
    func stopSpawning() {
        removeAction(forKey: "spawn")
        worldNode.enumerateChildNodes(withName: "obstacle", using: { node, stop in
            node.removeAllActions()
        })
    }
    
    func createObstacle() -> SKSpriteNode {
        let obstacleNode = ObstacleEntity(imageName: "Cactus").spriteComponent.node
        obstacleNode.zPosition = Layer.obstacle.rawValue
        obstacleNode.name = "obstacle"
        obstacleNode.userData = NSMutableDictionary()
        return obstacleNode
    }
    
    func spawnObstacle() {
        // Bottom Obstacle
        let bottomObstacle = createObstacle()
        let startX = size.width + bottomObstacle.size.width / 2
        let bottomObstacleMin = (playableStart - bottomObstacle.size.height / 2) + playableHeight * bottomObstacleMinFraction
        let bottomObstacleMax = (playableStart - bottomObstacle.size.height / 2) + playableHeight * bottomObstacleMaxFraction
        
            // let randomValue = CGFloat.random(bottomObstacleMin, max: bottomObstacleMax)
        
            // Using GameplayKit's randomization
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: Int(round(bottomObstacleMin)), highestValue: Int(round(bottomObstacleMax)))
        let randomValue = randomDistribution.nextInt()
        bottomObstacle.position = CGPoint(x: startX, y: CGFloat(randomValue))
        worldNode.addChild(bottomObstacle)
        // Top Obstacle
        let topObstacle = createObstacle()
        topObstacle.zRotation = CGFloat(GLKMathDegreesToRadians(180))
        topObstacle.position = CGPoint(
            x: startX,
            y: bottomObstacle.position.y + bottomObstacle.size.height / 2 + topObstacle.size.height / 2 + playerEntity.spriteComponent.node.size.height * gapMultiplayer
        )
        worldNode.addChild(topObstacle)
        // Move Obstacles
        let moveX = size.width + topObstacle.size.width
        let moveDuration = moveX / foregroundVelocity
        let sequence = SKAction.sequence([
            SKAction.moveBy(x: -moveX, y: 0.0, duration: TimeInterval(moveDuration)),
            SKAction.removeFromParent()
        ])
        topObstacle.run(sequence)
        bottomObstacle.run(sequence)
    }
    
    func restartGame(_ stateClass: AnyClass) {
        run(popSoundAction)
        let newScene = GameScene(size: size, stateClass: stateClass)
        let transition = SKTransition.fade(with: SKColor.black, duration: 0.02)
        view?.presentScene(newScene, transition: transition)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: scoreLabelFont)
        scoreLabel.text = scoreLabelText
        scoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - margin)
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = Layer.ui.rawValue
        worldNode.addChild(scoreLabel)
    }
    
    func updateForeground() {
        worldNode.enumerateChildNodes(withName: "foreground", using: { node, stop in
            if let foregroundNode = node as? SKSpriteNode {
                let moveAmount =  (-self.foregroundVelocity) * CGFloat(self.deltaTime)
                foregroundNode.position = CGPoint(
                    x: foregroundNode.position.x + moveAmount,
                    y: foregroundNode.position.y
                )
                if foregroundNode.position.x < -self.size.width {
                    foregroundNode.position = CGPoint(
                        x: foregroundNode.position.x + foregroundNode.size.width * CGFloat(self.numberOfForegrounds),
                        y: foregroundNode.position.y
                    )
                }
            }
        })
    }
    
    func updateScore() {
        worldNode.enumerateChildNodes(withName: "obstacle", using: { node, stop in
            if let obstacle = node as? SKSpriteNode {
                if let passed = obstacle.userData?["Passed"] as? NSNumber {
                    if passed.boolValue {
                        return
                    }
                }
                if self.playerEntity.spriteComponent.node.position.x > obstacle.position.x + obstacle.size.width / 2 {
                    obstacle.userData?["Passed"] = NSNumber(value: true as Bool)
                    self.score += 1
                    self.scoreLabel.text = self.scoreLabelText
                }
            }
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        stateMachine.update(deltaTime: currentTime)
        playerEntity.update(deltaTime: deltaTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch stateMachine.currentState {
        case is GameOverState: restartGame(TutorialState.self)
        case is MainMenuState: restartGame(TutorialState.self)
        case is TutorialState: stateMachine.enter(PlayingState.self)
        case is PlayingState: playerEntity.movementComponent.applyImpulse(lastUpdateTimeInterval)
        default: break
        }
    }
 
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == PhysicsCategory.Obstacle {
            print("hit Obstacle")
            stateMachine.enter(FallingState.self)
        }
        if other.categoryBitMask == PhysicsCategory.Ground {
            print("hit Ground")
            stateMachine.enter(GameOverState.self)
        }
        
    }
}
