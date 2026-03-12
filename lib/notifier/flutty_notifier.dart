import 'package:flutter/foundation.dart';

class FluttyNotifier<T> extends ValueNotifier<T> {
  FluttyNotifier(super.value);

  void update(T value) => this.value = value;

  void modify(T Function(T current) modifier) => value = modifier(value);
}
