import SwiftUI

class StakeAuthViewModel: ObservableObject {
    let contact = StakeAuthModel()
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var email2 = ""
    @Published var password2 = ""
    @Published var confirmPassword = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLog = false
    var userDefaultsManager = UserDefaultsManager()
    
    private func validateFields() -> Bool {
         if name.isEmpty ||
            email.isEmpty ||
            password.isEmpty ||
            confirmPassword.isEmpty {
             
             alertMessage = "All fileds must be filled"
             showAlert = true
             return false
         }
         
         if password != confirmPassword {
            alertMessage = "Passwrods are not the same"
            showAlert = true
             return false
         }
         
         return true
     }
    
     func handleRegistration() {
        guard validateFields() else { return }
        
        let success = userDefaultsManager.register(
            email: email,
            password: password,
            nickname: name
        )
        
        if success {
            showAlert = true
            alertMessage = "Success!"
        } else {
            showAlert = true
            alertMessage = "This email already exist"
        }
    }
    
    func handleLogin() {
            guard validateLoginFields() else { return }
            
            if userDefaultsManager.login(email: email2, password: password2) {
                isLog = true
            } else {
                showAlert = true
                alertMessage = "Incorrent login or email"
            }
        }
        
        private func validateLoginFields() -> Bool {
            if email2.isEmpty || password2.isEmpty {
                alertMessage = "All fileds must be filled"
                showAlert = true
                return false
            }
            return true
        }
}
