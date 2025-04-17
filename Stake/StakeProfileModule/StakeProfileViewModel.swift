import SwiftUI

class StakeProfileViewModel: ObservableObject {
    let contact = StakeProfileModel()
    @Published var isAva = false
    @Published var isLogOut = false
    @Published var testing = 0
    @Published var isSound: Bool {
        didSet {
            UserDefaults.standard.set(isSound, forKey: "isSound")
        }
    }
    
    @Published var isMusic: Bool {
          didSet {
              UserDefaults.standard.set(isMusic, forKey: "isMusic")
          }
      }
    
    @Published var isPushNotif: Bool {
        didSet {
            UserDefaults.standard.set(isPushNotif, forKey: "isPushNotif")
        }
    }
    
    @Published var isVib: Bool {
          didSet {
              UserDefaults.standard.set(isVib, forKey: "isVib")
          }
      }
    
    init() {
        isVib = UserDefaults.standard.bool(forKey: "isVib")
        isPushNotif = UserDefaults.standard.bool(forKey: "isPushNotif")
        isSound = UserDefaults.standard.bool(forKey: "isSound")
        isMusic = UserDefaults.standard.bool(forKey: "isMusic")
      }
}
