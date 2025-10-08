package com.example.workoutapp.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

private enum class Phase { Idle, Work, Rest, Done }

data class TimerState(
    val isRunning: Boolean = false,
    val phase: Phase = Phase.Idle,
    val phaseLabel: String = "Готовы?",
    val remainingMs: Long = 0,
    val remainingDisplay: String = "00:00",
    val currentRound: Int = 0,
    val totalRounds: Int = 0,
    val workMs: Long = 0,
    val restMs: Long = 0
)

class TimerViewModel : ViewModel() {
    private val _state = MutableStateFlow(TimerState())
    val state: StateFlow<TimerState> = _state

    private var job: Job? = null

    fun startWorkout(rounds: Int, workMs: Long, restMs: Long) {
        if (job != null) return
        _state.value = TimerState(
            isRunning = true,
            phase = Phase.Work,
            phaseLabel = "Работа",
            remainingMs = workMs,
            remainingDisplay = format(workMs),
            currentRound = 1,
            totalRounds = rounds,
            workMs = workMs,
            restMs = restMs
        )
        job = viewModelScope.launch { runLoop() }
    }

    fun toggle() {
        if (_state.value.isRunning) {
            pause()
        } else {
            resume()
        }
    }

    fun pause() {
        job?.cancel()
        job = null
        _state.value = _state.value.copy(isRunning = false)
    }

    fun reset() {
        pause()
        _state.value = TimerState()
    }

    private fun format(ms: Long): String {
        val totalSeconds = (ms / 1000).toInt()
        val m = totalSeconds / 60
        val s = totalSeconds % 60
        return "%02d:%02d".format(m, s)
    }

    private suspend fun tickDownWhileRunning() {
        var remaining = _state.value.remainingMs
        while (remaining > 0 && _state.value.isRunning) {
            delay(1000)
            remaining -= 1000
            _state.value = _state.value.copy(remainingMs = remaining, remainingDisplay = format(remaining))
        }
    }

    private fun resume() {
        if (job != null) return
        _state.value = _state.value.copy(isRunning = true)
        job = viewModelScope.launch { runLoop() }
    }

    private suspend fun runLoop() {
        while (_state.value.isRunning) {
            when (_state.value.phase) {
                Phase.Work -> {
                    tickDownWhileRunning()
                    if (!_state.value.isRunning) break
                    if (_state.value.currentRound >= _state.value.totalRounds) {
                        _state.value = _state.value.copy(
                            isRunning = false,
                            phase = Phase.Done,
                            phaseLabel = "Готово",
                            remainingMs = 0,
                            remainingDisplay = "00:00"
                        )
                        break
                    } else if (_state.value.restMs > 0) {
                        _state.value = _state.value.copy(
                            phase = Phase.Rest,
                            phaseLabel = "Отдых",
                            remainingMs = _state.value.restMs,
                            remainingDisplay = format(_state.value.restMs)
                        )
                    } else {
                        val nextRound = _state.value.currentRound + 1
                        _state.value = _state.value.copy(
                            phase = Phase.Work,
                            phaseLabel = "Работа",
                            currentRound = nextRound,
                            remainingMs = _state.value.workMs,
                            remainingDisplay = format(_state.value.workMs)
                        )
                    }
                }
                Phase.Rest -> {
                    tickDownWhileRunning()
                    if (!_state.value.isRunning) break
                    val nextRound = _state.value.currentRound + 1
                    _state.value = _state.value.copy(
                        phase = Phase.Work,
                        phaseLabel = "Работа",
                        currentRound = nextRound,
                        remainingMs = _state.value.workMs,
                        remainingDisplay = format(_state.value.workMs)
                    )
                }
                Phase.Done, Phase.Idle -> break
            }
        }
        job = null
    }
}
