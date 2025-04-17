import SwiftUI

struct StakeAuthView: View {
    @StateObject var stakeAuthModel =  StakeAuthViewModel()
    
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
                VStack(alignment: .trailing) {
                    Color(.clear)
                        .frame(height: setSize())
                    
                    Rectangle()
                        .fill(.darkMain)
                        .frame(height: 40)
                        .overlay {
                            Text("Registration")
                                .Stake(size: 24)
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(.black, lineWidth: 0.5)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 5) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Name:")
                                .Stake(size: 20)
                                .padding(.leading)
                            
                            CustomTextFiled(text: $stakeAuthModel.name,
                                            placeholder: "Player_Name")
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("E-mail:")
                                .Stake(size: 20)
                                .padding(.leading)
                            
                            CustomTextFiled(text: $stakeAuthModel.email,
                                            placeholder: "account@email.com")
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Password:")
                                .Stake(size: 20)
                                .padding(.leading)
                            
                            CustomSecureField(text: $stakeAuthModel.password,
                                              placeholder: "***********************")
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Repeat password:")
                                .Stake(size: 20)
                                .padding(.leading)
                            
                            CustomSecureField(text: $stakeAuthModel.confirmPassword,
                                              placeholder: "***********************")
                        }
                    }
                    .padding(.top)
                    
                    Button(action: {
                        stakeAuthModel.handleRegistration()
                    }) {
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                            .overlay {
                                Text("Sign up")
                                    .Stake(size: 24)
                                    .offset(y: -2)
                            }
                            .frame(height: 45)
                            .padding(.horizontal, 100)
                    }
                    .padding(.top)
                    
                    Rectangle()
                        .fill(.darkMain)
                        .frame(height: 40)
                        .overlay {
                            Text("Logging in")
                                .Stake(size: 24)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 5) {
                        VStack(alignment: .leading, spacing: 3) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("E-mail:")
                                    .Stake(size: 20)
                                    .padding(.leading)
                                
                                CustomTextFiled(text: $stakeAuthModel.email2,
                                                placeholder: "account@email.com")
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Password:")
                                    .Stake(size: 20)
                                    .padding(.leading)
                                
                                CustomSecureField(text: $stakeAuthModel.password2,
                                                  placeholder: "***********************")
                            }
                        }
                        .padding(.top)
                    }
                    
                    Button(action: {
                        stakeAuthModel.handleLogin()
                    }) {
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
                            .overlay {
                                Text("Sign In")
                                    .Stake(size: 24)
                                    .offset(y: -2)
                            }
                            .frame(height: 45)
                            .padding(.horizontal, 100)
                    }
                    .padding(.top)
                    
//                    Button(action: {
//                        UserDefaultsManager().enterAsGuest()
//                        stakeAuthModel.isLog = true
//                    }) {
//                        Rectangle()
//                            .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain], startPoint: .top, endPoint: .bottom))
//                            .overlay {
//                                Text("Guest access")
//                                    .Stake(size: 24)
//                                    .offset(y: -2)
//                            }
//                            .frame(height: 45)
//                            .padding(.horizontal, 100)
//                    }
//                    .padding(.top)
                }
            }
        }
        .alert(stakeAuthModel.alertMessage, isPresented: $stakeAuthModel.showAlert) {
            Button("OK", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $stakeAuthModel.isLog) {
            StakeTabBarView()
        }
    }
}

#Preview {
    StakeAuthView()
}
