import Foundation
import Combine

// MARK: - Data Service

class DataService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let workouts = "saved_workouts"
        static let workoutPlans = "saved_workout_plans"
        static let achievements = "saved_achievements"
        static let userProfile = "saved_user_profile"
    }
    
    // MARK: - Workouts
    
    func saveWorkouts(_ workouts: [Workout]) {
        if let encoded = try? JSONEncoder().encode(workouts) {
            userDefaults.set(encoded, forKey: Keys.workouts)
        }
    }
    
    func loadWorkouts(completion: @escaping ([Workout]) -> Void) {
        if let data = userDefaults.data(forKey: Keys.workouts),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            completion(decoded)
        } else {
            completion([])
        }
    }
    
    // MARK: - Workout Plans
    
    func saveWorkoutPlans(_ plans: [WorkoutPlan]) {
        if let encoded = try? JSONEncoder().encode(plans) {
            userDefaults.set(encoded, forKey: Keys.workoutPlans)
        }
    }
    
    func loadWorkoutPlans(completion: @escaping ([WorkoutPlan]) -> Void) {
        if let data = userDefaults.data(forKey: Keys.workoutPlans),
           let decoded = try? JSONDecoder().decode([WorkoutPlan].self, from: data) {
            completion(decoded)
        } else {
            completion([])
        }
    }
    
    // MARK: - Achievements
    
    func saveAchievements(_ achievements: [Achievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: Keys.achievements)
        }
    }
    
    func loadAchievements(completion: @escaping ([Achievement]) -> Void) {
        if let data = userDefaults.data(forKey: Keys.achievements),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            completion(decoded)
        } else {
            completion([])
        }
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: Keys.userProfile)
        }
    }
    
    func loadUserProfile(completion: @escaping (UserProfile?) -> Void) {
        if let data = userDefaults.data(forKey: Keys.userProfile),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            completion(decoded)
        } else {
            completion(nil)
        }
    }
}

// MARK: - Health Service

class HealthService: ObservableObject {
    private let healthStore = HealthStore()
    
    func requestAuthorization() async throws {
        try await healthStore.requestAuthorization()
    }
    
    func saveWorkout(_ workout: Workout) async throws {
        try await healthStore.saveWorkout(workout)
    }
    
    func getHeartRateData(startDate: Date, endDate: Date) async throws -> [HeartRateData] {
        return try await healthStore.getHeartRateData(startDate: startDate, endDate: endDate)
    }
    
    func getCaloriesBurned(startDate: Date, endDate: Date) async throws -> Int {
        return try await healthStore.getCaloriesBurned(startDate: startDate, endDate: endDate)
    }
}

// MARK: - Health Store (Mock implementation)

class HealthStore {
    func requestAuthorization() async throws {
        // Mock implementation - в реальном приложении здесь будет работа с HealthKit
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
    }
    
    func saveWorkout(_ workout: Workout) async throws {
        // Mock implementation
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
    }
    
    func getHeartRateData(startDate: Date, endDate: Date) async throws -> [HeartRateData] {
        // Mock implementation - возвращаем тестовые данные
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let calendar = Calendar.current
        var heartRateData: [HeartRateData] = []
        
        var currentDate = startDate
        while currentDate <= endDate {
            let heartRate = Int.random(in: 60...180)
            let zone = determineHeartRateZone(heartRate)
            heartRateData.append(HeartRateData(heartRate: heartRate, zone: zone))
            currentDate = calendar.date(byAdding: .minute, value: 1, to: currentDate) ?? currentDate
        }
        
        return heartRateData
    }
    
    func getCaloriesBurned(startDate: Date, endDate: Date) async throws -> Int {
        // Mock implementation
        try await Task.sleep(nanoseconds: 300_000_000)
        return Int.random(in: 200...800)
    }
    
    private func determineHeartRateZone(_ heartRate: Int) -> HeartRateZone {
        let percentage = Double(heartRate) / 200.0 * 100 // Предполагаем максимальный пульс 200
        
        switch percentage {
        case 0...60: return .recovery
        case 60...70: return .aerobic
        case 70...80: return .threshold
        case 80...90: return .anaerobic
        default: return .neuromuscular
        }
    }
}

// MARK: - Notification Service

class NotificationService: ObservableObject {
    func requestPermission() async {
        // В реальном приложении здесь будет запрос разрешений на уведомления
    }
    
    func scheduleWorkoutReminder(title: String, body: String, date: Date) {
        // Mock implementation
    }
    
    func scheduleRestTimerNotification(duration: TimeInterval) {
        // Mock implementation
    }
}

// MARK: - Analytics Service

class AnalyticsService: ObservableObject {
    func trackWorkoutStarted(_ workout: Workout) {
        // Mock implementation - в реальном приложении здесь будет отправка аналитики
    }
    
    func trackWorkoutCompleted(_ workout: Workout) {
        // Mock implementation
    }
    
    func trackExerciseCompleted(_ exercise: Exercise) {
        // Mock implementation
    }
    
    func trackAchievementUnlocked(_ achievement: Achievement) {
        // Mock implementation
    }
}

// MARK: - Workout Template Service

class WorkoutTemplateService: ObservableObject {
    func getTemplates() -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(
                name: "Быстрая утренняя зарядка",
                description: "15-минутная тренировка для пробуждения",
                exercises: [
                    "Отжимания",
                    "Приседания",
                    "Планка",
                    "Выпады",
                    "Берпи"
                ],
                duration: 15,
                difficulty: .beginner,
                category: .strength
            ),
            WorkoutTemplate(
                name: "Интенсивная кардио",
                description: "30-минутная кардио тренировка",
                exercises: [
                    "Бег на месте",
                    "Прыжки",
                    "Берпи",
                    "Горный альпинист",
                    "Прыжки в стороны"
                ],
                duration: 30,
                difficulty: .intermediate,
                category: .cardio
            ),
            WorkoutTemplate(
                name: "Силовая тренировка",
                description: "45-минутная силовая тренировка",
                exercises: [
                    "Жим лежа",
                    "Приседания со штангой",
                    "Становая тяга",
                    "Подтягивания",
                    "Отжимания на брусьях"
                ],
                duration: 45,
                difficulty: .advanced,
                category: .strength
            ),
            WorkoutTemplate(
                name: "Йога для начинающих",
                description: "Расслабляющая йога сессия",
                exercises: [
                    "Поза горы",
                    "Поза воина",
                    "Поза дерева",
                    "Поза кошки-коровы",
                    "Поза ребенка"
                ],
                duration: 25,
                difficulty: .beginner,
                category: .yoga
            ),
            WorkoutTemplate(
                name: "HIIT тренировка",
                description: "Высокоинтенсивная интервальная тренировка",
                exercises: [
                    "Берпи",
                    "Прыжки",
                    "Горный альпинист",
                    "Приседания с прыжком",
                    "Планка"
                ],
                duration: 20,
                difficulty: .advanced,
                category: .cardio
            )
        ]
    }
}

struct WorkoutTemplate: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var exercises: [String]
    var duration: Int // в минутах
    var difficulty: Difficulty
    var category: WorkoutCategory
    var isPopular: Bool = false
    
    init(name: String, description: String, exercises: [String], duration: Int, difficulty: Difficulty, category: WorkoutCategory, isPopular: Bool = false) {
        self.name = name
        self.description = description
        self.exercises = exercises
        self.duration = duration
        self.difficulty = difficulty
        self.category = category
        self.isPopular = isPopular
    }
}