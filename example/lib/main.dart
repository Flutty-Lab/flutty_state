import 'package:flutter/material.dart';
import 'package:flutty_state/flutty_state.dart';

void main() {
  runApp(const FluttyStateExample());
}

class FluttyStateExample extends StatelessWidget {
  const FluttyStateExample({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = FluttyNotifier<int>(0);

    return MaterialApp(
      title: 'Flutty State Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutty State')),
        body: Center(
          child: FluttyBuilder<int>(
            notifier: counter,
            builder: (context, value) => Text('Count: $value'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counter.modify((c) => c + 1),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
