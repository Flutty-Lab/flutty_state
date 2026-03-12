import 'package:flutter/widgets.dart';

import 'flutty_notifier.dart';

typedef FluttyValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
);

class FluttyBuilder<T> extends StatelessWidget {
  const FluttyBuilder({
    required this.notifier,
    required this.builder,
    super.key,
  });

  final FluttyNotifier<T> notifier;
  final FluttyValueWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, value, _) => builder(context, value),
    );
  }
}
