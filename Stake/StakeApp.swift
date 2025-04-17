import SwiftUI

@main
struct StakeApp: App {
    var body: some Scene {
        WindowGroup {
            StakeTabBarView()
                .onAppear() {
                    UserDefaultsManager().updateDaysCounter()
                    UserDefaultsManager().updateLifes()
                    UserDefaultsManager().isFirstLaunch()
                }
        }
    }
}
