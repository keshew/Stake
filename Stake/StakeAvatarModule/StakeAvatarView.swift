import SwiftUI

struct StakeAvatarView: View {
    @StateObject var stakeAvatarModel = StakeAvatarViewModel()
    @State var isTab = false
    var columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    @State private var isEditing = false
    @State private var newNickname: String = ""
    @StateObject var userDefaultsManager = UserDefaultsManager()
    @State var forRefresh = 0
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            Color(red: 14/255, green: 31/255, blue: 43/255)
                .frame(height: UIScreen.main.bounds.height / 8)
                .ignoresSafeArea(edges: .top)
                .shadow(radius: 5, y: 5)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 27)
            
            VStack {
                VStack {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .offset(y: 3)
                            .padding(.leading)
                            .onTapGesture {
                                isTab = true
                            }
                        
                        Spacer()
                        
                        Text("Choose an avatar")
                            .StakeCurly(size: 24)
                            .padding(.trailing, 40)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 25) {
                        Image(userDefaultsManager.selectedAvatar)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .padding(.leading)
                        
                        VStack(alignment: .leading, spacing: 17) {
                            Rectangle()
                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                .overlay {
                                    HStack {
                                              if isEditing {
                                                  TextField("Nickname", text: $newNickname, onCommit: {
                                                      if let email = userDefaultsManager.getEmail() {
                                                          userDefaultsManager.saveNickname(newNickname, for: email)
                                                      }
                                                      isEditing = false
                                                  })
                                                  .font(.custom("Agdasima-Regular", size: 12))
                                                  .foregroundStyle(.white)
                                                  .lineLimit(1)
                                                  .minimumScaleFactor(0.7)
                                                  .onAppear {
                                                      if let email = userDefaultsManager.getEmail(),
                                                         let current = userDefaultsManager.getNickname(for: email) {
                                                          newNickname = current
                                                      }
                                                  }
                                              } else {
                                                  Text(userDefaultsManager.getNickname(for: userDefaultsManager.getEmail() ?? "") ?? "")
                                                      .Stake(size: 12)
                                                      .lineLimit(1)
                                                      .minimumScaleFactor(0.7)
                                              }
                                              
                                              Spacer()
                                              
                                              Button(action: {
                                                  if !userDefaultsManager.isGuest() {
                                                      isEditing = true
                                                  }
                                              }) {
                                                  Image(.pen)
                                                      .resizable()
                                                      .frame(width: 12, height: 15)
                                              }
                                          }
                                          .padding(.horizontal, 8)
                                }
                                .frame(width: 120, height: 30)
                                .cornerRadius(5)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Account Lvl. 1")
                                    .Stake(size: 12)
                                
                                Rectangle()
                                    .fill(LinearGradient(colors: [Color(red: 45/255, green: 65/255, blue: 80/255), Color(red: 112/255, green: 136/255, blue: 149/255)], startPoint: .leading, endPoint: .trailing))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.black, lineWidth: 1)
                                    }
                                    .frame(width: 130, height: 20)
                                    .cornerRadius(5)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns) {
                        ForEach(0..<25, id: \.self) { index in
                            if !userDefaultsManager.ava[index].isForMoney {
                                if userDefaultsManager.ava[index].isOpen {
                                    Image("ava\(index + 1)")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .onTapGesture {
                                                 userDefaultsManager.selectAvatar("ava\(index + 1)")
                                             }
                                } else {
                                    Image(.lockedAva)
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                }
                            } else {
                                let number = 500 + (index - 20) * 100
                                Rectangle()
                                    .fill(Color(red: 26/255, green: 45/255, blue: 56/255))
                                    .overlay {
                                        Rectangle()
                                            .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                                            .overlay {
                                                Text("\(number)")
                                                    .Stake(size: 16)
                                                    .offset(y: -2)
                                            }
                                            .frame(height: 30)
                                            .cornerRadius(6)
                                            .padding(.horizontal, 10)
                                    }
                                
                                    .frame(width: 80, height: 80)
                                    .onTapGesture {
                                        userDefaultsManager.buyAvatar(at: index, price: number)
                                        forRefresh = 1
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .fullScreenCover(isPresented: $isTab) {
            StakeTabBarView()
        }
    }
}

#Preview {
    StakeAvatarView()
}
