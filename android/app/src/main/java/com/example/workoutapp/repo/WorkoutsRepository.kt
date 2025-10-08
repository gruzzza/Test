package com.example.workoutapp.repo

import com.example.workoutapp.model.Workout
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object WorkoutsRepository {
    private val _workouts = MutableStateFlow(
        listOf(
            Workout(id = "hiit", name = "HIIT 20/10", rounds = 8, workMs = 20_000, restMs = 10_000),
            Workout(id = "tabata", name = "Tabata 20/10", rounds = 8, workMs = 20_000, restMs = 10_000),
            Workout(id = "emom", name = "EMOM 60/0", rounds = 10, workMs = 60_000, restMs = 0)
        )
    )

    fun getWorkouts(): Flow<List<Workout>> = _workouts.asStateFlow()

    fun getById(id: String): Workout? = _workouts.value.firstOrNull { it.id == id }
}
