import SwiftUI

@main
struct FitTrackerApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .environmentObject(achievementManager)
                .environmentObject(timerManager)
                .preferredColorScheme(.light) // Можно изменить на .dark или убрать для автоматической темы
        }
    }
}