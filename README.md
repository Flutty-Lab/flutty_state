# flutty_state

[![pub package](https://img.shields.io/pub/v/flutty_state.svg)](https://pub.dev/packages/flutty_state)
[![pub points](https://img.shields.io/pub/points/flutty_state)](https://pub.dev/packages/flutty_state/score)
[![likes](https://img.shields.io/pub/likes/flutty_state)](https://pub.dev/packages/flutty_state/score)

Lightweight and reactive state management solution for Flutter.

## Installation

```yaml
dependencies:
  flutty_state: ^0.1.0
```

## Usage

```dart
import 'package:flutty_state/flutty_state.dart';

// Create a notifier
final counter = FluttyNotifier<int>(0);

// Use in a widget
FluttyBuilder<int>(
  notifier: counter,
  builder: (context, value) => Text('Count: $value'),
);

// Update
counter.update(42);
counter.modify((current) => current + 1);
```

## API Documentation

See the [API docs](https://pub.dev/documentation/flutty_state/latest/) for full documentation.
