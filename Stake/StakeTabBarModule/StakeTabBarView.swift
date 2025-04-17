import SwiftUI

struct StakeTabBarView: View {
    @StateObject var stakeTabBarModel = StakeTabBarViewModel()
    @State private var selectedTab: CustomTabBar.TabType = .Account
 
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    if selectedTab == .Account {
                        if UserDefaultsManager().checkLogin() {
                            StakeProfileView()
                        } else {
                            StakeAuthView()
                        }
                    } else if selectedTab == .Tracker {
                        StakeTrackerView()
                    } else if selectedTab == .Games {
                        StakeGamesView()
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .overlay(
            CustomTabBar(selectedTab: $selectedTab)
                .shadow(radius: 5, y: 3),
            alignment: .top
        )
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    StakeTabBarView()
}
