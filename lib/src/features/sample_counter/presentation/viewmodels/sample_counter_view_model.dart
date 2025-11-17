import 'package:flutter/foundation.dart';

import 'package:starter_app/src/features/sample_counter/domain/use_cases/increment_counter.dart';

/// ViewModel powering the sample counter feature.
class SampleCounterViewModel extends ChangeNotifier {
  /// Creates a ViewModel with the provided [incrementCounter] use case.
  SampleCounterViewModel(this.incrementCounter);

  /// Use case that determines the next counter value.
  final IncrementCounter incrementCounter;

  int _value = 0;
  bool _isBusy = false;

  /// Current counter value.
  int get value => _value;

  /// Indicates when business logic is running.
  bool get isBusy => _isBusy;

  /// Increments the counter via the use case and notifies listeners.
  Future<void> increment() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    _value = await incrementCounter(_value);
    _isBusy = false;
    notifyListeners();
  }
}
