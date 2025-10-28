import Foundation
import SwiftUI
import Combine

// MARK: - Workout Manager

@MainActor
class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentWorkout: Workout?
    @Published var isWorkoutActive = false
    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var userProfile: UserProfile?
    
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService = DataService()) {
        self.dataService = dataService
        loadData()
    }
    
    // MARK: - Workout Management
    
    func startWorkout(_ workout: Workout) {
        currentWorkout = workout
        isWorkoutActive = true
    }
    
    func endWorkout() {
        guard var workout = currentWorkout else { return }
        
        workout.duration = Date().timeIntervalSince(workout.date)
        workout.isCompleted = true
        workouts.append(workout)
        
        saveData()
        currentWorkout = nil
        isWorkoutActive = false
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        saveData()
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveData()
        }
    }
    
    func deleteWorkout(at indexSet: IndexSet) {
        workouts.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Exercise Management
    
    func addExercise(to workoutId: UUID, exercise: Exercise) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) {
            workouts[workoutIndex].exercises.append(exercise)
            saveData()
        }
        
        if currentWorkout?.id == workoutId {
            currentWorkout?.exercises.append(exercise)
        }
    }
    
    func updateExercise(in workoutId: UUID, exercise: Exercise) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }),
           let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            workouts[workoutIndex].exercises[exerciseIndex] = exercise
            saveData()
        }
        
        if currentWorkout?.id == workoutId,
           let exerciseIndex = currentWorkout?.exercises.firstIndex(where: { $0.id == exercise.id }) {
            currentWorkout?.exercises[exerciseIndex] = exercise
        }
    }
    
    func deleteExercise(from workoutId: UUID, at indexSet: IndexSet) {
        if let workoutIndex = workouts.firstIndex(where: { $0.id == workoutId }) {
            workouts[workoutIndex].exercises.remove(atOffsets: indexSet)
            saveData()
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
            saveData()
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
            saveData()
        }
        
        if currentWorkout?.id == workoutId,
           let exerciseIndex = currentWorkout?.exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = currentWorkout?.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            currentWorkout?.exercises[exerciseIndex].sets[setIndex] = set
        }
    }
    
    // MARK: - Workout Plans
    
    func addWorkoutPlan(_ plan: WorkoutPlan) {
        workoutPlans.append(plan)
        saveData()
    }
    
    func updateWorkoutPlan(_ plan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans[index] = plan
            saveData()
        }
    }
    
    func deleteWorkoutPlan(at indexSet: IndexSet) {
        workoutPlans.remove(atOffsets: indexSet)
        saveData()
    }
    
    func activateWorkoutPlan(_ plan: WorkoutPlan) {
        // Деактивировать все планы
        for index in workoutPlans.indices {
            workoutPlans[index].isActive = false
        }
        
        // Активировать выбранный план
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans[index].isActive = true
            workoutPlans[index].startDate = Date()
            workoutPlans[index].endDate = Calendar.current.date(byAdding: .weekOfYear, value: plan.duration, to: Date())
        }
        
        saveData()
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
    
    func getWorkoutsThisMonth() -> [Workout] {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        return workouts.filter { $0.date >= monthAgo }
    }
    
    func getTotalCaloriesBurned() -> Int {
        return workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    func getAverageWorkoutDuration() -> TimeInterval {
        guard !workouts.isEmpty else { return 0 }
        return getTotalDuration() / Double(workouts.count)
    }
    
    func getMostUsedExercises(limit: Int = 5) -> [(String, Int)] {
        let exerciseCounts = Dictionary(grouping: workouts.flatMap { $0.exercises }) { $0.name }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(exerciseCounts.prefix(limit))
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        dataService.loadWorkouts { [weak self] workouts in
            self?.workouts = workouts
        }
        
        dataService.loadWorkoutPlans { [weak self] plans in
            self?.workoutPlans = plans
        }
        
        dataService.loadUserProfile { [weak self] profile in
            self?.userProfile = profile
        }
    }
    
    private func saveData() {
        dataService.saveWorkouts(workouts)
        dataService.saveWorkoutPlans(workoutPlans)
        if let profile = userProfile {
            dataService.saveUserProfile(profile)
        }
    }
}

// MARK: - Achievement Manager

@MainActor
class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var unlockedAchievements: [Achievement] = []
    
    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService = DataService()) {
        self.dataService = dataService
        loadAchievements()
        createDefaultAchievements()
    }
    
    func checkAchievements(workoutManager: WorkoutManager) {
        let totalWorkouts = workoutManager.getTotalWorkouts()
        let totalExercises = workoutManager.getTotalExercises()
        let totalDuration = workoutManager.getTotalDuration()
        let totalCalories = workoutManager.getTotalCaloriesBurned()
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            if !achievement.isUnlocked {
                let progress = calculateProgress(for: achievement, workoutManager: workoutManager)
                achievement.progress = progress
                
                if progress >= 1.0 {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                    unlockedAchievements.append(achievement)
                }
                
                achievements[index] = achievement
            }
        }
        
        saveAchievements()
    }
    
    private func calculateProgress(for achievement: Achievement, workoutManager: WorkoutManager) -> Double {
        switch achievement.category {
        case .workout:
            return min(Double(workoutManager.getTotalWorkouts()) / achievement.target, 1.0)
        case .exercise:
            return min(Double(workoutManager.getTotalExercises()) / achievement.target, 1.0)
        case .time:
            return min(workoutManager.getTotalDuration() / (achievement.target * 3600), 1.0) // target в часах
        case .weight:
            return min(Double(workoutManager.getTotalCaloriesBurned()) / achievement.target, 1.0)
        case .consistency:
            let weeklyWorkouts = workoutManager.getWorkoutsThisWeek().count
            return min(Double(weeklyWorkouts) / achievement.target, 1.0)
        case .social:
            return 0.0 // Пока не реализовано
        }
    }
    
    private func createDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(title: "Первая тренировка", description: "Завершите свою первую тренировку", icon: "dumbbell.fill", color: "blue", target: 1, category: .workout),
                Achievement(title: "Неделя тренировок", description: "Тренируйтесь 7 дней подряд", icon: "calendar", color: "green", target: 7, category: .consistency),
                Achievement(title: "10 тренировок", description: "Завершите 10 тренировок", icon: "10.circle.fill", color: "orange", target: 10, category: .workout),
                Achievement(title: "50 упражнений", description: "Выполните 50 упражнений", icon: "list.bullet", color: "purple", target: 50, category: .exercise),
                Achievement(title: "10 часов тренировок", description: "Потратьте 10 часов на тренировки", icon: "clock.fill", color: "red", target: 10, category: .time),
                Achievement(title: "1000 калорий", description: "Сожгите 1000 калорий", icon: "flame.fill", color: "yellow", target: 1000, category: .weight)
            ]
        }
    }
    
    private func loadAchievements() {
        dataService.loadAchievements { [weak self] achievements in
            self?.achievements = achievements
            self?.unlockedAchievements = achievements.filter { $0.isUnlocked }
        }
    }
    
    private func saveAchievements() {
        dataService.saveAchievements(achievements)
    }
}

// MARK: - Timer Manager

@MainActor
class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentPhase: TimerPhase = .work
    
    private var timer: Timer?
    private var startTime: Date?
    
    enum TimerPhase {
        case work
        case rest
        case preparation
    }
    
    func startTimer(duration: TimeInterval, phase: TimerPhase = .work) {
        stopTimer()
        
        timeRemaining = duration
        currentPhase = phase
        isRunning = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = 0
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resumeTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        timeRemaining = max(0, timeRemaining - elapsed)
        
        if timeRemaining <= 0 {
            stopTimer()
            // Здесь можно добавить уведомление о завершении
        }
        
        self.startTime = Date()
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}