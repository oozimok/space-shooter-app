import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var gameTimer: Timer!
    var aliens = ["alien", "alien2", "alien3"]
    var alienCategory: UInt32 = 0x1 << 1
    var bulletCategory: UInt32 = 0x1 << 0
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 0, y: 1492)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1;
        self.addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        self.addChild(player)

     
        scoreLabel = SKLabelNode(text: "Счет: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.color = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 50 )
        score = 0
        self.addChild(scoreLabel)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
 
        gameTimer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(addAlien),
            userInfo: nil,
            repeats: true
        )
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let accelerometer = accelerometerData.acceleration
                self.xAccelerate = CGFloat(accelerometer.x) * 0.75 + self.xAccelerate * 0.25
            }
        }

    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(
                x: UIScreen.main.bounds.width - player.size.width,
                y: player.position.y
            )
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    @objc func addAlien() {
        let randomIndex = Int(arc4random_uniform(UInt32(aliens.count)))
        let alien = SKSpriteNode(imageNamed: aliens[randomIndex])
        let randomPos = GKRandomDistribution(
            lowestValue: 20,
            highestValue: Int(UIScreen.main.bounds.size.width - 20)
        )
        let pos = CGFloat(randomPos.nextInt())
        
        alien.position = CGPoint(
            x: pos,
            y: UIScreen.main.bounds.size.height + alien.size.height
        )
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration: TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            alienBody = contact.bodyA
            bulletBody = contact.bodyB
        } else {
            alienBody = contact.bodyB
            bulletBody = contact.bodyA
        }
        
        if
            (alienBody.categoryBitMask & alienCategory) != 0 &&
            (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(
                alienNode: alienBody.node as! SKSpriteNode,
                bulletNode: bulletBody.node as! SKSpriteNode
            )
        }
    }
    
    func collisionElements(alienNode: SKSpriteNode, bulletNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "bang")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("bang.mp3", waitForCompletion: false))
        
        alienNode.removeFromParent()
        bulletNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 5
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("bang.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5

        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(
            x: player.position.x,
            y: UIScreen.main.bounds.size.height + bullet.size.height
        ), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    

}
