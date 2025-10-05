import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
        case all = "Все время"
    }
    
    var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return workoutManager.workouts.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return workoutManager.workouts.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return workoutManager.workouts.filter { $0.date >= yearAgo }
        case .all:
            return workoutManager.workouts
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Селектор периода
                    Picker("Период", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if filteredWorkouts.isEmpty {
                        EmptyStatisticsView()
                    } else {
                        // Общая статистика
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Общая статистика")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatCard(
                                    title: "Тренировок",
                                    value: "\(filteredWorkouts.count)",
                                    icon: "dumbbell.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Упражнений",
                                    value: "\(filteredWorkouts.flatMap { $0.exercises }.count)",
                                    icon: "list.bullet",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Время",
                                    value: formatDuration(filteredWorkouts.reduce(0) { $0 + $1.duration }),
                                    icon: "clock.fill",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "Подходов",
                                    value: "\(filteredWorkouts.flatMap { $0.exercises }.flatMap { $0.sets }.count)",
                                    icon: "repeat",
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // График тренировок по дням
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Тренировки по дням")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            WorkoutChart(workouts: filteredWorkouts)
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                        
                        // Топ упражнений
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Популярные упражнения")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            TopExercisesView(workouts: filteredWorkouts)
                                .padding(.horizontal)
                        }
                        
                        // Прогресс по весам
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Прогресс по весам")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            WeightProgressView(workouts: filteredWorkouts)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Статистика")
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

struct WorkoutChart: View {
    let workouts: [Workout]
    
    var chartData: [WorkoutData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        
        return grouped.map { date, workouts in
            WorkoutData(
                date: date,
                count: workouts.count,
                duration: workouts.reduce(0) { $0 + $1.duration }
            )
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart(chartData) { data in
            BarMark(
                x: .value("Дата", data.date, unit: .day),
                y: .value("Количество", data.count)
            )
            .foregroundStyle(.blue.gradient)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
}

struct WorkoutData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let duration: TimeInterval
}

struct TopExercisesView: View {
    let workouts: [Workout]
    
    var topExercises: [(String, Int)] {
        let exerciseCounts = Dictionary(grouping: workouts.flatMap { $0.exercises }) { $0.name }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(exerciseCounts.prefix(5))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(topExercises.enumerated()), id: \.offset) { index, exercise in
                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 20, alignment: .leading)
                    
                    Text(exercise.0)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(exercise.1)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WeightProgressView: View {
    let workouts: [Workout]
    
    var weightData: [WeightData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        
        return grouped.map { date, workouts in
            let totalWeight = workouts.flatMap { $0.exercises }
                .flatMap { $0.sets }
                .reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            
            return WeightData(
                date: date,
                weight: totalWeight
            )
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart(weightData) { data in
            LineMark(
                x: .value("Дата", data.date, unit: .day),
                y: .value("Вес", data.weight)
            )
            .foregroundStyle(.green.gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .frame(height: 150)
    }
}

struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct EmptyStatisticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет данных")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Начните тренироваться, чтобы увидеть статистику")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(WorkoutManager())
}