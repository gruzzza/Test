import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let workout: Workout
    @State private var showingEditWorkout = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(workout.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(formatDuration(workout.duration), systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = workout.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                
                // Статистика
                VStack(alignment: .leading, spacing: 12) {
                    Text("Статистика")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatisticCard(
                            title: "Упражнений",
                            value: "\(workout.exercises.count)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        
                        StatisticCard(
                            title: "Подходов",
                            value: "\(workout.exercises.flatMap { $0.sets }.count)",
                            icon: "repeat",
                            color: .green
                        )
                        
                        StatisticCard(
                            title: "Повторений",
                            value: "\(workout.exercises.flatMap { $0.sets }.reduce(0) { $0 + $1.reps })",
                            icon: "number",
                            color: .orange
                        )
                        
                        StatisticCard(
                            title: "Общий вес",
                            value: "\(Int(workout.exercises.flatMap { $0.sets }.reduce(0) { $0 + ($1.weight * Double($1.reps)) })) кг",
                            icon: "scalemass",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Упражнения
                VStack(alignment: .leading, spacing: 12) {
                    Text("Упражнения")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ForEach(workout.exercises) { exercise in
                        ExerciseDetailCard(exercise: exercise)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Тренировка")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Редактировать") {
                    showingEditWorkout = true
                }
            }
        }
        .sheet(isPresented: $showingEditWorkout) {
            EditWorkoutView(workout: workout)
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

struct StatisticCard: View {
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

struct ExerciseDetailCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(exercise.sets.count) подходов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(exercise.sets) { set in
                    SetDetailRow(set: set)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Отдых: \(Int(exercise.restTime)) сек")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SetDetailRow: View {
    let set: ExerciseSet
    
    var body: some View {
        HStack {
            if set.reps > 0 {
                Text("\(set.reps) повторений")
                    .font(.subheadline)
            }
            
            if let duration = set.duration {
                Text("\(Int(duration)) сек")
                    .font(.subheadline)
            }
            
            Spacer()
            
            if set.weight > 0 {
                Text("\(Int(set.weight)) кг")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if set.completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct EditWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String
    @State private var notes: String
    @State private var exercises: [Exercise]
    
    let workout: Workout
    
    init(workout: Workout) {
        self.workout = workout
        self._workoutName = State(initialValue: workout.name)
        self._notes = State(initialValue: workout.notes ?? "")
        self._exercises = State(initialValue: workout.exercises)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о тренировке") {
                    TextField("Название тренировки", text: $workoutName)
                    TextField("Заметки", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Упражнения") {
                    ForEach(exercises) { exercise in
                        ExerciseRowView(exercise: exercise)
                    }
                    .onDelete(perform: deleteExercises)
                }
            }
            .navigationTitle("Редактировать тренировку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveWorkout()
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        let updatedWorkout = Workout(
            name: workoutName,
            exercises: exercises,
            date: workout.date,
            duration: workout.duration,
            notes: notes.isEmpty ? nil : notes
        )
        
        workoutManager.updateWorkout(updatedWorkout)
        dismiss()
    }
    
    private func deleteExercises(offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
}

#Preview {
    let sampleWorkout = Workout(
        name: "Тренировка груди",
        exercises: [
            Exercise(
                name: "Жим лежа",
                sets: [
                    ExerciseSet(reps: 12, weight: 60),
                    ExerciseSet(reps: 10, weight: 70),
                    ExerciseSet(reps: 8, weight: 80)
                ],
                restTime: 90
            ),
            Exercise(
                name: "Отжимания",
                sets: [
                    ExerciseSet(reps: 15, weight: 0),
                    ExerciseSet(reps: 12, weight: 0),
                    ExerciseSet(reps: 10, weight: 0)
                ],
                restTime: 60
            )
        ],
        date: Date(),
        duration: 3600,
        notes: "Отличная тренировка!"
    )
    
    WorkoutDetailView(workout: sampleWorkout)
        .environmentObject(WorkoutManager())
}