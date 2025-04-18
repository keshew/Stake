import SwiftUI
import Charts
import UniformTypeIdentifiers

struct TaskModel: Codable, Identifiable {
    var id = UUID().uuidString
    var name: String
    var isDone: Bool
    var categoryId: String?
    var date = Date()
}

struct CategoryModel: Codable, Identifiable {
    var id = UUID().uuidString
    var name: String
}

struct StakeTrackerView: View {
    @StateObject var stakeTrackerModel =  StakeTrackerViewModel()
    @State private var selectedTab: CustomTracker.TrackerTabType = .Calendar
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.lightMain, Color.darkMain],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            ZStack {
                VStack(spacing: 0) {
                    VStack {
                        if selectedTab == .Calendar {
                            StakeCalendar()
                        } else if selectedTab == .Task {
                            DailyTaskView()
                        } else if selectedTab == .Statistic {
                            StatisticView()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .overlay(
                CustomTracker(selectedTab: $selectedTab)
                    .shadow(radius: 5, y: 3),
                alignment: .top
            )
            .ignoresSafeArea(.keyboard)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    StakeTrackerView()
}

struct StakeCalendar: View {
    @StateObject var stakeTrackerModel = StakeTrackerViewModel()
    @State private var currentDate = Date()
    let cellSpacing: CGFloat = 14
    @State private var sheetOffsetY: CGFloat = UIScreen.main.bounds.height * (UIScreen.main.bounds.width > 700 ? 0.3 : 0.26)

    private var sheetHeightRatio: CGFloat {
        UIScreen.main.bounds.width > 700 ? 0.35 : 0.35
    }
    private var maxOffsetY: CGFloat {
        UIScreen.main.bounds.width > 700 ? UIScreen.main.bounds.height * 0.3 : UIScreen.main.bounds.height * 0.26
    }

    private let minOffsetY: CGFloat = 0
    @State private var isEditing = false
    @State private var taskText = ""
    @State private var categories: [CategoryModel] = []
    @State private var tasks: [TaskModel] = []
    let userDefaultsManager = UserDefaultsManager()
    private var weeks: [[Date?]] {
        generateWeeks(for: currentDate)
    }
    @State private var selectedDate: Date? = nil
    private var previousMonthDate: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private var previousMonthWeeks: [[Date?]] {
        generateWeeks(for: previousMonthDate)
    }
    private func loadCategories() {
        categories = userDefaultsManager.loadCategories()
    }
    private func loadTasks() {
        tasks = userDefaultsManager.loadTasks()
    }
    
    private var doneTasks: [TaskModel] {
        filterTasks(tasks: tasks, isDone: true, for: selectedDate)
    }

    private var unDoneTasks: [TaskModel] {
        filterTasks(tasks: tasks, isDone: false, for: selectedDate)
    }

    private func filterTasks(tasks: [TaskModel], isDone: Bool, for date: Date?) -> [TaskModel] {
        guard let selectedDate = date else {
            return tasks.filter { $0.isDone == isDone }
        }
        
        let calendar = Calendar.current
        return tasks.filter { task in
            let taskDate = task.date
            return calendar.isDate(taskDate, inSameDayAs: selectedDate) && task.isDone == isDone
        }
    }

    
    private func saveTask() {
           guard !taskText.isEmpty else { return }
           
           let newTask = TaskModel(name: taskText, isDone: false)
           userDefaultsManager.addTask(newTask, to: &tasks)
           userDefaultsManager.saveTasks(tasks)
           
           taskText = ""
           isEditing.toggle()
       }
    
    private func tasksForCategory(category: CategoryModel) -> [TaskModel] {
        return tasks.filter { task in
            return task.categoryId == category.id
        }
    }
    
    private func moveTask(task: TaskModel, isDone: Bool) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone = isDone
            userDefaultsManager.saveTasks(tasks)
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
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                .overlay {
                                    Text(monthYearString(from: currentDate))
                                        .Stake(size: 22)
                                }
                                .frame(height: 44)
                                .padding(.horizontal)
                            
                            Rectangle()
                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                .overlay {
                                    HStack(spacing: cellSpacing) {
                                        ForEach(stakeTrackerModel.contact.arrayWeek.indices, id: \.self) { index in
                                            Text(stakeTrackerModel.contact.arrayWeek[index])
                                                .Stake(size: 14)
                                                .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 28)
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                                .frame(height: 28)
                                .padding(.horizontal)
                            
                            VStack(spacing: 15) {
                                ForEach(weeks.indices, id: \.self) { weekIndex in
                                    HStack(spacing: cellSpacing) {
                                        ForEach(0..<7, id: \.self) { dayIndex in
                                            if let date = weeks[weekIndex][dayIndex] {
                                                let isCurrentMonth = Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .month)
                                                let isToday = Calendar.current.isDateInToday(date)
                                                
                                                CalendarDayCell(
                                                    text: "\(Calendar.current.component(.day, from: date))",
                                                    isCurrentMonth: isCurrentMonth,
                                                    isToday: isToday,
                                                    date: date,
                                                    geometry: geometry,
                                                    isSelected: selectedDate == date
                                                )
                                                .onTapGesture {
                                                    selectedDate = date
                                                }
                                                .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 36)
                                            } else {
                                                Rectangle()
                                                    .fill(Color.clear)
                                                    .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 36)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            }
                            .padding(.top)
                        }
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                                .overlay {
                                    Text(monthYearString(from: previousMonthDate))
                                        .Stake(size: 22)
                                }
                                .frame(height: 44)
                                .padding(.horizontal)
                            
                            Rectangle()
                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                .overlay {
                                    HStack(spacing: cellSpacing) {
                                        ForEach(stakeTrackerModel.contact.arrayWeek.indices, id: \.self) { index in
                                            Text(stakeTrackerModel.contact.arrayWeek[index])
                                                .Stake(size: 14)
                                                .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 28)
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                                .frame(height: 28)
                                .padding(.horizontal)
                            
                            VStack(spacing: 15) {
                                ForEach(previousMonthWeeks.indices, id: \.self) { weekIndex in
                                    HStack(spacing: cellSpacing) {
                                        ForEach(0..<7, id: \.self) { dayIndex in
                                            if let date = previousMonthWeeks[weekIndex][dayIndex] {
                                                let isCurrentMonth = Calendar.current.isDate(date, equalTo: previousMonthDate, toGranularity: .month)
                                                let isToday = Calendar.current.isDateInToday(date)
                                                
                                                CalendarDayCell(
                                                    text: "\(Calendar.current.component(.day, from: date))",
                                                    isCurrentMonth: isCurrentMonth,
                                                    isToday: isToday,
                                                    date: date,
                                                    geometry: geometry
                                                )
                                                .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 36)
                                            } else {
                                                Rectangle()
                                                    .fill(Color.clear)
                                                    .frame(width: cellWidth(for: geometry.size.width, spacing: cellSpacing), height: 36)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    Color(.clear)
                        .frame(height: 20)
                }
                .padding(.top, setSize())
                
                //MARK: - panel
                VStack {
                    Spacer()
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 26/255, green: 44/255, blue: 57/255))
                            .frame(width: 120, height: 8)
                            .padding(.top, 15)
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 5) {
                                VStack {
                                           if isEditing {
                                               HStack {
                                                   Image(.plus2)
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
                                                           saveTask()
                                                       }
                                               }
                                               .padding(.horizontal)
                                           } else {
                                               Button(action: { isEditing.toggle() }) {
                                                   HStack {
                                                       Image(.plus2)
                                                           .resizable()
                                                           .frame(width: 24, height: 24)
                                                       
                                                       Text("New task")
                                                           .Stake(size: 18, color: Color(red: 128/255, green: 155/255, blue: 172/255))
                                                       
                                                       Spacer()
                                                   }
                                                   .frame(height: 34)
                                               }
                                               .disabled(!userDefaultsManager.checkLogin() ? true : false)
                                               .opacity(!userDefaultsManager.checkLogin() ? 0.5 : 1)
                                               .padding(.leading)
                                           }
                                       }
                                       .animation(.easeInOut(duration: 0.3), value: isEditing)
                            
                                Rectangle()
                                    .fill(Color(red: 128/255, green: 155/255, blue: 172/255))
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                            .padding(.top)
                            
                            VStack(spacing: 10) {
                                Rectangle()
                                    .fill(Color(red: 128/255, green: 155/255, blue: 172/255))
                                    .frame(height: 38)
                                    .overlay {
                                        HStack {
                                            Text("Planned:")
                                                .Stake(size: 20, color: Color(red: 26/255, green: 44/255, blue: 57/255))
                                                .padding(.leading, 10)
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal)
                                
                                ForEach(unDoneTasks.indices, id: \.self) { index in
                                    if let taskIndex = tasks.firstIndex(where: { $0.id == unDoneTasks[index].id }) {
                                        TaskView(task: tasks[taskIndex], color: Color(red: 26/255, green: 44/255, blue: 57/255)) {
                                            if userDefaultsManager.checkLogin() {
                                                moveToDone(task: unDoneTasks[index])
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 5)
                            
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
                                        TaskView(task: task, color: Color(red: 26/255, green: 44/255, blue: 57/255)) {
                                            if userDefaultsManager.checkLogin() {
                                                moveToDone(task: task)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }
                            
                            if !doneTasks.isEmpty {
                                VStack(spacing: 10) {
                                    Rectangle()
                                        .fill(Color(red: 128/255, green: 155/255, blue: 172/255))
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
                                    
                                    ForEach(doneTasks.indices, id: \.self) { index in
                                        TaskView(task: doneTasks[index], color: Color(red: 26/255, green: 44/255, blue: 57/255)) {
                                            if userDefaultsManager.checkLogin() {
                                                moveToPlanned(task: doneTasks[index])
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }
                            
                            Color(.clear)
                                .frame(height: 30)
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 10)
                    .frame(height: geometry.size.height * sheetHeightRatio)
                    .offset(y: sheetOffsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = sheetOffsetY + value.translation.height
                                if newOffset >= minOffsetY && newOffset <= maxOffsetY {
                                    sheetOffsetY = newOffset
                                }
                            }
                            .onEnded { value in
                                withAnimation {
                                    if sheetOffsetY < maxOffsetY * 0.5 {
                                        sheetOffsetY = minOffsetY
                                    } else {
                                        sheetOffsetY = maxOffsetY
                                    }
                                }
                            }
                    )
                }
                .ignoresSafeArea()
            }
            .onAppear {
                loadTasks()
                loadCategories()
            }
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    func generateWeeks(for date: Date) -> [[Date?]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = Array(repeating: nil, count: 7)
        var weekdayIndex = firstWeekday - 1
        var currentDate = monthInterval.start
        let endDate = monthInterval.end
        
        while currentDate < endDate {
            currentWeek[weekdayIndex] = currentDate
            
            weekdayIndex += 1
            if weekdayIndex == 7 {
                weeks.append(currentWeek)
                currentWeek = Array(repeating: nil, count: 7)
                weekdayIndex = 0
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        if currentWeek.contains(where: { $0 != nil }) {
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    func cellWidth(for totalWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        let horizontalPadding = totalWidth * 0.1
        let totalSpacing = spacing * 6
        return (totalWidth - horizontalPadding - totalSpacing) / 7
    }
}

struct StatisticView: View {
    @State var monthlyData: [MonthlyData] = []
    
    let data = [CircleDataModel(name: "Completed tasks",
                                color: LinearGradient(colors: [Color(red: 177/255, green: 237/255, blue: 113/255)], startPoint: .top, endPoint: .bottom),
                                count: 10),
                CircleDataModel(name: "To Do",
                                color: LinearGradient(colors: [Color(red: 43/255, green: 66/255, blue: 80/255)], startPoint: .top, endPoint: .bottom),
                                count: 5)]
    @State var pieChartData: [CircleDataModel] = []
    @State private var daysUsed = 0
    var maxValue: Double {
        monthlyData.map { $0.value }.max() ?? 1
    }
    
    private let userDefaultsManager = UserDefaultsManager()
    @State private var tasks: [TaskModel] = []
    @State private var categories: [CategoryModel] = []
    
    private func loadData() {
        tasks = userDefaultsManager.loadTasks()
        categories = userDefaultsManager.loadCategories()
    }
    
    private func prepareMonthlyData() {
        var dailyCounts = [Int: Double]()
        let calendar = Calendar.current
        
        guard let daysRange = calendar.range(of: .day, in: .month, for: Date()) else { return }
        let daysInMonth = daysRange.count
        
        
        for task in tasks {
            let day = calendar.component(.day, from: task.date)
            dailyCounts[day] = (dailyCounts[day] ?? 0) + 1
        }
        
        
        let sortedDays = dailyCounts.keys.sorted()
        var result = [MonthlyData]()
        var previousDay = 0
        
        for day in sortedDays {
            while (previousDay + 1) < day {
                result.append(MonthlyData(day: "\(previousDay + 1)", value: 0))
                previousDay += 1
            }
            
            result.append(MonthlyData(day: "\(day)", value: dailyCounts[day]!))
            previousDay = day
        }
        
        while previousDay < daysInMonth {
            result.append(MonthlyData(day: "\(previousDay + 1)", value: 0))
            previousDay += 1
        }
        
        self.monthlyData = result
    }
    
    private func generatePieChartData() -> [CircleDataModel] {
          var chartData: [CircleDataModel] = []

          chartData.append(CircleDataModel(
              name: "Completed tasks",
              color: LinearGradient(colors: [Color(red: 177/255, green: 237/255, blue: 113/255)],
                                   startPoint: .top, endPoint: .bottom),
              count: tasks.filter { $0.isDone }.count
          ))

          chartData.append(CircleDataModel(
              name: "To Do",
              color: LinearGradient(colors: [Color(red: 43/255, green: 66/255, blue: 80/255)],
                                   startPoint: .top, endPoint: .bottom),
              count: tasks.filter { !$0.isDone }.count
          ))

          for category in categories {
              chartData.append(CircleDataModel(
                  name: category.name,
                  color: LinearGradient(colors: [.blue, .purple],
                                      startPoint: .top, endPoint: .bottom),
                  count: tasks.filter { $0.categoryId == category.id }.count
              ))
          }

        return chartData
      }
    
    func setSize() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return 180
        } else if UIScreen.main.bounds.size.width > 700 {
            return 180
        } else if UIScreen.main.bounds.size.width < 390 {
            return 180
        } else {
            return 100
        }
    }
    
    func setSpacing() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return 21.5
        } else if UIScreen.main.bounds.size.width > 700 {
            return 14.5
        } else if UIScreen.main.bounds.size.width < 390 {
            return -0.5
        } else {
            return 0.4
        }
    }
    
    func setPadding() -> CGFloat {
        if UIScreen.main.bounds.size.width > 900 {
            return -490
        } else if UIScreen.main.bounds.size.width > 700 {
            return -380
        } else if UIScreen.main.bounds.size.width < 390 {
            return -170
        } else {
            return -175
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 40)
                            .overlay {
                                HStack {
                                    Text("Tasks:")
                                        .Stake(size: 20)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        
                        VStack {
                            VStack {
                                HStack {
                                    Text("Tasks created: \(tasks.count)")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                            
                            VStack {
                                HStack {
                                    Text("Tasks planned: \(tasks.filter { !$0.isDone }.count)")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                            
                            VStack {
                                HStack {
                                    Text("Tasks done: \(tasks.filter { $0.isDone }.count)")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                            
                            VStack {
                                HStack {
                                    Text("Categories created: \(categories.count)")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 5)
                        
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 40)
                            .overlay {
                                HStack {
                                    Text("Other:")
                                        .Stake(size: 20)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        
                        VStack {
                            VStack {
                                HStack {
                                    Text("Days you've been using the app: \(daysUsed)")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                            
                            VStack {
                                HStack {
                                    Text("How many games have been played: 2")
                                        .Stake(size: 16)
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(.white)
                                    .frame(height: 3)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 5)
                        
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 40)
                            .overlay {
                                HStack {
                                    Text("Productivity for the month:")
                                        .Stake(size: 20)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        
                        ZStack {
                            Image(.chartBack)
                                .resizable()
                                .frame(height: 200)
                                .padding(.horizontal, 40)
                                .overlay {
                                    GeometryReader { geo in
                                        VStack(alignment: .leading) {
                                            Spacer()
                                            HStack(alignment: .bottom, spacing: setSpacing()) {
                                                ForEach(monthlyData) { data in
                                                    VStack(spacing: 0) {
                                                        Text("\(Int(data.value))")
                                                            .Stake(size: 12)
                                                        
                                                        RoundedRectangle(cornerRadius: 0)
                                                            .fill(LinearGradient(colors: [Color.lightMain, Color.darkMain],
                                                                                 startPoint: .top,
                                                                                 endPoint: .bottom))
                                                            .frame(
                                                                width: 10.35,
                                                                height: CGFloat(data.value) / CGFloat(maxValue) * 80
                                                            )
                                                    }
                                                    .offset(y: 6)
                                                }
                                            }
                                            .frame(height: 90)
                                            
                                            Rectangle()
                                                .fill(Color(red: 14/255, green: 31/255, blue: 43/255))
                                                .frame(height: 32)
                                                .overlay {
                                                    GeometryReader { geo in
                                                        HStack(spacing: 0) {
                                                            ForEach(1..<31) { index in
                                                                Text("\(index)")
                                                                    .Stake(size: 10)
                                                                    .lineLimit(1)
                                                                    .minimumScaleFactor(0.5)
                                                                    .frame(width: geo.size.width / 30)
                                                                    .offset(y: 7)
                                                            }
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 40)
                                }
                                .overlay {
                                    ZStack {
                                        Image(.arrows)
                                            .resizable()
                                            .frame(height: 210)
                                            .offset(x: -5, y: 5)
                                        Text("Completed tasks")
                                            .Stake(size: 20)
                                            .rotationEffect(.degrees(270))
                                            .offset(x: setPadding())
                                        Text("Days")
                                            .Stake(size: 20)
                                            .offset(y: 120)
                                    }
                                    .padding(.horizontal, 37)
                                }
                        }
                        
                        Rectangle()
                            .fill(.darkMain)
                            .frame(height: 40)
                            .overlay {
                                HStack {
                                    Text("Productivity for the month:")
                                        .Stake(size: 20)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 30)
                        
                        
                        Image(.gradient)
                            .resizable()
                            .overlay {
                                HStack {
                                    PieChartView(data: pieChartData)
                                        .frame(width: 200, height: 200)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        ForEach(pieChartData.indices, id: \.self) { index in
                                            HStack {
                                                Circle()
                                                    .fill(pieChartData[index].color)
                                                    .frame(width: 22, height: 22)
                                                
                                                Text("\(pieChartData[index].name)")
                                                    .Stake(size: 18)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                            }
                                            .padding(.top)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 220)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .padding(.top, setSize())
        }
        .onAppear {
            loadData()
            daysUsed = userDefaultsManager.getDaysSinceFirstLaunch()
            prepareMonthlyData()
            let abc = generatePieChartData()
            pieChartData = abc
        }
    }
}

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var gradient: LinearGradient
    var name: String
}

struct PieSliceView: View {
    var pieSliceData: PieSliceData
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: width/2, y: width/2)
                
                path.move(to: center)
                path.addArc(center: center,
                            radius: width/2,
                            startAngle: pieSliceData.startAngle,
                            endAngle: pieSliceData.endAngle,
                            clockwise: false)
            }
            .fill(pieSliceData.gradient)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieChartView: View {
    var data: [CircleDataModel]
    
    var slices: [PieSliceData] {
        let total = data.reduce(0) { $0 + $1.count }
        var endAngle = 0.0
        var slices: [PieSliceData] = []
        
        for item in data {
            let degrees = Double(item.count) / Double(total) * 360
            let startAngle = Angle(degrees: endAngle)
            endAngle += degrees
            slices.append(PieSliceData(startAngle: startAngle,
                                       endAngle: Angle(degrees: endAngle),
                                       gradient: item.color,
                                       name: item.name))
        }
        return slices
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<slices.count, id: \.self) { i in
                PieSliceView(pieSliceData: slices[i])
            }
        }
    }
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let day: String
    var value: Double
}

struct CircleDataModel: Identifiable {
    let id = UUID()
    var name: String
    var color: LinearGradient
    var count: Int
}
