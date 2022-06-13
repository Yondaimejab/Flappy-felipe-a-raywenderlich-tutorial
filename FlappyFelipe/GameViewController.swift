//
//  GameViewController.swift
//  FlappyFelipe
//
//  Created by joel Alcantara on 1/6/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureScene()
    }
    
    private func configureScene() {
        if let skView = view as? SKView, skView.scene == nil {
            let aspectRatio = skView.bounds.size.height / skView.bounds.size.width
            let scene = GameScene(size: CGSize(width: 320, height: 320 * aspectRatio), stateClass: MainMenuState.self)
            scene.view?.showsFPS = false
            scene.view?.showsNodeCount = false
            scene.view?.showsPhysics = false
            scene.view?.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
