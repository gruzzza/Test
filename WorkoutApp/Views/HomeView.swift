import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingQuickStart = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Приветствие
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Привет! 👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Готов к тренировке?")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Быстрый старт
                    VStack(spacing: 16) {
                        HStack {
                            Text("Быстрый старт")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        Button(action: {
                            showingQuickStart = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Начать тренировку")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Статистика
                    VStack(spacing: 16) {
                        HStack {
                            Text("Статистика")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatCard(
                                title: "Всего тренировок",
                                value: "\(workoutManager.getTotalWorkouts())",
                                icon: "dumbbell.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Упражнений",
                                value: "\(workoutManager.getTotalExercises())",
                                icon: "figure.strengthtraining.traditional",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Время тренировок",
                                value: formatDuration(workoutManager.getTotalDuration()),
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "На этой неделе",
                                value: "\(workoutManager.getWorkoutsThisWeek().count)",
                                icon: "calendar",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Последние тренировки
                    if !workoutManager.workouts.isEmpty {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Последние тренировки")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            ForEach(workoutManager.workouts.suffix(3).reversed()) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Тренировки")
            .sheet(isPresented: $showingQuickStart) {
                QuickStartView()
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(workout.exercises.count) упражнений")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(workout.duration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(workout.exercises.flatMap { $0.sets }.count) подходов")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutManager())
}