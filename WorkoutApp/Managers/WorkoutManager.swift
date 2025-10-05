import Foundation
import Combine

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentWorkout: Workout?
    @Published var isWorkoutActive = false
    
    private let userDefaults = UserDefaults.standard
    private let workoutsKey = "saved_workouts"
    
    init() {
        loadWorkouts()
    }
    
    // MARK: - Workout Management
    
    func startWorkout(_ workout: Workout) {
        currentWorkout = workout
        isWorkoutActive = true
    }
    
    func endWorkout() {
        if var workout = currentWorkout {
            workout.duration = Date().timeIntervalSince(workout.date)
            workouts.append(workout)
            saveWorkouts()
        }
        currentWorkout = nil
        isWorkoutActive = false
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        saveWorkouts()
    }
    
    func deleteWorkout(at indexSet: IndexSet) {
        workouts.remove(atOffsets: indexSet)
        saveWorkouts()
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    // MARK: - Exercise Management
    
    func addExercise(to workoutId: UUID, exercise: Exercise) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) {
            workouts[workoutIndex].exercises.append(exercise)
            saveWorkouts()
        }
        
        if currentWorkout?.id == workoutId {
            currentWorkout?.exercises.append(exercise)
        }
    }
    
    func updateExercise(in workoutId: UUID, exercise: Exercise) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            workouts[workoutIndex].exercises[exerciseIndex] = exercise
            saveWorkouts()
        }
        
        if currentWorkout?.id == workoutId,
           let exerciseIndex = currentWorkout?.exercises.firstIndex(where: { $0.id == exercise.id }) {
            currentWorkout?.exercises[exerciseIndex] = exercise
        }
    }
    
    func deleteExercise(from workoutId: UUID, at indexSet: IndexSet) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) {
            workouts[workoutIndex].exercises.remove(atOffsets: indexSet)
            saveWorkouts()
        }
        
        if currentWorkout?.id == workoutId {
            currentWorkout?.exercises.remove(atOffsets: indexSet)
        }
    }
    
    // MARK: - Set Management
    
    func addSet(to exerciseId: UUID, in workoutId: UUID, set: ExerciseSet) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId }) {
            workouts[workoutIndex].exercises[exerciseIndex].sets.append(set)
            saveWorkouts()
        }
        
        if currentWorkout?.id == workoutId,
           let exerciseIndex = currentWorkout?.exercises.firstIndex(where: { $0.id == exerciseId }) {
            currentWorkout?.exercises[exerciseIndex].sets.append(set)
        }
    }
    
    func updateSet(in exerciseId: UUID, in workoutId: UUID, set: ExerciseSet) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = workouts[workoutIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            workouts[workoutIndex].exercises[exerciseIndex].sets[setIndex] = set
            saveWorkouts()
        }
        
        if currentWorkout?.id == workoutId,
           let exerciseIndex = currentWorkout?.exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = currentWorkout?.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            currentWorkout?.exercises[exerciseIndex].sets[setIndex] = set
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            userDefaults.set(encoded, forKey: workoutsKey)
        }
    }
    
    private func loadWorkouts() {
        if let data = userDefaults.data(forKey: workoutsKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    
    // MARK: - Statistics
    
    func getTotalWorkouts() -> Int {
        return workouts.count
    }
    
    func getTotalExercises() -> Int {
        return workouts.flatMap { $0.exercises }.count
    }
    
    func getTotalDuration() -> TimeInterval {
        return workouts.reduce(0) { $0 + $1.duration }
    }
    
    func getWorkoutsThisWeek() -> [Workout] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        
        return workouts.filter { $0.date >= weekAgo }
    }
}