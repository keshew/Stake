import SwiftUI
import SpriteKit

class FootballGameData: ObservableObject {
    @Published var isEnd = false
    @Published var goal = 0
}

class FootballGameSpriteKit: SKScene {
    var game: FootballGameData?
    private var ball: SKSpriteNode!
    private var keeper: SKSpriteNode!
    private var tapToPlayLabel: SKLabelNode!
    private var circles: [SKShapeNode] = []
    private let attempts = 3
    private var currentAttempt = 0
    private var isBallFlying = false
    private var swipeStartPoint: CGPoint?
    private var isFirstTouch = true
    private var keeperSpeed: TimeInterval = 2.0
    private var goalRect: CGRect!
    
    override func didMove(to view: SKView) {
        size = UIScreen.main.bounds.size
        setupView()
        setupKeeper()
        setupGoalState()
        setupBall()
    }
    
    private func setupKeeper() {
        keeper = SKSpriteNode(imageNamed: "keeper")
        keeper.size = CGSize(width: 130, height: 150)
        keeper.position = CGPoint(x: size.width / 2, y: size.height / 2.05)
        addChild(keeper)
        startKeeperMovement()
    }
    
    private func setupBall() {
        ball = SKSpriteNode(imageNamed: "ballPenalty")
        ball.size = CGSize(width: 110, height: 120)
        ball.position = CGPoint(x: size.width / 2, y: size.height / 3.7)
        addChild(ball)
        
        let rect = CGRect(x: 0, y: 375, width: size.width, height: 210)
        let rectangleNode = SKShapeNode(rect: rect)
        rectangleNode.fillColor = .clear
        rectangleNode.strokeColor = .clear
        rectangleNode.lineWidth = 2
        addChild(rectangleNode)
        goalRect = rect

    }
    
    private func setupGoalState() {
        let goalParent = SKNode()
        goalParent.position = CGPoint(x: size.width / 2, y: size.height / 1.22)
        addChild(goalParent)
        
        let goalLine = SKSpriteNode(imageNamed: "goalLine")
        goalLine.size = CGSize(width: 190, height: 70)
        goalLine.position = .zero
        goalParent.addChild(goalLine)
        
        let circleParams = (
            radius: CGFloat(15),
            spacing: CGFloat(45),
            yPosition: CGFloat(-3)
        )
        
        for i in 0..<3 {
            let circle = SKShapeNode(circleOfRadius: circleParams.radius)
            circle.fillColor = UIColor(red: 1.0, green: 138/255, blue: 241/255, alpha: 1)
            circle.strokeColor = .clear
            circle.zPosition = 1
            circle.position = CGPoint(
                x: (CGFloat(i) - 1.0) * circleParams.spacing,
                y: circleParams.yPosition
            )
            goalParent.addChild(circle)
            circles.append(circle)
        }
    }
    
    private func setupView() {
        let bg = SKSpriteNode(imageNamed: "footballBack")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(bg)
        
        let goalLabel = SKLabelNode(fontNamed: "Agdasima-Regular")
        goalLabel.text = "GOAL:"
        goalLabel.fontColor = .white
        goalLabel.fontSize = 34
        goalLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.15)
        addChild(goalLabel)
       
        tapToPlayLabel = SKLabelNode(fontNamed: "Agdasima-Regular")
        tapToPlayLabel.text = "TAP TO PLAY"
        tapToPlayLabel.fontColor = .white
        tapToPlayLabel.fontSize = 64
        tapToPlayLabel.position = CGPoint(x: size.width / 2, y: size.height / 10)
        addChild(tapToPlayLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBallFlying, let touch = touches.first else { return }
        
        if isFirstTouch {
            tapToPlayLabel.removeFromParent()
            isFirstTouch = false
            return
        }
        
        swipeStartPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBallFlying,
              let _ = swipeStartPoint,
              let end = touches.first?.location(in: self) else { return }
        
        startBallFlight(to: end)
        swipeStartPoint = nil
    }
    
    private func startBallFlight(to target: CGPoint) {
        isBallFlying = true
        currentAttempt += 1
        
        let distance = hypot(target.x - ball.position.x, target.y - ball.position.y)
        let duration = TimeInterval(distance / 500)
        
        let move = SKAction.move(to: target, duration: duration)
        let scale = SKAction.scale(to: 0.67, duration: duration)
        let rotate = SKAction.rotate(byAngle: .pi * 4, duration: duration)
        
        ball.run(SKAction.group([move, scale, rotate])) { [weak self] in
            self?.handleFlightCompletion()
        }
    }
    
    private func handleFlightCompletion() {
        isBallFlying = false
        checkGoalResult()
        resetBall()
        increaseKeeperSpeed()
    }
    
    private func checkGoalResult() {
        guard currentAttempt > 0 && currentAttempt <= circles.count else { return }
        let ballInGoal = goalRect.contains(ball.position)
        let ballFrame = ball.frame
        let keeperFrame = keeper.frame
        let ballHitKeeper = ballFrame.intersects(keeperFrame)
        if ballInGoal && !ballHitKeeper {
            circles[currentAttempt - 1].fillColor = UIColor(red: 190/255, green: 255/255, blue: 138/255, alpha: 1)
            game?.goal += 1
        } else {
            circles[currentAttempt - 1].fillColor = UIColor(red: 255/255, green: 138/255, blue: 161/255, alpha: 1)
        }
    }

    private func resetBall() {
        ball.removeAllActions()
        ball.position = CGPoint(x: size.width/2, y: size.height/3.7)
        ball.zRotation = 0
        ball.setScale(1.0)
        
        if currentAttempt >= attempts {
            scene?.isPaused = true
            game?.isEnd = true
            switch game?.goal {
            case 1:
                UserDefaultsManager().addCoin(coins: 30)
            case 2:
                UserDefaultsManager().addCoin(coins: 50)
            case 3:
                UserDefaultsManager().addCoin(coins: 100)
            case .none:
                UserDefaultsManager().addCoin(coins: 0)
            case .some(_):
                UserDefaultsManager().addCoin(coins: 0)
            }
       
        }
    }
    
    private func startKeeperMovement() {
        let moveAction = SKAction.sequence([
            SKAction.moveTo(x: size.width * 0.2, duration: keeperSpeed),
            SKAction.moveTo(x: size.width * 0.8, duration: keeperSpeed)
        ])
        
        keeper.run(SKAction.repeatForever(moveAction))
    }
    
    private func increaseKeeperSpeed() {
        keeperSpeed = max(0.5, keeperSpeed * 0.8)
        keeper.removeAllActions()
        startKeeperMovement()
    }
}


struct StakePenaltyView: View {
    @StateObject var stakePenaltyModel =  StakePenaltyViewModel()
    @StateObject var gameModel = FootballGameData()
    
    var body: some View {
        ZStack {
            SpriteView(scene: stakePenaltyModel.createGameScene(gameData: gameModel))
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .fullScreenCover(isPresented: $gameModel.isEnd) {
                    StakeTabBarView()
                }
        }
    }
}

#Preview {
    StakePenaltyView()
}
