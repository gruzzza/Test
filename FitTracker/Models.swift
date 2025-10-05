import Foundation
import SwiftUI

// MARK: - Core Models

struct Workout: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
    var date: Date
    var duration: TimeInterval
    var notes: String?
    var category: WorkoutCategory
    var difficulty: Difficulty
    var isCompleted: Bool = false
    var caloriesBurned: Int = 0
    var heartRate: [HeartRateData] = []
    
    init(name: String, exercises: [Exercise] = [], date: Date = Date(), duration: TimeInterval = 0, notes: String? = nil, category: WorkoutCategory = .strength, difficulty: Difficulty = .beginner) {
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
        self.notes = notes
        self.category = category
        self.difficulty = difficulty
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet]
    var restTime: TimeInterval
    var notes: String?
    var category: ExerciseCategory
    var muscleGroups: [MuscleGroup]
    var equipment: Equipment?
    var instructions: [String] = []
    var videoURL: String?
    var imageURL: String?
    
    init(name: String, sets: [ExerciseSet] = [], restTime: TimeInterval = 60, notes: String? = nil, category: ExerciseCategory = .strength, muscleGroups: [MuscleGroup] = [], equipment: Equipment? = nil) {
        self.name = name
        self.sets = sets
        self.restTime = restTime
        self.notes = notes
        self.category = category
        self.muscleGroups = muscleGroups
        self.equipment = equipment
    }
}

struct ExerciseSet: Identifiable, Codable, Hashable {
    let id = UUID()
    var reps: Int
    var weight: Double
    var duration: TimeInterval?
    var distance: Double?
    var calories: Int?
    var completed: Bool = false
    var restTime: TimeInterval?
    var notes: String?
    var timestamp: Date = Date()
    
    init(reps: Int = 0, weight: Double = 0, duration: TimeInterval? = nil, distance: Double? = nil, calories: Int? = nil, completed: Bool = false, restTime: TimeInterval? = nil, notes: String? = nil) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.distance = distance
        self.calories = calories
        self.completed = completed
        self.restTime = restTime
        self.notes = notes
    }
}

// MARK: - Enums

enum WorkoutCategory: String, CaseIterable, Codable {
    case strength = "Силовые"
    case cardio = "Кардио"
    case flexibility = "Гибкость"
    case sports = "Спорт"
    case yoga = "Йога"
    case pilates = "Пилатес"
    case crossfit = "Кроссфит"
    case martialArts = "Боевые искусства"
    case other = "Другое"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .sports: return "sportscourt.fill"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        case .crossfit: return "figure.strengthtraining.traditional"
        case .martialArts: return "figure.martial.arts"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .blue
        case .cardio: return .red
        case .flexibility: return .purple
        case .sports: return .green
        case .yoga: return .orange
        case .pilates: return .pink
        case .crossfit: return .yellow
        case .martialArts: return .brown
        case .other: return .gray
        }
    }
}

enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "Силовые"
    case cardio = "Кардио"
    case flexibility = "Гибкость"
    case balance = "Баланс"
    case endurance = "Выносливость"
    case power = "Мощность"
    case speed = "Скорость"
    case agility = "Ловкость"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .balance: return "figure.balance"
        case .endurance: return "timer"
        case .power: return "bolt.fill"
        case .speed: return "speedometer"
        case .agility: return "arrow.triangle.2.circlepath"
        }
    }
}

enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "Грудь"
    case back = "Спина"
    case shoulders = "Плечи"
    case biceps = "Бицепс"
    case triceps = "Трицепс"
    case forearms = "Предплечья"
    case abs = "Пресс"
    case obliques = "Косые мышцы"
    case lowerBack = "Поясница"
    case glutes = "Ягодицы"
    case quadriceps = "Квадрицепс"
    case hamstrings = "Бицепс бедра"
    case calves = "Икры"
    case fullBody = "Все тело"
    
    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.arms.open"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.arms.open"
        case .triceps: return "figure.arms.open"
        case .forearms: return "figure.arms.open"
        case .abs: return "figure.core.training"
        case .obliques: return "figure.core.training"
        case .lowerBack: return "figure.core.training"
        case .glutes: return "figure.legs"
        case .quadriceps: return "figure.legs"
        case .hamstrings: return "figure.legs"
        case .calves: return "figure.legs"
        case .fullBody: return "figure.all"
        }
    }
}

enum Equipment: String, CaseIterable, Codable {
    case none = "Без оборудования"
    case dumbbells = "Гантели"
    case barbell = "Штанга"
    case kettlebell = "Гиря"
    case resistanceBand = "Эспандер"
    case pullUpBar = "Турник"
    case bench = "Скамья"
    case machine = "Тренажер"
    case cable = "Трос"
    case medicineBall = "Медбол"
    case yogaMat = "Коврик для йоги"
    case jumpRope = "Скакалка"
    case treadmill = "Беговая дорожка"
    case bike = "Велосипед"
    case rowingMachine = "Гребной тренажер"
    
    var icon: String {
        switch self {
        case .none: return "figure.walk"
        case .dumbbells: return "dumbbell.fill"
        case .barbell: return "dumbbell.fill"
        case .kettlebell: return "dumbbell.fill"
        case .resistanceBand: return "bandage.fill"
        case .pullUpBar: return "figure.pull"
        case .bench: return "rectangle.fill"
        case .machine: return "gear"
        case .cable: return "cable.connector"
        case .medicineBall: return "circle.fill"
        case .yogaMat: return "rectangle.fill"
        case .jumpRope: return "figure.jumprope"
        case .treadmill: return "figure.run"
        case .bike: return "bicycle"
        case .rowingMachine: return "figure.rowing"
        }
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Начинающий"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
    case expert = "Эксперт"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .orange
        case .expert: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        case .expert: return "4.circle.fill"
        }
    }
}

// MARK: - Supporting Models

struct HeartRateData: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Int
    let zone: HeartRateZone
    
    init(timestamp: Date = Date(), heartRate: Int, zone: HeartRateZone) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.zone = zone
    }
}

enum HeartRateZone: String, CaseIterable, Codable {
    case recovery = "Восстановление"
    case aerobic = "Аэробная"
    case threshold = "Пороговая"
    case anaerobic = "Анаэробная"
    case neuromuscular = "Нервно-мышечная"
    
    var color: Color {
        switch self {
        case .recovery: return .blue
        case .aerobic: return .green
        case .threshold: return .yellow
        case .anaerobic: return .orange
        case .neuromuscular: return .red
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .recovery: return 50...60
        case .aerobic: return 60...70
        case .threshold: return 70...80
        case .anaerobic: return 80...90
        case .neuromuscular: return 90...100
        }
    }
}

struct WorkoutPlan: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var workouts: [Workout]
    var duration: Int // в неделях
    var difficulty: Difficulty
    var category: WorkoutCategory
    var isActive: Bool = false
    var startDate: Date?
    var endDate: Date?
    var progress: Double = 0.0
    
    init(name: String, description: String, workouts: [Workout] = [], duration: Int = 4, difficulty: Difficulty = .beginner, category: WorkoutCategory = .strength) {
        self.name = name
        self.description = description
        self.workouts = workouts
        self.duration = duration
        self.difficulty = difficulty
        self.category = category
    }
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: String
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Double = 0.0
    var target: Double
    var category: AchievementCategory
    
    init(title: String, description: String, icon: String, color: String, target: Double, category: AchievementCategory) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.target = target
        self.category = category
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case workout = "Тренировки"
    case exercise = "Упражнения"
    case time = "Время"
    case weight = "Вес"
    case consistency = "Постоянство"
    case social = "Социальные"
    
    var icon: String {
        switch self {
        case .workout: return "dumbbell.fill"
        case .exercise: return "list.bullet"
        case .time: return "clock.fill"
        case .weight: return "scalemass.fill"
        case .consistency: return "calendar"
        case .social: return "person.2.fill"
        }
    }
}

struct UserProfile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var age: Int
    var weight: Double
    var height: Double
    var fitnessLevel: Difficulty
    var goals: [FitnessGoal]
    var joinDate: Date = Date()
    var avatar: String?
    var bio: String?
    
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    init(name: String, age: Int, weight: Double, height: Double, fitnessLevel: Difficulty = .beginner, goals: [FitnessGoal] = []) {
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.fitnessLevel = fitnessLevel
        self.goals = goals
    }
}

enum FitnessGoal: String, CaseIterable, Codable {
    case weightLoss = "Похудение"
    case muscleGain = "Набор мышечной массы"
    case strength = "Увеличение силы"
    case endurance = "Выносливость"
    case flexibility = "Гибкость"
    case generalFitness = "Общая физическая форма"
    case sportsPerformance = "Спортивные результаты"
    case rehabilitation = "Реабилитация"
    
    var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle.fill"
        case .muscleGain: return "arrow.up.circle.fill"
        case .strength: return "dumbbell.fill"
        case .endurance: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .generalFitness: return "figure.all"
        case .sportsPerformance: return "trophy.fill"
        case .rehabilitation: return "cross.fill"
        }
    }
}