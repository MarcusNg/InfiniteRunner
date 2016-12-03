//
//  GameScene.swift
//  InfiniteRunner
//
//  Created by Marcus Ng on 12/3/16.
//  Copyright © 2016 Marcus Ng. All rights reserved.
//

import SpriteKit
import GameplayKit

struct CollisionNames {
    static let Hero: UInt32 = 0x1 << 1
    static let Block: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameStarted: Bool = false
    var isAlive: Bool = false
    
    var score: Int = 0
    var highscore: Int = 0
    
    var hero: SKSpriteNode = SKSpriteNode()
    var block: SKSpriteNode = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        let heroTexture = SKTexture(imageNamed: "hero")
        
        hero = SKSpriteNode(texture: heroTexture)
        hero.position = CGPoint(x: 200, y: 300)
        hero.name = "Hero"
        
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.isDynamic = false
        hero.physicsBody?.categoryBitMask = CollisionNames.Hero
        hero.physicsBody?.contactTestBitMask = CollisionNames.Block
        hero.physicsBody?.collisionBitMask = CollisionNames.Block
        self.addChild(hero)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

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
