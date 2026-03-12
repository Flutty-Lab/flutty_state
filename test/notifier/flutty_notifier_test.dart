import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/notifier/flutty_notifier.dart';

void main() {
  group('FluttyNotifier', () {
    test('should create instance with initial value', () {
      final notifier = FluttyNotifier<int>(0);
      expect(notifier.value, 0);
    });

    test('update should change the value', () {
      final notifier = FluttyNotifier<int>(0);
      notifier.update(5);
      expect(notifier.value, 5);
    });

    test('update should notify listeners', () {
      final notifier = FluttyNotifier<int>(0);
      var listenerCalled = false;

      notifier.addListener(() {
        listenerCalled = true;
      });

      notifier.update(10);
      expect(listenerCalled, isTrue);
    });

    test('modify should apply transformation to current value', () {
      final notifier = FluttyNotifier<int>(5);
      notifier.modify((current) => current * 2);
      expect(notifier.value, 10);
    });

    test('modify should notify listeners', () {
      final notifier = FluttyNotifier<int>(5);
      var listenerCalled = false;

      notifier.addListener(() {
        listenerCalled = true;
      });

      notifier.modify((current) => current + 1);
      expect(listenerCalled, isTrue);
    });

    test('modify should receive current value', () {
      final notifier = FluttyNotifier<String>('hello');
      notifier.modify((current) => '$current world');
      expect(notifier.value, 'hello world');
    });

    test('should work with complex types', () {
      final notifier = FluttyNotifier<List<int>>([1, 2, 3]);
      notifier.modify((current) => [...current, 4]);
      expect(notifier.value, [1, 2, 3, 4]);
    });

    test('should work with nullable types', () {
      final notifier = FluttyNotifier<int?>(null);
      expect(notifier.value, isNull);

      notifier.update(42);
      expect(notifier.value, 42);

      notifier.update(null);
      expect(notifier.value, isNull);
    });

    test('should dispose properly', () {
      final notifier = FluttyNotifier<int>(0);

      notifier.addListener(() {});

      notifier.dispose();

      expect(() => notifier.update(5), throwsFlutterError);
    });
  });
}
