import Foundation

// MARK: - Workout Models

struct Workout: Identifiable, Codable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
    var date: Date
    var duration: TimeInterval
    var notes: String?
    
    init(name: String, exercises: [Exercise] = [], date: Date = Date(), duration: TimeInterval = 0, notes: String? = nil) {
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
        self.notes = notes
    }
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet]
    var restTime: TimeInterval
    var notes: String?
    
    init(name: String, sets: [ExerciseSet] = [], restTime: TimeInterval = 60, notes: String? = nil) {
        self.name = name
        self.sets = sets
        self.restTime = restTime
        self.notes = notes
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id = UUID()
    var reps: Int
    var weight: Double
    var duration: TimeInterval? // For time-based exercises
    var completed: Bool = false
    
    init(reps: Int, weight: Double = 0, duration: TimeInterval? = nil, completed: Bool = false) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.completed = completed
    }
}

// MARK: - Workout Categories

enum WorkoutCategory: String, CaseIterable, Codable {
    case strength = "Силовые"
    case cardio = "Кардио"
    case flexibility = "Гибкость"
    case sports = "Спорт"
    case other = "Другое"
    
    var icon: String {
        switch self {
        case .strength:
            return "dumbbell.fill"
        case .cardio:
            return "heart.fill"
        case .flexibility:
            return "figure.flexibility"
        case .sports:
            return "sportscourt.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Exercise Types

enum ExerciseType: String, CaseIterable, Codable {
    case reps = "Повторы"
    case time = "Время"
    case distance = "Дистанция"
    case weight = "Вес"
    
    var icon: String {
        switch self {
        case .reps:
            return "repeat"
        case .time:
            return "clock.fill"
        case .distance:
            return "location.fill"
        case .weight:
            return "scalemass.fill"
        }
    }
}