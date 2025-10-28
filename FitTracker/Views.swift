import SwiftUI
import Charts

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var achievementManager: AchievementManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Тренировки")
                }
                .tag(1)
            
            CreateWorkoutView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Создать")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(4)
        }
        .accentColor(.primaryBlue)
        .onAppear {
            achievementManager.checkAchievements(workoutManager: workoutManager)
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var showingQuickStart = false
    @State private var showingWorkoutPlans = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    WelcomeSection()
                    
                    // Quick Actions
                    QuickActionsSection(showingQuickStart: $showingQuickStart, showingWorkoutPlans: $showingWorkoutPlans)
                    
                    // Active Workout
                    if workoutManager.isWorkoutActive, let workout = workoutManager.currentWorkout {
                        ActiveWorkoutCard(workout: workout)
                    }
                    
                    // Statistics Cards
                    StatisticsSection()
                    
                    // Recent Workouts
                    RecentWorkoutsSection()
                    
                    // Achievements
                    AchievementsSection()
                }
                .padding()
            }
            .navigationTitle("FitTracker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingQuickStart) {
                QuickStartView()
            }
            .sheet(isPresented: $showingWorkoutPlans) {
                WorkoutPlansView()
            }
        }
    }
}

// MARK: - Welcome Section

struct WelcomeSection: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Привет! 👋")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Готов к тренировке?")
                        .font(.title2)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let profile = workoutManager.userProfile {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(profile.name.prefix(1)).uppercased())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryBlue)
                        )
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    @Binding var showingQuickStart: Bool
    @Binding var showingWorkoutPlans: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: { showingQuickStart = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.primaryBlue)
                        Text("Быстрый старт")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBlue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: { showingWorkoutPlans = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.title)
                            .foregroundColor(.primaryGreen)
                        Text("Планы тренировок")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Active Workout Card

struct ActiveWorkoutCard: View {
    let workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Активная тренировка")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Завершить") {
                    workoutManager.endWorkout()
                }
                .font(.caption)
                .foregroundColor(.primaryBlue)
            }
            
            Text(workout.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Label("\(workout.exercises.count) упражнений", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Label(timerManager.formattedTime, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView(value: workoutProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
        }
        .cardStyle()
    }
    
    private var workoutProgress: Double {
        let totalSets = workout.exercises.flatMap { $0.sets }.count
        let completedSets = workout.exercises.flatMap { $0.sets }.filter { $0.completed }.count
        return totalSets > 0 ? Double(completedSets) / Double(totalSets) : 0
    }
}

// MARK: - Statistics Section

struct StatisticsSection: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Тренировок",
                    value: "\(workoutManager.getTotalWorkouts())",
                    icon: "dumbbell.fill",
                    color: .primaryBlue
                )
                
                StatCard(
                    title: "Упражнений",
                    value: "\(workoutManager.getTotalExercises())",
                    icon: "list.bullet",
                    color: .primaryGreen
                )
                
                StatCard(
                    title: "Время",
                    value: workoutManager.getTotalDuration().formattedShort(),
                    icon: "clock.fill",
                    color: .primaryOrange
                )
                
                StatCard(
                    title: "Калории",
                    value: "\(workoutManager.getTotalCaloriesBurned())",
                    icon: "flame.fill",
                    color: .primaryRed
                )
            }
        }
    }
}

// MARK: - Stat Card

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
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Recent Workouts Section

struct RecentWorkoutsSection: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var recentWorkouts: [Workout] {
        Array(workoutManager.workouts.suffix(3).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Последние тренировки")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("Все") {
                    WorkoutListView()
                }
                .font(.caption)
                .foregroundColor(.primaryBlue)
            }
            
            if recentWorkouts.isEmpty {
                EmptyStateView(
                    icon: "dumbbell",
                    title: "Нет тренировок",
                    description: "Создайте свою первую тренировку"
                )
            } else {
                ForEach(recentWorkouts) { workout in
                    WorkoutCard(workout: workout)
                }
            }
        }
    }
}

// MARK: - Workout Card

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(workout.exercises.count) упражнений")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text(workout.date.formatted(style: .short))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(workout.duration.formattedShort())
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(workout.exercises.flatMap { $0.sets }.count) подходов")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: workout.category.icon)
                        .font(.caption)
                    Text(workout.category.rawValue)
                        .font(.caption)
                }
                .foregroundColor(workout.category.color)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Achievements Section

struct AchievementsSection: View {
    @EnvironmentObject var achievementManager: AchievementManager
    
    var recentAchievements: [Achievement] {
        Array(achievementManager.unlockedAchievements.suffix(3).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Достижения")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("Все") {
                    AchievementsView()
                }
                .font(.caption)
                .foregroundColor(.primaryBlue)
            }
            
            if recentAchievements.isEmpty {
                EmptyStateView(
                    icon: "trophy",
                    title: "Нет достижений",
                    description: "Начните тренироваться для получения достижений"
                )
            } else {
                ForEach(recentAchievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(Color(hex: achievement.color))
                .frame(width: 40, height: 40)
                .background(Color(hex: achievement.color).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.primaryGreen)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Workout List View

struct WorkoutListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var searchText = ""
    @State private var selectedCategory: WorkoutCategory?
    @State private var showingCreateWorkout = false
    
    var filteredWorkouts: [Workout] {
        var workouts = workoutManager.workouts.sorted { $0.date > $1.date }
        
        if !searchText.isEmpty {
            workouts = workouts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory {
            workouts = workouts.filter { $0.category == category }
        }
        
        return workouts
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "Все",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(WorkoutCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if filteredWorkouts.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "Тренировки не найдены",
                        description: "Попробуйте изменить фильтры или создать новую тренировку"
                    )
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutCard(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Тренировки")
            .searchable(text: $searchText, prompt: "Поиск тренировок")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWorkout = true }) {
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

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.primaryBlue : Color.backgroundGray)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Placeholder Views (to be implemented)

struct CreateWorkoutView: View {
    var body: some View {
        Text("Create Workout View")
            .navigationTitle("Создать тренировку")
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        Text("Workout Detail View")
            .navigationTitle(workout.name)
    }
}

struct StatisticsView: View {
    var body: some View {
        Text("Statistics View")
            .navigationTitle("Статистика")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
            .navigationTitle("Профиль")
    }
}

struct QuickStartView: View {
    var body: some View {
        Text("Quick Start View")
            .navigationTitle("Быстрый старт")
    }
}

struct WorkoutPlansView: View {
    var body: some View {
        Text("Workout Plans View")
            .navigationTitle("Планы тренировок")
    }
}

struct AchievementsView: View {
    var body: some View {
        Text("Achievements View")
            .navigationTitle("Достижения")
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
        .environmentObject(AchievementManager())
        .environmentObject(TimerManager())
}