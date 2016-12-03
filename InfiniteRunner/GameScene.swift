//
//  GameScene.swift
//  InfiniteRunner
//
//  Created by Marcus Ng on 12/3/16.
//  Copyright © 2016 Marcus Ng. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

struct CollisionNames {
    static let Hero: UInt32 = 0x1 << 1
    static let Block: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let manager = CMMotionManager()
    
    var spd: CGFloat = 1.0
    
    var gameStarted: Bool = false
    var isAlive: Bool = false
    
    var score: Int = 0
    var highscore: Int = 0
    
    var scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var highscoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var titleLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    var tapToStart: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    
    var hero: SKSpriteNode = SKSpriteNode()
    var block: SKSpriteNode = SKSpriteNode()
    
    var blockTimer = Timer()
    var scoreTimer = Timer()
    
    var fadingAnimation = SKAction()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        let bgColor: UIColor = UIColor(red: 179, green: 218, blue: 255, alpha: 1)
        backgroundColor = bgColor
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main) {(data,error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 10, dy: CGFloat((data?.acceleration.y)!) * 10)
        }
        
        let highscoreDefault = UserDefaults.standard
        if highscoreDefault.value(forKey: "Highscore") != nil {
            
            highscore = highscoreDefault.value(forKey: "Highscore") as! Int
            highscoreLabel.text = "Highscore : \(highscore)"
            
        }
        
        titleLabel.text = "THE GAME"
        titleLabel.fontSize = 80
        titleLabel.fontColor = UIColor.black
        titleLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        titleLabel.zPosition = 2.0
        self.addChild(titleLabel)
        
        tapToStart.text = "Tap to Start"
        tapToStart.fontSize = 65
        tapToStart.fontColor = UIColor.black
        tapToStart.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 3)
        tapToStart.zPosition = 2.0
        fadingAnimation = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), SKAction.fadeOut(withDuration: 1.0)])
        tapToStart.run(SKAction.repeatForever(fadingAnimation))
        self.addChild(tapToStart)
        
        highscoreLabel.text = "Highscore : \(highscore)"
        highscoreLabel.fontSize = 47
        highscoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2)
        highscoreLabel.fontColor = UIColor.black
        self.addChild(highscoreLabel)
        
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = UIColor.black
        scoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.2)
        scoreLabel.zPosition = 2.0
        scoreLabel.isHidden = true
        self.addChild(scoreLabel)
        
        let heroTexture = SKTexture(imageNamed: "hero")
        
        hero = SKSpriteNode(texture: heroTexture)
        hero.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 )
        hero.name = "Hero"
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.affectedByGravity = true
        
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        hero.physicsBody?.categoryBitMask = CollisionNames.Hero
        hero.physicsBody?.contactTestBitMask = CollisionNames.Block
        hero.physicsBody?.collisionBitMask = CollisionNames.Block
        
        let border  = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
        
    }

    func spawnBlocks() {
        
        if gameStarted == true {
            let blockTexture = SKTexture(imageNamed: "Block.png")
            block = SKSpriteNode(texture: blockTexture)
            let minValue = self.size.width / 8
            let maxValue = self.size.height - 20
            let spawnPoint = UInt32(maxValue - minValue)
            block.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
            block.name = "Block"
            
            block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
            block.physicsBody?.allowsRotation = false
            block.physicsBody?.isDynamic = true
            block.physicsBody?.categoryBitMask = CollisionNames.Block
            block.physicsBody?.contactTestBitMask = CollisionNames.Hero
            block.physicsBody?.collisionBitMask = CollisionNames.Hero
            block.physicsBody?.affectedByGravity = false
            
            let action = SKAction.moveTo(y: -1000, duration: 3 )
            let actionDone = SKAction.removeFromParent()
            block.run(SKAction.sequence([action, actionDone]))
            
            self.addChild(block)
        }
        
    }
    
    func increaseScore() {
        if gameStarted == true {
            score += 1
            scoreLabel.text = "\(score)"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {

            gameStarted = true
            
            self.addChild(hero)
            
            tapToStart.removeFromParent()
            highscoreLabel.removeFromParent()
            titleLabel.removeFromParent()
            
            score = 0
            scoreLabel.isHidden = false
            scoreLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)]))

            scoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.2)
            scoreLabel.fontSize = 65
            scoreLabel.text = "\(score)"
            
            blockTimer = Timer.scheduledTimer(timeInterval: TimeInterval(spd), target: self, selector: #selector(GameScene.spawnBlocks), userInfo: nil, repeats: true)
            
            scoreTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
            
        }
        
        for touch in touches {
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted == true {

            let bodyA = contact.bodyA
            let bodyB = contact.bodyB
            if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Hero && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Block || bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Block && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Hero {
                
                gameStarted = false
                spd = 1.0
                hero.removeFromParent()
                block.removeFromParent()
                blockTimer.invalidate()
                scoreTimer.invalidate()
                
                scoreLabel.text = "Time Survived : \(score)"
                scoreLabel.fontSize = 45
                scoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.7)
                scoreLabel.run(SKAction.fadeIn(withDuration: 0.4))
                scoreLabel.fontColor = UIColor.black
                
                tapToStart.text = "Play Again"
                tapToStart.run(SKAction.fadeIn(withDuration: 1.0))
                tapToStart.run(SKAction.repeatForever(fadingAnimation))
                self.addChild(tapToStart)
                self.addChild(titleLabel)
                self.addChild(highscoreLabel)
            
                if score > highscore {
                    let highscoreDefault = UserDefaults.standard
                    highscore = score
                    highscoreDefault.set(highscore, forKey: "Highscore")
                    highscoreLabel.text = "Highscore : \(highscore)"
                }
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if score % 10 == 0 && spd > 0.5 {
            spd -= 0.2
        }
    }
    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

