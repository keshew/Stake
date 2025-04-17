import SwiftUI
import SpriteKit

struct StakeWheelView: View {
    @StateObject var stakeWheelModel = StakeWheelViewModel()
    @State private var isSpinning = false
    @State private var spinAngle: Angle = .zero
    @State private var canSpinToday: Bool = true
    @State private var isWin = false
    let numberOfSections = 20
    let sectorRewards: [Int] = [
        500, 5, 10, 20, 250, 100, 50, 30, 15, 40,
        60, 80, 120, 200, 300, 400, 35, 55, 75, 150
    ]
    @State var numberOfWin = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 52/255, green: 48/255, blue: 151/255),
                Color(red: 57/255, green: 170/255, blue: 250/255)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack(alignment: .bottom) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(.leading, 40)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                            .frame(width: 37, height: 37)
                            .overlay {
                                Image(.coin)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .offset(y: 1)
                            }
                            .offset(y: 7)
                        
                        VStack(spacing: 3) {
                            Text("Cost:")
                                .Stake(size: 18)
                            
                            Rectangle()
                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                .overlay {
                                    Text("100")
                                        .Stake(size: 14)
                                }
                                .frame(width: 150, height: 23)
                                .cornerRadius(36)
                        }
                        
                        Spacer()
                    }
                    .padding(.trailing, 110)
                    
                    Image(.wheel)
                        .resizable()
                        .rotationEffect(spinAngle)
                        .overlay {
                            VStack {
                                Spacer()
                                Image(.pin)
                                    .resizable()
                                    .frame(width: 100, height: 120)
                                    .offset(y: 30)
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 450, height: 450)
                        .padding(.top, 40)
                    
                    if canSpinToday && !isSpinning {
                        Button(action: {
                            spinWheel()
                        }) {
                            Image(.spinBtn)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 60)
                        }
                        .padding(.top, 50)
                    }
                }
            }
            
            if isWin {
                WinView(number: $numberOfWin)
            }
        }
    }
    
    func mappedSectorNumber(from sectorIndex: Int) -> Int {
        let index = sectorIndex + 1
        
        if index <= 10 {
            return 11 - index
        } else {
            return 31 - index
        }
    }
    
    func spinWheel() {
        let lifeCount = UserDefaults.standard.integer(forKey: "life")
        guard lifeCount >= 1 else { return }
        guard !isSpinning else { return }
        isSpinning = true
        let randomSector = Int.random(in: 0..<numberOfSections)
        let sectorAngle = 360.0 / Double(numberOfSections)
        let targetAngleDegrees = Double(randomSector) * sectorAngle + sectorAngle / 2 + 180
        
        let totalRotation = spinAngle.degrees + 360 * 5 + targetAngleDegrees
        
        withAnimation(.easeInOut(duration: 5.0)) {
            spinAngle = Angle(degrees: totalRotation)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let finalAngle = (spinAngle.degrees).truncatingRemainder(dividingBy: 360)
            let adjustedAngle = (finalAngle - 180 + 360).truncatingRemainder(dividingBy: 360)
            let sectorIndex = Int(adjustedAngle / sectorAngle) % numberOfSections
            let mappedNumber = mappedSectorNumber(from: sectorIndex)
            numberOfWin = mappedNumber
            isSpinning = false
            isWin = true
        }
        
        UserDefaultsManager().minusLifes(life: 1)
        UserDefaultsManager().minusCoins(coins: 100)
    }
}

#Preview {
    StakeWheelView()
}

struct WinView: View {
    @State var isClaim = false
    @Binding var number: Int
    var body: some View {
        ZStack {
            Color(.black).opacity(0.5).ignoresSafeArea()
            
            VictoryParticlesView()
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(spacing: 0) {
                        Image(.congratulation)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 390, height: 80)
                        
                        Text("You win a new avatar!")
                            .StakeCurly(size: 30)
                    }
                    
                    Image(.solar)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: 550)
                        .offset(y: -70)
                        .overlay {
                            VStack(spacing: 50) {
                                Image(UserDefaultsManager().ava[number].name)
                                .resizable()
                                .frame(width: 250, height: 250)
                                .cornerRadius(20)
                        
                                VStack(spacing: 20) {
                                    Text("You can change it in your account.")
                                        .Stake(size: 24)
                                        .outlineText(color: .black, width: 0.7)
                                    
                                    Button(action: {
                                        isClaim = true
                                        
                                        UserDefaultsManager().openAvatar(at: number)
                                    }) {
                                        Text("CLAIM")
                                            .Stake(size: 24)
                                            .outlineText(color: .black, width: 0.7)
                                    }
                                }
                            }
                            .padding(.top, -80)
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $isClaim) {
            StakeTabBarView()
        }
    }
}

struct VictoryParticlesView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = VictoryScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}

class VictoryScene: SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.clear
        view.allowsTransparency = true
        let textures = (1...2).map { SKTexture(imageNamed: "it\($0)") }
        let addParticleAction = SKAction.run {
            self.addParticle(texture: textures.randomElement()!)
        }
        let sequence = SKAction.sequence([
            addParticleAction,
            SKAction.wait(forDuration: 0.5)
        ])
        run(SKAction.repeatForever(sequence))
    }
    
    private func addParticle(texture: SKTexture) {
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: size.height / 0.8
        )
        spriteNode.setScale(0.05)
        spriteNode.zRotation = CGFloat.random(in: -CGFloat.pi/2...CGFloat.pi/2)
        addChild(spriteNode)
        let moveAction = SKAction.move(
            to: CGPoint(x: spriteNode.position.x, y: -spriteNode.size.height),
            duration: 10
        )
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let removeAction = SKAction.removeFromParent()
        spriteNode.run(SKAction.sequence([
            SKAction.group([moveAction, rotateAction]),
            removeAction
        ]))
    }
}
