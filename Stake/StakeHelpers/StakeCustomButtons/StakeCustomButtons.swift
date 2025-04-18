import SwiftUI
import UniformTypeIdentifiers

struct TrackerItem: View {
    let imageName: String
    let tab: CustomTracker.TrackerTabType
    @Binding var selectedTab: CustomTracker.TrackerTabType
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 8) {
                Image(selectedTab == tab ? imageName + "Picked" : imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct CustomTracker: View {
    @Binding var selectedTab: TrackerTabType
    
    enum TrackerTabType: Int {
        case Calendar
        case Task
        case Statistic
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 20) {
                TrackerItem(
                    imageName: "calendar",
                    tab: .Calendar,
                    selectedTab: $selectedTab
                )
                TrackerItem(
                    imageName: "tracker",
                    tab: .Task,
                    selectedTab: $selectedTab
                )
                TrackerItem(
                    imageName: "stat",
                    tab: .Statistic,
                    selectedTab: $selectedTab
                )
            }
            .frame(width: UIScreen.main.bounds.size.width * 0.9, height: 45)
            .padding(.top, setSize())
        }
    }
    
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
}

struct TaskView: View {
    let task: TaskModel
    var color = Color.white
    var action: (() -> ())
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 25, height: 25)
                    .overlay {
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(color, lineWidth: 2)
                        if task.isDone {
                            Image(.done)
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                    }
                    .onTapGesture {
                        action()
                    }
                Text(task.name)
                    .Stake(size: 18, color: color)
                Spacer()
            }
            .padding(.leading)
            
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .padding(.horizontal)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabType
    
    enum TabType: Int {
        case Account
        case Tracker
        case Games
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 14/255, green: 31/255, blue: 43/255)
                .frame(height: 110)
                .edgesIgnoringSafeArea(.top)
            
            HStack(spacing: 0) {
                TabBarItem(
                    imageName: "tab1",
                    tab: .Account,
                    selectedTab: $selectedTab
                )
                TabBarItem(
                    imageName: "tab2",
                    tab: .Tracker,
                    selectedTab: $selectedTab
                )
                TabBarItem(
                    imageName: "tab3",
                    tab: .Games,
                    selectedTab: $selectedTab
                )
            }
            .padding(.top, 5)
            .frame(height: setSize())
        }
    }
    func setSize() -> CGFloat{
        if UIScreen.main.bounds.size.width > 900 {
            return 155
        } else if UIScreen.main.bounds.size.width > 700 {
            return 155
        } else if UIScreen.main.bounds.size.width < 390 {
            return 155
        } else {
            return 50
        }
    }
}

struct TabBarItem: View {
    let imageName: String
    let tab: CustomTabBar.TabType
    @Binding var selectedTab: CustomTabBar.TabType
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 8) {
                Image(selectedTab == tab ? imageName + "Picked" : imageName)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: selectedTab == tab ? 50 : 40)
                    .offset(y: selectedTab == tab ? 0 : 3)
            }
            .frame(maxWidth: .infinity)
        }
    }
}



struct UniversalDropDelegate: DropDelegate {
    @Binding var tasks: [TaskModel]
    let userDefaultsManager: UserDefaultsManager
    @Binding var currentTask: TaskModel?
    let targetCategoryId: String?
    let targetIsDone: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedTask = currentTask else { return false }
        
        if let index = tasks.firstIndex(where: { $0.id == draggedTask.id }) {
            tasks[index].categoryId = targetCategoryId
            tasks[index].isDone = targetIsDone
            userDefaultsManager.saveTasks(tasks)
        }
        
        self.currentTask = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        
    }
}

struct CalendarDayCell: View {
    let text: String
    let isCurrentMonth: Bool
    let isToday: Bool
    let date: Date
    let geometry: GeometryProxy
    var isSelected: Bool = false
    var body: some View {
        ZStack {
            if isToday {
                RoundedRectangle(cornerRadius: 0)
                    .fill(isToday ? Color(red: 14/255, green: 31/255, blue: 43/255) : Color(red: 26/255, green: 44/255, blue: 57/255))
                    .overlay {
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(.white, lineWidth: 1)
                    }
            } else {
                RoundedRectangle(cornerRadius: 0)
                    .fill(isSelected ? Color(red: 14/255, green: 31/255, blue: 43/255) : (isToday ? Color(red: 14/255, green: 31/255, blue: 43/255) : Color(red: 26/255, green: 44/255, blue: 57/255)))
            }
            
            Text(text)
                .Stake(size: 14)
                .foregroundColor(isCurrentMonth ? .white : .gray)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct CustomTextFiled: View {
    @Binding var text: String
    @FocusState var isTextFocused: Bool
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                .frame(height: 28)
                .padding(.horizontal, 15)
            
            TextField("", text: $text, onEditingChanged: { isEditing in
                if !isEditing {
                    isTextFocused = false
                }
            })
            .padding(.horizontal, 16)
            .frame(height: 54)
            .font(.custom("Agdasima-Regular", size: 15))
            .cornerRadius(20)
            .foregroundStyle(.white)
            .focused($isTextFocused)
            .padding(.horizontal, 15)
            .padding(.leading, 13)
            
            HStack(spacing: -13) {
                Image(.pen)
                    .resizable()
                    .frame(width: 16, height: 22)
                    .padding(.leading, 15)
                
                if text.isEmpty && !isTextFocused {
                    Text(placeholder)
                        .Stake(size: 16, color: .white)
                        .padding(.leading, 20)
                        .onTapGesture {
                            isTextFocused = true
                        }
                }
            }
            .padding(.leading, 5)
        }
        .frame(height: 28)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    @FocusState var isTextFocused: Bool
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                .frame(height: 28)
                .padding(.horizontal, 15)
            
            SecureField("", text: $text)
                .padding(.horizontal, 16)
                .font(.custom("Agdasima-Regular", size: 16))
                .cornerRadius((20))
                .foregroundStyle(.white)
                .focused($isTextFocused)
                .padding(.horizontal, 15)
                .padding(.leading, 13)
            
            HStack(spacing: -13) {
                Image(.pen)
                    .resizable()
                    .frame(width: 16, height: 22)
                    .padding(.leading, 15)
                
                if text.isEmpty && !isTextFocused {
                    Text(placeholder)
                        .Stake(size: 16, color: .white)
                        .padding(.leading, 20)
                        .onTapGesture {
                            isTextFocused = true
                        }
                }
            }
            .padding(.leading, 5)
        }
        .frame(height: 28)
    }
}

struct DailyTaskView: View {
    @State private var isEditing = false
    @State private var isEditingCategory = false
    @State private var taskText = ""
    @State private var categoryText = ""
    @State private var tasks: [TaskModel] = []
    @State private var categories: [CategoryModel] = []
    @State private var draggedTask: TaskModel?
    private let userDefaultsManager = UserDefaultsManager()
    
    private var doneTasks: [TaskModel] {
        let today = Date()
        return tasks.filter { task in
            task.isDone &&
            task.categoryId == nil &&
            Calendar.current.isDate(task.date, inSameDayAs: today)
        }
    }

    private var unDoneTasks: [TaskModel] {
        let today = Date()
        return tasks.filter { task in
            !task.isDone &&
            task.categoryId == nil &&
            Calendar.current.isDate(task.date, inSameDayAs: today)
        }
    }

    
    private func saveTask() {
        guard !taskText.isEmpty else { return }
        
        let newTask = TaskModel(name: taskText, isDone: false, categoryId: nil)
        userDefaultsManager.addTask(newTask, to: &tasks)
        userDefaultsManager.saveTasks(tasks)
        
        taskText = ""
        isEditing.toggle()
    }
    
    private func loadTasks() {
        tasks = userDefaultsManager.loadTasks()
    }
    
    private func loadCategories() {
        categories = userDefaultsManager.loadCategories()
    }
    
    private func moveTask(task: TaskModel, isDone: Bool) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone = isDone
            userDefaultsManager.saveTasks(tasks)
        }
    }
    
    private func tasksForCategory(category: CategoryModel) -> [TaskModel] {
        return tasks.filter { task in
            return task.categoryId == category.id
        }
    }
    
    func setSize() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return 190
        } else if UIScreen.main.bounds.size.width > 700 {
            return 190
        } else if UIScreen.main.bounds.size.width < 390 {
            return 190
        } else {
            return 115
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Color(.clear)
                    .frame(height: setSize())
                
                VStack(spacing: 5) {
                    Rectangle()
                        .fill(.darkMain)
                        .frame(height: 40)
                        .overlay {
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .Stake(size: 24)
                        }
                        .padding(.horizontal)
                    
                    VStack(spacing: 5) {
                        if isEditing {
                            HStack {
                                Image(.plus)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .onTapGesture {
                                        saveTask()
                                        isEditing.toggle()
                                    }
                                
                                TextField("New task name", text: $taskText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.custom("Agdasima-Regular", size: 20))
                                    .foregroundStyle(Color(red: 128/255, green: 155/255, blue: 172/255))
                                    .submitLabel(.done)
                                    .onSubmit {
                                        isEditing.toggle()
                                        saveTask()
                                    }
                            }
                            .padding(.horizontal)
                        } else {
                            Button(action: { isEditing.toggle() }) {
                                HStack {
                                    Image(.plus)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("New task")
                                        .Stake(size: 18)
                                    
                                    Spacer()
                                }
                                .frame(height: 34)
                            }
                            .disabled(!userDefaultsManager.checkLogin() ? true : false)
                            .opacity(!userDefaultsManager.checkLogin() ? 0.5 : 1)
                            .padding(.leading)
                        }
                        
                        Rectangle()
                            .fill(.white)
                            .frame(height: 3)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 10) {
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 38)
                            .overlay {
                                HStack {
                                    Text("Planned:")
                                        .Stake(size: 20)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        
                        ForEach(unDoneTasks) { task in
                            TaskView(task: task) {
                                if userDefaultsManager.checkLogin() {
                                    moveToDone(task: task)
                                }
                            }
                            .onDrag {
                                self.draggedTask = task
                                return NSItemProvider(object: String(task.id) as NSString)
                            }
                            .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: nil, targetIsDone: false))
                        }
                    }
                    .padding(.top, 5)
                    .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: nil, targetIsDone: false))
                    
                    ForEach(categories) { category in
                        VStack(spacing: 10) {
                            Rectangle()
                                .fill(.darkMain)
                                .frame(height: 38)
                                .overlay {
                                    HStack {
                                        Text(category.name)
                                            .Stake(size: 20)
                                            .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            
                            ForEach(tasksForCategory(category: category)) { task in
                                TaskView(task: task) {
                                    if userDefaultsManager.checkLogin() {
                                        moveToDone(task: task)
                                    }
                                }
                                .onDrag {
                                    self.draggedTask = task
                                    return NSItemProvider(object: String(task.id) as NSString)
                                }
                                .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: category.id, targetIsDone: false))
                            }
                        }
                        .padding(.top, 5)
                        .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: category.id, targetIsDone: false))
                    }
                    
                    if !doneTasks.isEmpty {
                        VStack(spacing: 10) {
                            Rectangle()
                                .fill(.darkMain)
                                .frame(height: 38)
                                .overlay {
                                    HStack {
                                        Text("Done:")
                                            .Stake(size: 20)
                                            .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            
                            ForEach(doneTasks) { task in
                                TaskView(task: task) {
                                    if userDefaultsManager.checkLogin() {
                                        moveToPlanned(task:task)
                                    }
                                }
                                .onDrag {
                                    self.draggedTask = task
                                    return NSItemProvider(object: String(task.id) as NSString)
                                }
                                .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: nil, targetIsDone: true))
                            }
                        }
                        .padding(.top, 5)
                        .onDrop(of: [UTType.text], delegate: UniversalDropDelegate(tasks: $tasks, userDefaultsManager: userDefaultsManager, currentTask: $draggedTask, targetCategoryId: nil, targetIsDone: true))
                    }
                    
                    
                    
                    ZStack {
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 38)
                            .padding(.horizontal)
                        
                        VStack(spacing: 5) {
                            if isEditingCategory {
                                HStack {
                                    Image(.plus)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .onTapGesture {
                                            let category = CategoryModel(name: categoryText)
                                            userDefaultsManager.addCategory(category, to: &categories)
                                            self.categories = userDefaultsManager.loadCategories()
                                            isEditingCategory.toggle()
                                            categoryText = ""
                                        }
                                    
                                    TextField("New category name", text: $categoryText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.custom("Agdasima-Regular", size: 20))
                                        .foregroundStyle(Color(red: 128/255, green: 155/255, blue: 172/255))
                                        .submitLabel(.done)
                                        .onSubmit {
                                            let category = CategoryModel(name: categoryText)
                                            userDefaultsManager.addCategory(category, to: &categories)
                                            self.categories = userDefaultsManager.loadCategories()
                                            isEditingCategory.toggle()
                                            categoryText = ""
                                        }
                                }
                                .padding(.horizontal)
                            } else {
                                Button(action: { isEditingCategory.toggle() }) {
                                    HStack {
                                        Image(.plus)
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        
                                        Text("New category")
                                            .Stake(size: 18)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 34)
                                }
                                .disabled(!userDefaultsManager.checkLogin() ? true : false)
                                .opacity(!userDefaultsManager.checkLogin() ? 0.5 : 1)
                                .padding(.leading)
                            }
                            
                            Rectangle()
                                .fill(.white)
                                .frame(height: 3)
                                .padding(.horizontal)
                        }
                        .offset(y: 5)
                    }
                    .padding(.top, 5)
                }
            }
            .padding(.top)
        }
        .onAppear {
            loadTasks()
            loadCategories()
        }
    }
    
    func moveToDone(task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone = true
            tasks[index].categoryId = nil
            userDefaultsManager.saveTasks(tasks)
        }
    }
    
    func moveToPlanned(task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone = false
            tasks[index].categoryId = nil
            userDefaultsManager.saveTasks(tasks)
        }
    }
}
