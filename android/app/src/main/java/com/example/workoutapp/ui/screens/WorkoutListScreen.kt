package com.example.workoutapp.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.clickable
import androidx.compose.material3.Card
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.workoutapp.viewmodel.WorkoutsViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle

@Composable
fun WorkoutListScreen(
    onOpenWorkout: (String) -> Unit,
    onStartTimer: (String) -> Unit,
    vm: WorkoutsViewModel = viewModel()
) {
    val workouts by vm.workouts.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize()) {
        Text(
            text = "Тренировки",
            style = MaterialTheme.typography.headlineMedium
        )
        LazyColumn {
            items(workouts) { workout ->
                Card {
                    ListItem(
                        modifier = Modifier.clickable { onOpenWorkout(workout.id) },
                        headlineContent = { Text(workout.name) },
                        supportingContent = { Text("Подходы: ${workout.rounds}") },
                        trailingContent = {
                            OutlinedButton(onClick = { onStartTimer(workout.id) }) {
                                Text("Старт")
                            }
                        }
                    )
                }
            }
        }
    }
}
