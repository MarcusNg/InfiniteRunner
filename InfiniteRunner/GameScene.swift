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
    
    var gameStarted: Bool = false
    var isAlive: Bool = false
    
    var score: Int = 0
    var highscore: Int = 0
    var scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    
    var hero: SKSpriteNode = SKSpriteNode()
    var block: SKSpriteNode = SKSpriteNode()
    
    var blockTimer = Timer()

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height)
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main) {(data,error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 10, dy: CGFloat((data?.acceleration.y)!) * 10)
        }
        let heroTexture = SKTexture(imageNamed: "hero")
        
        hero = SKSpriteNode(texture: heroTexture)
        hero.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 )
        hero.name = "Hero"
        backgroundColor = UIColor.white
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.affectedByGravity = true
        
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        hero.physicsBody?.categoryBitMask = CollisionNames.Hero
        hero.physicsBody?.contactTestBitMask = CollisionNames.Block
        hero.physicsBody?.collisionBitMask = CollisionNames.Block
        self.addChild(scoreLabel)
        self.addChild(hero)
        
        let border  = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
        
    }
    
    func spawnBlocks() {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let blockTexture = SKTexture(imageNamed: "Block.png")
        block = SKSpriteNode(texture: blockTexture)
        let minValue = self.size.width / 8
        let maxValue = self.size.height - 20
        let spawnPoint = UInt32(maxValue - minValue)
        block.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
        //block.position = CGPoint(x: self.size.width / 20, y: self.size.height / 2)
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
        score += 1
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        gameStarted = true
        blockTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(GameScene.spawnBlocks), userInfo: nil, repeats: true)
        
        for touch in touches {
            let location = touch.location(in: self)
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted == true {
            print("test")
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB
            if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Hero && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Block {
                print("CONTACT")
            } else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Block && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Hero {
                print("CONTACT")
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
    }
}
