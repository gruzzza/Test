import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingCreateWorkout = false
    @State private var searchText = ""
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workoutManager.workouts.sorted { $0.date > $1.date }
        } else {
            return workoutManager.workouts
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if workoutManager.workouts.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutRowView(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                    .searchable(text: $searchText, prompt: "Поиск тренировок")
                }
            }
            .navigationTitle("Мои тренировки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        workoutManager.deleteWorkout(at: offsets)
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(workout.exercises.count) упражнений", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(formatDuration(workout.duration), systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет тренировок")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Создайте свою первую тренировку, чтобы начать отслеживать прогресс")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WorkoutListView()
        .environmentObject(WorkoutManager())
}