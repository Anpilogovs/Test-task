//
//  MainVC.swift
//  TestTask
//
//  Created by Serhii Anp on 24.08.2024.
//

import UIKit
import SpriteKit
import GameplayKit

class MainVC: UIViewController {
    
    private var skView = SKView()
    var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameScene()
        view.backgroundColor = .black
        navigationController?.isNavigationBarHidden = true
    }
    private func setGameScene() {
        skView.frame = view.frame
        view.addSubview(skView)
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        self.gameScene = scene
        scene.backgroundColor = .gray
        skView.backgroundColor = .gray
        view.backgroundColor = .gray
        gameScene?.gameViewController = self
        gameScene?.backgroundColor = .white
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = false
        skView.isMultipleTouchEnabled = true
        skView.showsPhysics = true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
