import 'package:flutter/foundation.dart';

/// Times an async operation and logs: PERF | <label> | <n> ms
Future<T> timeAsync<T>(String label, Future<T> Function() action) async {
  final stopwatch = Stopwatch()..start();
  try {
    return await action();
  } finally {
    stopwatch.stop();
    debugPrint('PERF | $label | ${stopwatch.elapsedMilliseconds} ms');
  }
}

/// Times a synchronous operation and logs: PERF | <label> | <n> ms
T timeSync<T>(String label, T Function() action) {
  final stopwatch = Stopwatch()..start();
  try {
    return action();
  } finally {
    stopwatch.stop();
    debugPrint('PERF | $label | ${stopwatch.elapsedMilliseconds} ms');
  }
}
