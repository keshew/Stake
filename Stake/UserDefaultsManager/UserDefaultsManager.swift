import Foundation
import SwiftUI

struct ImageWin: Codable {
    var name: String
    var isOpen: Bool
    var isSelected: Bool
    var isForMoney: Bool
}

class UserDefaultsManager: ObservableObject {
    private let daysCounterKey = "daysSinceFirstLaunch"
    private let firstLaunchKey = "firstLaunchDate"
    @Published var selectedAvatar: String {
        didSet {
            UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
        }
    }
    
    @Published var progress: Int {
        didSet {
            UserDefaults.standard.set(progress, forKey: "progress")
        }
    }
    
    init() {
        self.selectedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") ?? "profile"
        
        self.progress = UserDefaults.standard.integer(forKey: "progress")
        if self.progress > 100 {
            self.progress = 100
        }
    }
    
    func selectAvatar(_ name: String) {
        selectedAvatar = name
    }
    
    func incrementProgress() {
        progress = min(progress + 1, 100)
    }
    
    func resetProgress() {
        progress = 0
    }
    @Published var ava: [ImageWin] = {
        var images = [
            ImageWin(name: "ava1", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava2", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava3", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava4", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava5", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava6", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava7", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava8", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava9", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava10", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava11", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava12", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava13", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava14", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava15", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava16", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava17", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava18", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava19", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava20", isOpen: false, isSelected: false, isForMoney: false),
            ImageWin(name: "ava21", isOpen: false, isSelected: false, isForMoney: true),
            ImageWin(name: "ava22", isOpen: false, isSelected: false, isForMoney: true),
            ImageWin(name: "ava23", isOpen: false, isSelected: false, isForMoney: true),
            ImageWin(name: "ava24", isOpen: false, isSelected: false, isForMoney: true),
            ImageWin(name: "ava25", isOpen: false, isSelected: false, isForMoney: true)
        ]
        
        if let savedData = UserDefaults.standard.data(forKey: "avatars"),
           let decoded = try? JSONDecoder().decode([ImageWin].self, from: savedData) {
            images = decoded
        }
        return images
    }()
    
    func buyAvatar(at index: Int, price: Int) {
        let defaults = UserDefaults.standard
        var currentCoins = defaults.integer(forKey: "coin")
        
        guard currentCoins >= price else { return }
        
        currentCoins -= price
        defaults.set(currentCoins, forKey: "coin")
        
        var avatars = self.ava
        avatars[index].isOpen = true
        avatars[index].isForMoney = false
        self.ava = avatars
        
        if let encoded = try? JSONEncoder().encode(avatars) {
            defaults.set(encoded, forKey: "avatars")
        }
        selectAvatar("ava\(index + 1)")
    }
    
    
    func openAvatar(at index: Int) {
        guard index >= 0 && index < ava.count else { return }
        
        var updatedAva = ava
        updatedAva[index].isOpen = true
        
        ava = updatedAva
        
        if let encoded = try? JSONEncoder().encode(ava) {
            UserDefaults.standard.set(encoded, forKey: "avatars")
        }
    }
    
    func getDaysSinceFirstLaunch() -> Int {
        if UserDefaults.standard.object(forKey: firstLaunchKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchKey)
            return 0
        }
        
        guard let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchKey) as? Date else {
            return 0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstLaunchDate, to: Date())
        return components.day ?? 0
    }
    
    func updateDaysCounter() {
        let daysCount = getDaysSinceFirstLaunch()
        UserDefaults.standard.set(daysCount, forKey: daysCounterKey)
    }
    
    func loadDaysCounter() -> Int {
        return UserDefaults.standard.integer(forKey: daysCounterKey)
    }
    
    func isFirstLaunch()  {
        let defaults = UserDefaults.standard
        let isFirstLaunch = defaults.bool(forKey: "isFirstLaunch")
        
        if !isFirstLaunch {
            defaults.set(true, forKey: "isFirstLaunch")
            defaults.set(10000, forKey: "coin")
            defaults.set(5, forKey: "life")
            var tasks = loadTasks()
            let newTask = TaskModel(name: "Set up your To Do App!", isDone: false, categoryId: nil)
            addTask(newTask, to: &tasks)
            saveTasks(tasks)
        }
    }
    
    func addCoin(coins: Int) {
        let defaults = UserDefaults.standard
        let coin = defaults.integer(forKey: "coin")
        defaults.set(coin + coins, forKey: "coin")
    }
    
    func updateLifes() {
        let defaults = UserDefaults.standard
        let lastUpdateKey = "lastLifeUpdateDate"
        let maxLives = 5
        
        let now = Date()
        
        if let lastUpdate = defaults.object(forKey: lastUpdateKey) as? Date {
            let calendar = Calendar.current
            if let diff = calendar.dateComponents([.hour], from: lastUpdate, to: now).hour, diff >= 24 {
                defaults.set(maxLives, forKey: "life")
                defaults.set(now, forKey: lastUpdateKey)
            }
        } else {
            defaults.set(maxLives, forKey: "life")
            defaults.set(now, forKey: lastUpdateKey)
        }
    }
    
    
    func minusCoins(coins: Int) {
        let defaults = UserDefaults.standard
        let coin = defaults.integer(forKey: "coin")
        defaults.set(coin - coins, forKey: "coin")
    }
    
    func minusLifes(life: Int) {
        let defaults = UserDefaults.standard
        let lifes = defaults.integer(forKey: "life")
        defaults.set(lifes - life, forKey: "life")
    }
    
    func saveCategories(_ categories: [CategoryModel]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "categories")
        }
    }
    
    func loadCategories() -> [CategoryModel] {
        guard let data = UserDefaults.standard.data(forKey: "categories") else { return [] }
        return (try? JSONDecoder().decode([CategoryModel].self, from: data)) ?? []
    }
    
    func addCategory(_ category: CategoryModel, to categories: inout [CategoryModel]) {
        categories.append(category)
        saveCategories(categories)
    }
    
    func addTask(_ task: TaskModel, to tasks: inout [TaskModel]) {
        tasks.append(task)
    }
    
    func saveTasks(_ tasks: [TaskModel]) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(tasks)
            defaults.set(data, forKey: "tasks")
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    func loadTasks() -> [TaskModel] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "tasks") else { return [] }
        
        do {
            return try JSONDecoder().decode([TaskModel].self, from: data)
        } catch {
            print("Load error: \(error.localizedDescription)")
            return []
        }
    }
    
    func enterAsGuest() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "guest")
    }
    
    func isGuest() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "guest")
    }
    
    func quitQuest() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "guest")
    }
    
    func saveNickname(_ nickname: String, for email: String) {
        let defaults = UserDefaults.standard
        if var users = defaults.dictionary(forKey: "users") as? [String: [String: String]] {
            if var user = users[email] {
                user["nickname"] = nickname
                users[email] = user
                defaults.set(users, forKey: "users")
            }
        }
    }
    
    func register(email: String, password: String, nickname: String) -> Bool {
        let userDefaults = UserDefaults.standard
        var storedUsers: [String: [String: String]] = [:]
        
        if let existingUsers = userDefaults.dictionary(forKey: "users") as? [String: [String: String]] {
            storedUsers = existingUsers
        }
        
        if storedUsers[email] != nil {
            return false
        }
        
        storedUsers[email] = ["password": password, "nickname": nickname]
        userDefaults.set(storedUsers, forKey: "users")
        return true
    }
    
    
    func checkLogin() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "isLoggedIn")
    }
    
    private func saveLoginStatus(_ isLoggedIn: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isLoggedIn, forKey: "isLoggedIn")
    }
    
    func deleteAccount() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "users")
        saveLoginStatus(false)
        defaults.removeObject(forKey: "progress")
        defaults.removeObject(forKey: "selectedAvatar")
        defaults.removeObject(forKey: "avatars")
        defaults.removeObject(forKey: "userEmail")
    }
    
    func logout() {
        let defaults = UserDefaults.standard
        saveLoginStatus(false)
        defaults.removeObject(forKey: "users")
        defaults.removeObject(forKey: "progress")
        defaults.removeObject(forKey: "selectedAvatar")
        defaults.removeObject(forKey: "avatars")
        defaults.removeObject(forKey: "userEmail")
    }
    
    func getNickname(for email: String) -> String? {
        let defaults = UserDefaults.standard
        if let storedUsers = defaults.dictionary(forKey: "users") as? [String: [String: String]] {
            return storedUsers[email]?["nickname"]
        }
        return nil
    }
    
    func getEmail() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "currentEmail")
    }
    
    
    
    func saveCurrentEmail(_ email: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "currentEmail")
    }
    
    func login(email: String, password: String) -> Bool {
        let defaults = UserDefaults.standard
        if let storedUsers = defaults.dictionary(forKey: "users") as? [String: [String: String]] {
            for (storedUsername, storedUser) in storedUsers {
                if email == storedUsername && password == storedUser["password"] {
                    saveLoginStatus(true)
                    saveCurrentEmail(email)
                    return true
                }
            }
        }
        return false
    }
}
