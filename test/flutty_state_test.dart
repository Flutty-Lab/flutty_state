import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/flutty_state.dart';

void main() {
  test('FluttyNotifier updates value', () {
    final notifier = FluttyNotifier<int>(0);
    notifier.update(42);
    expect(notifier.value, 42);
  });

  test('FluttyNotifier modify transforms value', () {
    final notifier = FluttyNotifier<int>(10);
    notifier.modify((current) => current + 5);
    expect(notifier.value, 15);
  });
}
