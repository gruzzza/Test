import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    func formatted() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func formattedShort() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let primaryGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let primaryOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let primaryPurple = Color(red: 0.69, green: 0.32, blue: 0.87)
    static let primaryRed = Color(red: 1.0, green: 0.23, blue: 0.19)
    
    static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let textSecondary = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color.backgroundGray)
            .foregroundColor(.primary)
            .cornerRadius(12)
            .font(.headline)
            .fontWeight(.medium)
    }
    
    func outlineButtonStyle() -> some View {
        self
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryBlue, lineWidth: 2)
            )
            .foregroundColor(.primaryBlue)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Array Extensions

extension Array where Element == Workout {
    func totalDuration() -> TimeInterval {
        return self.reduce(0) { $0 + $1.duration }
    }
    
    func totalCalories() -> Int {
        return self.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    func totalExercises() -> Int {
        return self.flatMap { $0.exercises }.count
    }
    
    func totalSets() -> Int {
        return self.flatMap { $0.exercises }.flatMap { $0.sets }.count
    }
    
    func averageDuration() -> TimeInterval {
        guard !self.isEmpty else { return 0 }
        return totalDuration() / Double(self.count)
    }
    
    func groupedByWeek() -> [Date: [Workout]] {
        let calendar = Calendar.current
        return Dictionary(grouping: self) { workout in
            calendar.startOfWeek(for: workout.date)
        }
    }
    
    func groupedByMonth() -> [Date: [Workout]] {
        let calendar = Calendar.current
        return Dictionary(grouping: self) { workout in
            calendar.startOfMonth(for: workout.date)
        }
    }
}

extension Array where Element == Exercise {
    func totalSets() -> Int {
        return self.flatMap { $0.sets }.count
    }
    
    func totalReps() -> Int {
        return self.flatMap { $0.sets }.reduce(0) { $0 + $1.reps }
    }
    
    func totalWeight() -> Double {
        return self.flatMap { $0.sets }.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    func byMuscleGroup() -> [MuscleGroup: [Exercise]] {
        return Dictionary(grouping: self) { exercise in
            exercise.muscleGroups.first ?? .fullBody
        }
    }
}

// MARK: - String Extensions

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// MARK: - Double Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func formatted(decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}

// MARK: - Int Extensions

extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func daysBetween(_ start: Date, and end: Date) -> Int {
        let components = dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
    
    func weeksBetween(_ start: Date, and end: Date) -> Int {
        let components = dateComponents([.weekOfYear], from: start, to: end)
        return components.weekOfYear ?? 0
    }
    
    func monthsBetween(_ start: Date, and end: Date) -> Int {
        let components = dateComponents([.month], from: start, to: end)
        return components.month ?? 0
    }
}