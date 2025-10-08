package com.example.workoutapp.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.workoutapp.viewmodel.WorkoutsViewModel

@Composable
fun WorkoutDetailScreen(
    workoutId: String,
    onStartTimer: (String) -> Unit,
    onBack: () -> Unit,
    vm: WorkoutsViewModel = viewModel()
) {
    if (vm.selectedWorkout.value?.id != workoutId) {
        vm.select(workoutId)
    }
    val workout by vm.selectedWorkout.collectAsStateWithLifecycle()
    val item = workout ?: return
    Column(Modifier.fillMaxSize()) {
        Text(item.name, style = MaterialTheme.typography.headlineMedium)
        Text("Подходы: ${item.rounds}")
        Text("Интервал: ${item.workMs/1000}s / отдых: ${item.restMs/1000}s")
        Button(onClick = { onStartTimer(item.id) }) { Text("Начать") }
    }
}
