import SwiftUI

struct QuickStartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName = ""
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingCustomWorkout = false
    
    let templates = [
        WorkoutTemplate(
            name: "Быстрая тренировка",
            exercises: [
                "Отжимания",
                "Приседания",
                "Планка"
            ],
            duration: 15
        ),
        WorkoutTemplate(
            name: "Тренировка груди",
            exercises: [
                "Жим лежа",
                "Отжимания",
                "Разведение гантелей"
            ],
            duration: 30
        ),
        WorkoutTemplate(
            name: "Кардио",
            exercises: [
                "Бег на месте",
                "Прыжки",
                "Берпи"
            ],
            duration: 20
        ),
        WorkoutTemplate(
            name: "Тренировка ног",
            exercises: [
                "Приседания",
                "Выпады",
                "Подъемы на носки"
            ],
            duration: 25
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Быстрый старт")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Выберите готовый шаблон или создайте свою тренировку")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Поле для названия
                VStack(alignment: .leading, spacing: 8) {
                    Text("Название тренировки")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Введите название", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Шаблоны
                VStack(alignment: .leading, spacing: 12) {
                    Text("Готовые шаблоны")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(templates) { template in
                                TemplateCard(
                                    template: template,
                                    isSelected: selectedTemplate?.id == template.id
                                ) {
                                    selectedTemplate = template
                                    workoutName = template.name
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Кнопка создания кастомной тренировки
                Button(action: {
                    showingCustomWorkout = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Создать свою тренировку")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка начала
                Button(action: {
                    startWorkout()
                }) {
                    Text("Начать тренировку")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(workoutName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(workoutName.isEmpty)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Быстрый старт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCustomWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private func startWorkout() {
        let exercises = selectedTemplate?.exercises.map { exerciseName in
            Exercise(
                name: exerciseName,
                sets: [ExerciseSet(reps: 10, weight: 0)],
                restTime: 60
            )
        } ?? []
        
        let workout = Workout(
            name: workoutName,
            exercises: exercises,
            date: Date(),
            duration: 0
        )
        
        workoutManager.startWorkout(workout)
        dismiss()
    }
}

struct WorkoutTemplate: Identifiable {
    let id = UUID()
    let name: String
    let exercises: [String]
    let duration: Int // в минутах
}

struct TemplateCard: View {
    let template: WorkoutTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(template.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("\(template.exercises.count) упражнений")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("~\(template.duration) мин")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Нажмите для выбора")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(width: 150, height: 120)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .foregroundColor(isSelected ? .blue : .primary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    QuickStartView()
        .environmentObject(WorkoutManager())
}