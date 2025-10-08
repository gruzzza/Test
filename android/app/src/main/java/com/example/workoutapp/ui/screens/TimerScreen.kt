package com.example.workoutapp.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.workoutapp.viewmodel.TimerViewModel
import com.example.workoutapp.viewmodel.WorkoutsViewModel

@Composable
fun TimerScreen(
    workoutId: String,
    onBack: () -> Unit,
    vm: TimerViewModel = viewModel()
) {
    val state by vm.state.collectAsStateWithLifecycle()

    val workoutsVm: WorkoutsViewModel = viewModel()
    if (workoutsVm.selectedWorkout.value?.id != workoutId) {
        workoutsVm.select(workoutId)
    }
    val workout by workoutsVm.selectedWorkout.collectAsStateWithLifecycle()
    val item = workout
    LaunchedEffect(item?.id) {
        item?.let {
            vm.reset()
            vm.startWorkout(it.rounds, it.workMs, it.restMs)
        }
    }
    Column(
        modifier = androidx.compose.ui.Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center
    ) {
        Text(text = state.phaseLabel, style = MaterialTheme.typography.headlineLarge)
        Text(text = state.remainingDisplay, style = MaterialTheme.typography.displaySmall)
        Text(text = "Раунд: ${state.currentRound}/${state.totalRounds}")
        Button(onClick = { vm.toggle() }) { Text(if (state.isRunning) "Пауза" else "Старт") }
        Button(onClick = { vm.reset() }) { Text("Сброс") }
    }
}
