//
//  GameScene.swift
//  TestTask
//
//  Created by Serhii Anp on 23.08.2024.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    let ballCategory: UInt32 = 0x1 << 0
    let padCategory: UInt32 = 0x2 << 2
    let fireCategory: UInt32 = 0x3 << 3
    
    var gameViewController: MainVC?
    var ballNode: SKSpriteNode!
    var backgroundNode1: SKSpriteNode!
    var backgroundNode2: SKSpriteNode!
    let ballFallingSpeed: CGFloat = 200.0
    let backgroundSpeedOffset: CGFloat = 25.0
    var isGameOver = true
    var motionManager = CMMotionManager()
    var accelerometerX: CGFloat = 0
    var timerLabel: SKLabelNode!
    var timerBackgroundNode: SKSpriteNode!

    var winTime = 30
    var gameTimer: Timer?
    var gameOverLabel: SKLabelNode!
    var hasWon = false
    var startButton: SKSpriteNode!
    var isTimerActive = false
    var isOnFire = false
    let fireAnimationTextures = [
        SKTexture(image: .fireAnimation1),
        SKTexture(image: .fireAnimation2),
        SKTexture(image: .fireAnimation3),
        SKTexture(image: .fireAnimation4),
        SKTexture(image: .fireAnimation5),
        SKTexture(image: .fireAnimation6),
        SKTexture(image: .fireAnimation7)
    ]
    let ballFireTextures = [
        SKTexture(image: .animationBall1),
        SKTexture(image: .animationBall2),
        SKTexture(image: .animationBall3),
        SKTexture(image: .animationBall4),
        SKTexture(image: .animationBall5),
        SKTexture(image: .animationBall6),
        SKTexture(image: .animationBall7),
        SKTexture(image: .animationBall8)
    ]
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.speed = 0
        isPaused = true
        
        setupStartButton()
        setupAccelerometer()
        setupBackground()
        setupBall()
        setupFlatFigure()
    }
    
    //MARK: Create accelerometer
    func setupAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.2
        guard let operationQueue = OperationQueue.current else {return}
        motionManager.startAccelerometerUpdates(to: operationQueue) { [self] (accelerometerData, error) in
            guard let accelerometerData = accelerometerData else {
                print("Error: \(error!)")
                return
            }
            let acceleration = accelerometerData.acceleration
            self.accelerometerX = CGFloat(acceleration.x) * 0.75 + self.accelerometerX * 0.25
            
        }
    }
    // MARK: Create Timer, win condition
    func setupTimerLabel() {
        
        timerBackgroundNode = SKSpriteNode(imageNamed: "time")
        timerBackgroundNode.size.width = 200
        timerBackgroundNode.size.height = 80
        timerBackgroundNode.position = CGPoint(x: size.width / 2.0, y: size.height - 50)
        
        if UIScreen.main.bounds.size.height > 750 {
            timerBackgroundNode.position = CGPoint(x: size.width / 2.0, y: size.height - 80)
        }
        
        addChild(timerBackgroundNode)
        
        timerLabel =  SKLabelNode()
        timerLabel.text = "\(winTime)"
        timerLabel.fontColor = .white
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.fontSize = 30
        timerLabel.fontName = "BalooPaaji-Regular"
        timerLabel.position = CGPoint(x: size.width / 1.8  , y: size.height - 60)
        if UIScreen.main.bounds.size.height > 750 {
            timerLabel.position = CGPoint(x: size.width / 1.8  , y: size.height - 90)
        }
        addChild(timerLabel)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateGameTimer() {
        winTime -= 1
        timerLabel.text = "\(winTime)"
        if winTime <= 0 {
            stopGameTimer()
            gameOver()
        }
    }
    
    func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    //MARK: Create BackGround
    
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        backgroundNode1 = SKSpriteNode(texture: backgroundTexture)
        backgroundNode1.size = CGSize(width: frame.width, height: frame.height)
        backgroundNode1.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backgroundNode1)
        backgroundNode2 = SKSpriteNode(texture: backgroundTexture)
        backgroundNode2.size = CGSize(width: frame.width, height: frame.height)
        backgroundNode2.position = CGPoint(x: frame.midX, y: frame.midY - frame.height + 1)
        addChild(backgroundNode2)
        
        let moveUp = SKAction.moveBy(x: 0, y: frame.height, duration: TimeInterval((frame.height + backgroundSpeedOffset) / ballFallingSpeed))
        let resetPosition = SKAction.moveBy(x: 0, y: -frame.height, duration: 0)
        let moveForever = SKAction.repeatForever(SKAction.sequence([moveUp, resetPosition]))
        
        backgroundNode1.run(moveForever)
        backgroundNode2.run(moveForever)
    }
    //MARK: Create Ball
    func setupBall() {
        ballNode = SKSpriteNode(imageNamed: "AnimationBall")
        ballNode.size = CGSize(width: 50, height: 50)
        ballNode.position = CGPoint(x: frame.midX, y: frame.midY)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: ballNode.size.width / 2)
        ballNode.physicsBody?.categoryBitMask = ballCategory
        ballNode.physicsBody?.contactTestBitMask = padCategory
        ballNode.physicsBody?.collisionBitMask = padCategory
        ballNode.physicsBody?.restitution = 0.5
        ballNode.physicsBody?.friction = 0.2
        addChild(ballNode)
        let fallForever = SKAction.repeatForever(SKAction.moveBy(x: 0, y: -ballFallingSpeed, duration: 1))
        ballNode.run(fallForever)
    }
    
    //MARK: Random Spawn Pads
    func setupFlatFigure() {
        let spawn = SKAction.run { [self] in
            let flatFigure = SKSpriteNode(imageNamed: "flatFigure")
            flatFigure.name = "flatFigure"
            flatFigure.size = CGSize(width: size.width - ballNode.size.width - 20, height: 30)
            var xPosition: CGFloat = 0.0
            var anchorPoint: CGPoint!
            let randomInt = Int.random(in: 0...300)
            switch randomInt {
            case 0...50:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x:  -flatFigure.size.width / 2, y: 0))
            case 51...100:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x: flatFigure.size.width / 2, y: 0))
                
            case 101...150:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x:  -flatFigure.size.width / 2, y: 0))
                setupFireOnPad(flatFigure, CGPoint(x: -40, y: flatFigure.size.height))
            case 151...200:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x: flatFigure.size.width / 2, y: 0))
                setupFireOnPad(flatFigure, CGPoint(x: 40, y: flatFigure.size.height))
            case 201...250:
                xPosition = self.size.width
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x:  -flatFigure.size.width / 2, y: 0))
                createMovingPadAction(flatFigure, anchorPoint)
            case 251...300:
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
                flatFigure.physicsBody = SKPhysicsBody(rectangleOf: flatFigure.size, center: CGPoint(x: flatFigure.size.width / 2, y: 0))
                createMovingPadAction(flatFigure, anchorPoint)
            default: break
            }
            
            flatFigure.position = CGPoint(x: xPosition, y: -flatFigure.size.height)
            flatFigure.anchorPoint = anchorPoint
            
            flatFigure.physicsBody?.isDynamic = false
            flatFigure.physicsBody?.categoryBitMask = self.padCategory
            flatFigure.physicsBody?.contactTestBitMask = self.ballCategory
            flatFigure.physicsBody?.collisionBitMask = self.ballCategory
            self.addChild(flatFigure)
            
            let moveUp = SKAction.moveBy(x: 0, y: self.frame.height + flatFigure.size.height + self.backgroundSpeedOffset, duration: TimeInterval((self.frame.height + self.backgroundSpeedOffset) / self.ballFallingSpeed))
            let remove = SKAction.removeFromParent()
            flatFigure.run(SKAction.sequence([moveUp, remove]))
        }
        let delay = SKAction.wait(forDuration: 1)
        let spawnForever = SKAction.repeatForever(SKAction.sequence([spawn, delay]))
        run(spawnForever)
    }
    
    //MARK: Create Fire
    func setupFireOnPad(_ padNode: SKSpriteNode, _ position: CGPoint) {
        let texture = SKTexture(image: .fireAnimation1)
        let fireNode = SKSpriteNode(texture: texture)
        fireNode.anchorPoint = padNode.anchorPoint
        fireNode.position = position
        fireNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: fireNode.size.width / 2, height: fireNode.size.height / 2.5))
        fireNode.physicsBody?.isDynamic = false
        fireNode.physicsBody?.categoryBitMask = self.fireCategory
        fireNode.physicsBody?.contactTestBitMask = self.ballCategory
        fireNode.physicsBody?.collisionBitMask = self.ballCategory
        let fireAnimate = SKAction.animate(with: fireAnimationTextures, timePerFrame: 0.1)
        fireNode.run(SKAction.repeatForever(fireAnimate))
        padNode.addChild(fireNode)
    }
    
    func createMovingPadAction(_ pad: SKSpriteNode, _ ancorPoin: CGPoint) {
        
        let moveAction = SKAction.moveBy(x: ballNode.size.width + 20, y: 0, duration: 1)
        let moveActionBack = SKAction.moveBy(x: -ballNode.size.width - 20, y: 0, duration: 1)
        let waitAction = SKAction.wait(forDuration: 1.5)
        let sequenceForward = SKAction.sequence([moveAction, waitAction, moveActionBack, waitAction])
        let sequencrBackward = SKAction.sequence([moveActionBack, waitAction, moveAction, waitAction])
        if ancorPoin == CGPoint(x: 0.0, y: 0.5) {
            pad.run(SKAction.repeatForever(sequenceForward))
        } else {
            pad.run(SKAction.repeatForever(sequencrBackward))
        }
    }
    
    
    //MARK: Create Start Button
    func setupStartButton() {
        startButton = SKSpriteNode(imageNamed: "buttonStart")
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startButton.size.width = UIScreen.main.bounds.width - 100
        startButton.size.height = 120
        startButton.zPosition = 100
        addChild(startButton)
    }
    //MARK: Touches, Physics, Update
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }
    
   private func startGame() {
            isGameOver = false
            physicsWorld.speed = 1
            isPaused = false
            startButton.isHidden = true
            if !isTimerActive {
                setupTimerLabel()
                isTimerActive = true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (ballCategory | padCategory) {
            let ballNode = contact.bodyA.categoryBitMask == ballCategory ? contact.bodyA.node : contact.bodyB.node
            if let ballNode = ballNode {
                ballNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        if contactMask == (ballCategory | fireCategory) {
            let ballNode = contact.bodyA.categoryBitMask == ballCategory ? contact.bodyA.node : contact.bodyB.node
            if let ballNode = ballNode {
                if !isOnFire {
                    isOnFire = true
                    accelerometerX = 0
                    ballNode.zRotation = 0
                    ballNode.run(SKAction.animate(with: ballFireTextures, timePerFrame: 0.1)) { [self] in
                        ballNode.removeFromParent()
                        gameOver()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isGameOver{
            if ballNode.position.y > size.height {
                stopGameTimer()
                gameOver()
            }
        }
    }

    override func didSimulatePhysics() {
        guard let body = ballNode.physicsBody else{return}
        body.velocity = CGVector(dx: accelerometerX * 1000, dy:  0)
        if ballNode.position.y < 10 {
            ballNode.position = CGPoint(x: ballNode.position.x, y: 10)
        } else if ballNode.position.x < 10 {
            ballNode.position = CGPoint(x: 10, y: ballNode.position.y)
        } else if ballNode.position.x > size.width - 10 {
            ballNode.position = CGPoint(x: size.width - 10, y: ballNode.position.y)
        }
    }
    
    //MARK: Game Over, Restart
  private func gameOver() {
        isGameOver  =  true
        ballNode.removeFromParent()
        backgroundNode1.removeAllActions()
        backgroundNode2.removeAllActions()
        removeAllActions()
        enumerateChildNodes(withName: "pad") {
            name, stop in
            name.removeFromParent()
        }
        if winTime <= 0 {
            hasWon = true
        } else {
            hasWon = false
        }
        presentGameOverViewController()
    }
    
  func restartGame() {
        removeAllChildren()
        removeAllActions()
        if let scene = self.scene {
            let newGameScene = GameScene(size: scene.size)
            newGameScene.gameViewController = gameViewController
            if let view = self.view {
                view.presentScene(newGameScene)
            }
        }
    }
    
    private func presentGameOverViewController() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleString = "Game Over"
        let messageString = hasWon ? "Congratulations, you won!" : "You lost, better luck next time."
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "BalooPaaji-Regular", size: 20)!]
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "BalooPaaji-Regular", size: 16)!]
        
        let attributedTitle = NSAttributedString(string: titleString, attributes: titleAttributes)
        let attributedMessage = NSAttributedString(string: messageString, attributes: messageAttributes)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.loadGameOverViewController()
        }
        
        alertController.addAction(okAction)
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    private func loadGameOverViewController() {
        let gameOverViewController = GameOver()
        gameOverViewController.isWinner = hasWon
        gameOverViewController.gameScene = self
        
        if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(gameOverViewController, animated: true)
        }
    }
}


