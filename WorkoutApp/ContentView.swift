import SwiftUI

struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главная страница
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            // Список тренировок
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Тренировки")
                }
                .tag(1)
            
            // Создание тренировки
            CreateWorkoutView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Создать")
                }
                .tag(2)
            
            // Статистика
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                }
                .tag(3)
        }
        .environmentObject(workoutManager)
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}