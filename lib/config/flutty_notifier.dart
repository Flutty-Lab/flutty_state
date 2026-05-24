import 'package:flutter/foundation.dart';

/// A simple reactive state holder.
class FluttyNotifier<T> extends ValueNotifier<T> {
  /// Creates a [FluttyNotifier] with the given initial value.
  FluttyNotifier(super.value);

  /// Updates the state value.
  void update(T newValue) {
    value = newValue;
  }

  /// Updates the state using a modifier function.
  void modify(T Function(T current) modifier) {
    value = modifier(value);
  }
}
