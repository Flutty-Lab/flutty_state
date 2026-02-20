import 'package:flutter/material.dart';

import 'flutty_notifier.dart';

/// A widget that rebuilds when a [FluttyNotifier] changes.
class FluttyBuilder<T> extends StatelessWidget {
  /// Creates a [FluttyBuilder].
  const FluttyBuilder({
    super.key,
    required this.notifier,
    required this.builder,
  });

  /// The notifier to listen to.
  final FluttyNotifier<T> notifier;

  /// Builder function called with the current value.
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, value, _) => builder(context, value),
    );
  }
}
