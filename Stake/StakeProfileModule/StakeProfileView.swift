import SwiftUI

struct StakeProfileView: View {
    @StateObject var stakeProfileModel =  StakeProfileViewModel()
    @State var userDefaultsManager = UserDefaultsManager()
    @State private var isEditing = false
    @State private var newNickname: String = ""
    
    func setSize() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return 100
        } else if UIScreen.main.bounds.size.width > 700 {
            return 100
        } else if UIScreen.main.bounds.size.width < 390 {
            return 100
        } else {
            return 40
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
                    
                    HStack(spacing: 25) {
                        Image(userDefaultsManager.selectedAvatar)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .padding(.leading)
                            .onTapGesture {
                              if !userDefaultsManager.isGuest() {
                                    stakeProfileModel.isAva = true
                                }
                            }
                        
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
                                    .fill(.black)
                                    .overlay {
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .fill( LinearGradient(
                                                        colors: [
                                                            Color(red: 45/255, green: 65/255, blue: 80/255),
                                                            Color(red: 112/255, green: 136/255, blue: 149/255)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ))
                                                    .frame(width: geometry.size.width * CGFloat(userDefaultsManager.progress) / 100)
                                            }
                                        }
                                    }
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
                    
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            Button(action: {
                                stakeProfileModel.isSound.toggle()
                            }) {
                                Rectangle()
                                    .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                    .overlay {
                                        Text("SOUND: \(stakeProfileModel.isSound ? "OFF" : "ON")")
                                            .Stake(size: 16)
                                    }
                                    .frame(width: 120, height: 40)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                stakeProfileModel.isMusic.toggle()
                            }) {
                                Rectangle()
                                    .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                    .overlay {
                                        Text("MUSIC: \(stakeProfileModel.isMusic ? "OFF" : "ON")")
                                            .Stake(size: 16)
                                    }
                                    .frame(width: 120, height: 40)
                                    .cornerRadius(10)
                            }
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                stakeProfileModel.isPushNotif.toggle()
                            }) {
                                Rectangle()
                                    .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                    .overlay {
                                        Text("NOTIFICATIONS: \(stakeProfileModel.isPushNotif ? "OFF" : "ON")")
                                            .Stake(size: 14)
                                    }
                                    .frame(width: 120, height: 40)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                stakeProfileModel.isVib.toggle()
                            }) {
                                Rectangle()
                                    .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                    .overlay {
                                        Text("VIBRATION: \(stakeProfileModel.isVib ? "OFF" : "ON")")
                                            .Stake(size: 16)
                                    }
                                    .frame(width: 120, height: 40)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 50)
                    
                    VStack {
                        Button(action: {
                            stakeProfileModel.testing = 120
                            userDefaultsManager.resetProgress()
                        }) {
                            Rectangle()
                                .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                                .overlay {
                                    Text("Reset level")
                                        .Stake(size: 24)
                                        .offset(y: -2)
                                }
                                .frame(width: 250, height: 45)
                                
                        }
                        .disabled(userDefaultsManager.isGuest() ? true : false)
                        .opacity(userDefaultsManager.isGuest() ? 0.5 : 1)
                        
                        Button(action: {
                            UserDefaultsManager().logout()
                            stakeProfileModel.isLogOut = true
                            if userDefaultsManager.isGuest() {
                                userDefaultsManager.quitQuest()
                            }
                            
                        }) {
                            Rectangle()
                                .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                                .overlay {
                                    Text(userDefaultsManager.isGuest() ? "Log out as Guest" : "Log out of the account")
                                        .Stake(size: 24)
                                        .offset(y: -2)
                                }
                                .frame(width: 250, height: 45)
                        }
                        
                        if !userDefaultsManager.isGuest() {
                            Button(action: {
                                UserDefaultsManager().deleteAccount()
                                stakeProfileModel.isLogOut = true
                            }) {
                                Rectangle()
                                    .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                                    .overlay {
                                        Text("Delete account")
                                            .Stake(size: 24)
                                            .offset(y: -2)
                                    }
                                    .frame(width: 250, height: 45)
                                
                            }
                        }
                    }
                    .padding(.top, 50)
                }
            }
        }
        .fullScreenCover(isPresented: $stakeProfileModel.isAva) {
            StakeAvatarView()
        }
        .fullScreenCover(isPresented: $stakeProfileModel.isLogOut) {
            StakeTabBarView()
        }
    }
}

#Preview {
    StakeProfileView()
}

