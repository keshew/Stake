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
