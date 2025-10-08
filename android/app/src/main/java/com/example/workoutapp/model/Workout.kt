package com.example.workoutapp.model

data class Workout(
    val id: String,
    val name: String,
    val rounds: Int,
    val workMs: Long,
    val restMs: Long
)