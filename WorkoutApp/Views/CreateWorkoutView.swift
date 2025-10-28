import SwiftUI

struct CreateWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName = ""
    @State private var notes = ""
    @State private var exercises: [Exercise] = []
    @State private var showingAddExercise = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о тренировке") {
                    TextField("Название тренировки", text: $workoutName)
                    TextField("Заметки (необязательно)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Упражнения") {
                    if exercises.isEmpty {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("Добавить упражнение")
                                .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            showingAddExercise = true
                        }
                    } else {
                        ForEach(exercises) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .onDelete(perform: deleteExercises)
                        
                        Button(action: {
                            showingAddExercise = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Добавить упражнение")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая тренировка")
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
                    .disabled(workoutName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView { exercise in
                    exercises.append(exercise)
                }
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            exercises: exercises,
            date: Date(),
            duration: 0,
            notes: notes.isEmpty ? nil : notes
        )
        
        workoutManager.addWorkout(workout)
        dismiss()
    }
    
    private func deleteExercises(offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("\(exercise.sets.count) подходов")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var sets: [ExerciseSet] = []
    @State private var restTime: TimeInterval = 60
    @State private var notes = ""
    @State private var showingAddSet = false
    
    let onSave: (Exercise) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация об упражнении") {
                    TextField("Название упражнения", text: $exerciseName)
                    
                    HStack {
                        Text("Время отдыха")
                        Spacer()
                        Text("\(Int(restTime)) сек")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $restTime, in: 0...300, step: 15)
                    
                    TextField("Заметки (необязательно)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Подходы") {
                    if sets.isEmpty {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("Добавить подход")
                                .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            showingAddSet = true
                        }
                    } else {
                        ForEach(sets) { set in
                            SetRowView(set: set)
                        }
                        .onDelete(perform: deleteSets)
                        
                        Button(action: {
                            showingAddSet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Добавить подход")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новое упражнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        saveExercise()
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddSet) {
                AddSetView { set in
                    sets.append(set)
                }
            }
        }
    }
    
    private func saveExercise() {
        let exercise = Exercise(
            name: exerciseName,
            sets: sets,
            restTime: restTime,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave(exercise)
        dismiss()
    }
    
    private func deleteSets(offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
}

struct SetRowView: View {
    let set: ExerciseSet
    
    var body: some View {
        HStack {
            Text("Подход \(set.reps) повторений")
                .font(.subheadline)
            
            Spacer()
            
            if set.weight > 0 {
                Text("\(Int(set.weight)) кг")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let duration = set.duration {
                Text("\(Int(duration)) сек")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var reps = 10
    @State private var weight = 0.0
    @State private var duration: TimeInterval = 0
    @State private var isTimeBased = false
    
    let onSave: (ExerciseSet) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Тип упражнения") {
                    Picker("Тип", selection: $isTimeBased) {
                        Text("Повторы").tag(false)
                        Text("Время").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if isTimeBased {
                    Section("Время") {
                        HStack {
                            Text("Длительность")
                            Spacer()
                            Text("\(Int(duration)) сек")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $duration, in: 1...600, step: 1)
                    }
                } else {
                    Section("Повторы") {
                        Stepper("Повторы: \(reps)", value: $reps, in: 1...100)
                    }
                }
                
                Section("Вес") {
                    HStack {
                        Text("Вес")
                        Spacer()
                        TextField("0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("кг")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Новый подход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        saveSet()
                    }
                }
            }
        }
    }
    
    private func saveSet() {
        let set = ExerciseSet(
            reps: isTimeBased ? 0 : reps,
            weight: weight,
            duration: isTimeBased ? duration : nil
        )
        
        onSave(set)
        dismiss()
    }
}

#Preview {
    CreateWorkoutView()
        .environmentObject(WorkoutManager())
}