package com.example.workoutapp.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import androidx.navigation.NavType
import com.example.workoutapp.ui.screens.WorkoutDetailScreen
import com.example.workoutapp.ui.screens.WorkoutListScreen
import com.example.workoutapp.ui.screens.TimerScreen

sealed class Route(val route: String) {
    data object Workouts : Route("workouts")
    data object WorkoutDetail : Route("workout_detail/{id}")
    data object Timer : Route("timer/{id}")
}

@Composable
fun AppNavHost(navController: NavHostController) {
    NavHost(navController = navController, startDestination = Route.Workouts.route) {
        composable(Route.Workouts.route) {
            WorkoutListScreen(
                onOpenWorkout = { id -> navController.navigate("workout_detail/$id") },
                onStartTimer = { id -> navController.navigate("timer/$id") }
            )
        }
        composable(
            route = Route.WorkoutDetail.route,
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStackEntry ->
            val id = backStackEntry.arguments?.getString("id") ?: return@composable
            WorkoutDetailScreen(
                workoutId = id,
                onStartTimer = { wid -> navController.navigate("timer/$wid") },
                onBack = { navController.popBackStack() }
            )
        }
        composable(
            route = Route.Timer.route,
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStackEntry ->
            val id = backStackEntry.arguments?.getString("id") ?: return@composable
            TimerScreen(workoutId = id, onBack = { navController.popBackStack() })
        }
    }
}
