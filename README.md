# flutty_state

[![pub package](https://img.shields.io/pub/v/flutty_state.svg)](https://pub.dev/packages/flutty_state)
[![pub points](https://img.shields.io/pub/points/flutty_state)](https://pub.dev/packages/flutty_state/score)
[![likes](https://img.shields.io/pub/likes/flutty_state)](https://pub.dev/packages/flutty_state/score)

Lightweight and reactive state management utilities for Flutter.

The main value of this package is the set of **ready-to-use pages** that help you build common app flows quickly:

- **`FetchAndSubmitPage`**: fetch initial data, display it, and handle submission (with refresh + snackbars).
- **`SubmitPage`**: handle form submission lifecycle (loading, success, error) with a clean layout.
- **`StaticPage`**: a simple scrollable page layout with safe area + padding.

## Installation

```yaml
dependencies:
  flutty_state: ^0.1.1
```

## Usage

## Quick start

Import:

```dart
import 'package:flutty_state/flutty_state.dart';
```

### StaticPage

```dart
StaticPage(
  appBar: AppBar(title: const Text('About')),
  child: const Text('Hello world'),
);
```

### SubmitPage

```dart
SubmitPage(
  appBarBuilder: (_, __, ___) => AppBar(title: const Text('Submit')),
  childBuilder: (submitCubit, context) {
    return FilledButton(
      onPressed: () => submitCubit.submit(
        dataSubmitter: () async => DataSubmitSucceedEmpty(message: 'Saved'),
      ),
      child: const Text('Submit'),
    );
  },
);
```

### FetchAndSubmitPage

```dart
FetchAndSubmitPage<int>(
  appBarBuilder: (data, _, __) => AppBar(title: const Text('Fetch & Submit')),
  dataFetcher: () async => DataFetchSucceed(data: 1),
  builder: (data, submitCubit, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fetched value: $data'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => submitCubit.submitAndFetch(
            dataSubmitter: () async => DataSubmitSucceedEmpty(message: 'OK'),
          ),
          child: const Text('Submit + refresh'),
        ),
      ],
    );
  },
);
```

## Example

See `packages/flutty_state/example` for a complete demo app showcasing the 3 pages.

## API Documentation

See the [API docs](https://pub.dev/documentation/flutty_state/latest/) for full documentation.
