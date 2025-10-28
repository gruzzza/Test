import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Тренировки")
                }
                .tag(1)
            
            CreateWorkoutView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Создать")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(4)
        }
        .accentColor(.primaryBlue)
        .onAppear {
            achievementManager.checkAchievements(workoutManager: workoutManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
        .environmentObject(AchievementManager())
        .environmentObject(TimerManager())
}