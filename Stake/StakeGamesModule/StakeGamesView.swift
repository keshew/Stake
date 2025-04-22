import SwiftUI

struct StakeGamesView: View {
    @StateObject var stakeGamesModel =  StakeGamesViewModel()
    @State var isWheel = false
    @State var isBreak = false
    @State var isPenalty = false
    
    func setSize() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return 120
        } else if UIScreen.main.bounds.size.width > 700 {
            return 120
        } else if UIScreen.main.bounds.size.width < 390 {
            return 120
        } else {
            return 60
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Color(.clear)
                        .frame(height: setSize())
                    
                    HStack {
                        HStack {
                            Circle()
                                .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                .frame(width: 35, height: 35)
                                .overlay {
                                    Image(.heart)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .offset(y: 1)
                                }
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 130, height: 20)
                                    .cornerRadius(36)
                                
                                let lifeCount = UserDefaults.standard.integer(forKey: "life")
                                let maxLife = 5
                                let fullWidth: CGFloat = 130
                                let fillWidth = max(0, CGFloat(lifeCount) / CGFloat(maxLife) * fullWidth)

                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 45/255, green: 65/255, blue: 80/255),
                                                     Color(red: 112/255, green: 136/255, blue: 149/255)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: fillWidth, height: 20)
                                    .cornerRadius(36)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 36)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                
                                Text("\(lifeCount)/\(maxLife)")
                                    .Stake(size: 14)
                                    .foregroundColor(.white)
                                    .frame(width: fullWidth, height: 20)
                                    .multilineTextAlignment(.center)
                            }

                        }
                        
                        Spacer()
                        
                        HStack {
                            Circle()
                                .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                .frame(width: 35, height: 35)
                                .overlay {
                                    Image(.coin)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                            
                            Rectangle()
                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                .overlay {
                                    Text("\(UserDefaults.standard.integer(forKey: "coin"))")
                                        .Stake(size: 14)
                                }
                                .frame(width: 130, height: 20)
                                .cornerRadius(36)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text(stakeGamesModel.contact.text.randomElement() ?? "")
                        .Stake(size: 30)
                        .padding(.top)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                        .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                        .frame(height: 40)
                        .overlay(content: {
                            HStack {
                                Text("Games with random")
                                    .Stake(size: 22)
                                    .padding(.leading)
                                
                                Spacer()
                            }
                        })
                        .padding(.horizontal)
                        .padding(.top)
                    
                    HStack {
                        Button(action: {
                            if UserDefaults.standard.integer(forKey: "life") >= 1 {
                                if UserDefaults.standard.integer(forKey: "coin") >= 100 {
                                    isWheel = true
                                    UserDefaultsManager().incrementProgress()
                                }
                            }
                        }) {
                            Image(.wheelScreen)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 165, height: 165)
                        }
                        .disabled(!UserDefaultsManager().checkLogin() ? true : false)
                        .opacity(!UserDefaultsManager().checkLogin() ? 0.5 : 1)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Image(.lockedGame)
                                .resizable()
                                .overlay {
                                    Text("Opens at level 50")
                                        .Stake(size: 24)
                                }
                                .frame(width: 165, height: 165)
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                    
                    Rectangle()
                        .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                        .frame(height: 40)
                        .overlay(content: {
                            HStack {
                                Text("Mini-games")
                                    .Stake(size: 22)
                                    .padding(.leading)
                                
                                Spacer()
                            }
                        })
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    HStack {
                        Button(action: {
                            if UserDefaults.standard.integer(forKey: "life") >= 1 {
                                isBreak = true
                                UserDefaultsManager().incrementProgress()
                            }
                        }) {
                            Image(.miniScreen)
                                .resizable()
                                .frame(width: 165, height: 165)
                        }
                        .disabled(!UserDefaultsManager().checkLogin() ? true : false)
                        .opacity(!UserDefaultsManager().checkLogin() ? 0.5 : 1)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Image(.lockedGame)
                                .resizable()
                                .overlay {
                                    Text("Opens at level 60")
                                        .Stake(size: 24)
                                }
                                .frame(width: 165, height: 165)
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                    
                    Rectangle()
                        .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                        .frame(height: 40)
                        .overlay(content: {
                            HStack {
                                Text("Arcade games")
                                    .Stake(size: 22)
                                    .padding(.leading)
                                
                                Spacer()
                            }
                        })
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    HStack {
                        Button(action: {
                            if UserDefaults.standard.integer(forKey: "life") >= 1 {
                                isPenalty = true
                                UserDefaultsManager().incrementProgress()
                            }
                        }) {
                            Image(.arcadeScreen)
                                .resizable()
                                .frame(width: 165, height: 165)
                        }
                        .disabled(!UserDefaultsManager().checkLogin() ? true : false)
                        .opacity(!UserDefaultsManager().checkLogin() ? 0.5 : 1)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Image(.lockedGame)
                                .resizable()
                                .overlay {
                                    Text("Opens at level 70")
                                        .Stake(size: 24)
                                }
                                .frame(width: 165, height: 165)
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
            }
        }
        .fullScreenCover(isPresented: $isWheel) {
            StakeWheelView()
        }
        .fullScreenCover(isPresented: $isBreak) {
            StakeBreakView()
        }
        .fullScreenCover(isPresented: $isPenalty) {
            StakePenaltyView()
        }
    }
}

#Preview {
    StakeGamesView()
}

