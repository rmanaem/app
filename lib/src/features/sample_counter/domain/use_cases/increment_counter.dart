/// Use case responsible for incrementing the counter value.
class IncrementCounter {
  /// Returns the next counter value after performing async work.
  Future<int> call(int current) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return current + 1;
  }
}
