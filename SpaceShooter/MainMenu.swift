import SpriteKit

class MainMenu: SKScene {

    var starfieldAnim: SKEmitterNode!
    var newGameBtnNode: SKSpriteNode!
    var levelBtnNode: SKSpriteNode!
    var levelLabelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        starfieldAnim = (self.childNode(withName: "starfieldAnim") as! SKEmitterNode)
        starfieldAnim.advanceSimulationTime(10)
        
        newGameBtnNode = (self.childNode(withName: "newGameBtn") as! SKSpriteNode)
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        
        levelBtnNode = (self.childNode(withName: "levelBtn") as! SKSpriteNode)
        levelBtnNode.texture = SKTexture(imageNamed: "levelBtn")
        
        levelLabelNode = (self.childNode(withName: "levelLabel") as! SKLabelNode)

        let userLevel = UserDefaults.standard
        if userLevel.bool(forKey: "hard") {
            levelLabelNode.text = "Сложно"
        } else {
            levelLabelNode.text = "Легко"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodeArray = self.nodes(at: location)
            
            if nodeArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds .size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodeArray.first?.name == "levelBtn" {
                changeLevel()
            }
        } 
    }
    
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if levelLabelNode.text == "Легко" {
            levelLabelNode.text = "Сложно"
            userLevel.set(true, forKey: "hard")
        } else {
            levelLabelNode.text = "Легко"
            userLevel.set(false, forKey: "hard")
        }
        
        userLevel.synchronize()
    }
}
