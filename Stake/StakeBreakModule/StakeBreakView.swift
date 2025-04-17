import SwiftUI
import SpriteKit

class GameData: ObservableObject {
    @Published var isEnd = false
    @Published var isGameStarted = false
}

struct ObstacleData {
    let type: ObstacleType
    var health: Int
}

enum ObstacleType: String {
    case red, yellow, orange
}

private struct PhysicsCategory {
    static let ball: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let desk: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
}

class GameSpriteKit: SKScene, SKPhysicsContactDelegate {
    var game: GameData?
    private var ball: SKSpriteNode!
    private var desk: SKSpriteNode!
    var obstacleData: [SKNode: ObstacleData] = [:]
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = UIScreen.main.bounds.size
        setupView()
        setupObstacle()
        createBall()
        setupPhysicsBoundaries()
    }
    
    func setupPhysicsBoundaries() {
        let screen = UIScreen.main.bounds
        
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0),
                                             to: CGPoint(x: 0, y: screen.height))
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(leftWall)
        
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: screen.width, y: 0),
                                              to: CGPoint(x: screen.width, y: screen.height))
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(rightWall)
        
        let top = SKNode()
        top.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: screen.height),
                                        to: CGPoint(x: screen.width, y: screen.height))
        top.physicsBody?.categoryBitMask = PhysicsCategory.wall
        top.physicsBody?.collisionBitMask = PhysicsCategory.ball
        addChild(top)
        
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0),
                                           to: CGPoint(x: screen.width, y: 0))
        bottom.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottom.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        addChild(bottom)
    }
    
    func addPhysics(to node: SKSpriteNode) {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func setupObstacle() {
        let parentNode = SKNode()
        parentNode.position = CGPoint(x: 0, y: 0)
        addChild(parentNode)
        
        func createObstacle(imageNamed imageName: String, size: CGSize, position: CGPoint, obstacleType: ObstacleType, health: Int) {
            let obs = SKSpriteNode(imageNamed: imageName)
            obs.size = size
            obs.position = position
            addPhysics(to: obs)
            parentNode.addChild(obs)
            obs.name = obstacleType.rawValue
            obstacleData[obs] = ObstacleData(type: obstacleType, health: health)
        }
        
        for i in 0..<2 {
            let position = CGPoint(x: size.width / 3.05 + CGFloat(i * 140) - parentNode.position.x, y: size.height / 1.2 - parentNode.position.y)
            createObstacle(imageNamed: "yellowObstacle", size: CGSize(width: 123, height: 33), position: position, obstacleType: .yellow, health: 4)
        }
        
        for i in 0..<2 {
            let position = CGPoint(x: size.width / 3.4 + CGFloat(i * 165) - parentNode.position.x, y: size.height / 1.257 - parentNode.position.y)
            createObstacle(imageNamed: "redObstacle", size: CGSize(width: 165, height: 33), position: position, obstacleType: .red, health: 5)
        }
        
        for i in 0..<3 {
            if i != 1 {
                let position = CGPoint(x: size.width / 4.5 + CGFloat(i * 113) - parentNode.position.x, y: size.height / 1.32 - parentNode.position.y)
                createObstacle(imageNamed: "redObstacle", size: CGSize(width: 165, height: 33), position: position, obstacleType: .red, health: 5)
            } else {
                let position = CGPoint(x: size.width / 2 - parentNode.position.x, y: size.height / 1.32 - parentNode.position.y)
                createObstacle(imageNamed: "orangeObstacle", size: CGSize(width: 63, height: 33), position: position, obstacleType: .orange, health: 3)
            }
        }
        
        for i in 0..<2 {
            let position = CGPoint(
                x: size.width / 3.4 + CGFloat(i * 165) - parentNode.position.x,
                y: size.height / 1.389 - parentNode.position.y
            )
            createObstacle(imageNamed: "redObstacle", size: CGSize(width: 165, height: 33), position: position, obstacleType: .red, health: 5)
        }
        
        for i in 0..<2 {
            let position = CGPoint(
                x: size.width / 3.4 + CGFloat(i * 165) - parentNode.position.x,
                y: size.height / 1.466 - parentNode.position.y
            )
            createObstacle(imageNamed: "redObstacle", size: CGSize(width: 165, height: 33), position: position, obstacleType: .red, health: 5)
        }
        
        for i in 0..<2 {
            let position = CGPoint(
                x: size.width / 3.15 + CGFloat(i * 145) - parentNode.position.x,
                y: size.height / 1.552 - parentNode.position.y
            )
            createObstacle(imageNamed: "yellowObstacle", size: CGSize(width: 145, height: 33), position: position, obstacleType: .yellow, health: 4)
        }
        
        let yellowPosition = CGPoint(
            x: size.width / 2 - parentNode.position.x,
            y: size.height / 1.649 - parentNode.position.y
        )
        createObstacle(imageNamed: "yellowObstacle", size: CGSize(width: 145, height: 33), position: yellowPosition, obstacleType: .yellow, health: 4)
        
        let orangePosition = CGPoint(
            x: size.width / 2 - parentNode.position.x,
            y: size.height / 1.76 - parentNode.position.y
        )
        createObstacle(imageNamed: "orangeObstacle", size: CGSize(width: 63, height: 33), position: orangePosition, obstacleType: .orange, health: 3)
    }
    
    func setupView() {
        let bg = SKSpriteNode(imageNamed: "gameBack")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(bg)
    }
    
    func createBall() {
        ball = SKSpriteNode(imageNamed: StakeImageName.ball.rawValue)
        ball.size = CGSize(width: 50, height: 50)
        ball.position = CGPoint(x: size.width / 2, y: size.height / 3)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.wall
        ball.physicsBody?.collisionBitMask = PhysicsCategory.desk | PhysicsCategory.wall | PhysicsCategory.obstacle
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        ball.physicsBody?.friction = 0.0
        addChild(ball)
        
        desk = SKSpriteNode(imageNamed: StakeImageName.desk.rawValue)
        desk.size = CGSize(width: 200, height: 20)
        desk.position = CGPoint(x: size.width / 2, y: size.height / 3.5)
        desk.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 10))
        desk.physicsBody?.isDynamic = false
        desk.physicsBody?.categoryBitMask = PhysicsCategory.desk
        desk.physicsBody?.collisionBitMask = PhysicsCategory.ball
        
        addChild(desk)
        
        let label = SKLabelNode(fontNamed: "Agdasima-Regular")
        label.text = "TAP TO PLAY"
        label.name = "tapToPlayLabel"
        label.fontSize = 64
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 7)
        addChild(label)
    }
    
    private func startGame() {
        self.childNode(withName: "tapToPlayLabel")?.removeFromParent()
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
        if let label = self.childNode(withName: "tapToPlayLabel") {
            label.run(SKAction.fadeOut(withDuration: 0.3)) {
                label.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !game!.isGameStarted else { return }
        
        game?.isGameStarted = true
        startGame()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let newPosition = CGPoint(
            x: touchLocation.x,
            y: desk.position.y
        )
        let minX = desk.size.width / 2 + 20
        let maxX = size.width - desk.size.width / 2 - 20
        desk.position.x = min(max(newPosition.x, minX), maxX)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if areNoObstaclesOnScreen() {
            game?.isEnd = true
        }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.ball | PhysicsCategory.obstacle {
            var obstacleNode: SKNode?
            
            if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle {
                obstacleNode = contact.bodyA.node
            } else {
                obstacleNode = contact.bodyB.node
            }
            
            guard let obstacle = obstacleNode,  let _ = obstacleData[obstacle] else { return }
            
            obstacleData[obstacle]?.health -= 1
            
            if obstacleData[obstacle]?.health ?? 0 <= 0 {
                obstacle.removeFromParent()
                obstacleData.removeValue(forKey: obstacle)
            }
        }
        
        if collision == PhysicsCategory.ball | PhysicsCategory.wall {
            if contact.contactPoint.y < 50 {
                game?.isEnd = true
                scene?.isPaused = true
                UserDefaultsManager().minusLifes(life: 1)
            }
        }
    }
    
    func areNoObstaclesOnScreen() -> Bool {
        if obstacleData.isEmpty {
            UserDefaultsManager().addCoin(coins: 1400)
        }
        return obstacleData.isEmpty
    }
}

struct StakeBreakView: View {
    @StateObject var stakeBreakModel =  StakeBreakViewModel()
    @StateObject var gameModel = GameData()
    var body: some View {
        ZStack {
            SpriteView(scene: stakeBreakModel.createGameScene(gameData: gameModel))
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .fullScreenCover(isPresented: $gameModel.isEnd) {
                    StakeTabBarView()
                }
        }
    }
}

#Preview {
    StakeBreakView()
}

