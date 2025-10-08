package com.example.workoutapp

import androidx.compose.runtime.Composable
import androidx.navigation.compose.rememberNavController
import com.example.workoutapp.navigation.AppNavHost

@Composable
fun WorkoutApp() {
    val navController = rememberNavController()
    AppNavHost(navController)
}
