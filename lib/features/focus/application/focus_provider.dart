import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusMode { pomodoro, stopwatch }

class FocusTimerState {
  const FocusTimerState({
    required this.mode,
    required this.remaining,
    required this.elapsed,
    required this.running,
  });

  final FocusMode mode;
  final Duration remaining;
  final Duration elapsed;
  final bool running;

  static const pomodoroDuration = Duration(minutes: 25);

  FocusTimerState copyWith({
    FocusMode? mode,
    Duration? remaining,
    Duration? elapsed,
    bool? running,
  }) {
    return FocusTimerState(
      mode: mode ?? this.mode,
      remaining: remaining ?? this.remaining,
      elapsed: elapsed ?? this.elapsed,
      running: running ?? this.running,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  FocusTimerNotifier()
      : super(const FocusTimerState(
          mode: FocusMode.pomodoro,
          remaining: FocusTimerState.pomodoroDuration,
          elapsed: Duration.zero,
          running: false,
        ));

  Timer? _timer;

  void setMode(FocusMode mode) {
    _timer?.cancel();
    state = FocusTimerState(
      mode: mode,
      remaining: FocusTimerState.pomodoroDuration,
      elapsed: Duration.zero,
      running: false,
    );
  }

  void toggle() {
    if (state.running) {
      _timer?.cancel();
      state = state.copyWith(running: false);
      return;
    }
    state = state.copyWith(running: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.mode == FocusMode.pomodoro) {
        final next = state.remaining - const Duration(seconds: 1);
        if (next <= Duration.zero) {
          _timer?.cancel();
          state = state.copyWith(remaining: Duration.zero, running: false);
        } else {
          state = state.copyWith(remaining: next);
        }
      } else {
        state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier();
});
