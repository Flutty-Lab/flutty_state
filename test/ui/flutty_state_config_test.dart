import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/data/data_submit_response.dart';
import 'package:flutty_state/config/flutty_state_config.dart';
import 'package:flutty_state/ui/fetch_and_submit_page.dart';
import 'package:flutty_state/ui/submit_page.dart';

class _Boom implements Exception {
  const _Boom();
  @override
  String toString() => 'Boom';
}

void main() {
  group('FluttyStateConfig.maybeOf', () {
    testWidgets('returns null when no config is in the tree', (tester) async {
      FluttyStateConfig? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = FluttyStateConfig.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('returns the nearest ancestor config', (tester) async {
      late FluttyStateConfig captured;
      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultFetchLoader: const Text('config-loader'),
            child: Builder(
              builder: (context) {
                captured = FluttyStateConfig.maybeOf(context)!;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured.defaultFetchLoader, isNotNull);
    });
  });

  group('FetchAndSubmitPage with FluttyStateConfig', () {
    testWidgets('uses fetchLoaderBuilder from config while fetching',
        (tester) async {
      final completer = Completer<DataFetchingResponse<int>>();

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultFetchLoader: const Text('custom-loader'),
            child: FetchAndSubmitPage<int>(
              dataFetcher: () => completer.future,
              builder: (data, _, __) => Text('value: $data'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('custom-loader'), findsOneWidget);

      completer.complete(DataFetchSucceed(data: 1));
      await tester.pumpAndSettle();
      expect(find.text('value: 1'), findsOneWidget);
    });

    testWidgets('instance loader takes precedence over config', (tester) async {
      final completer = Completer<DataFetchingResponse<int>>();

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultFetchLoader: const Text('config-loader'),
            child: FetchAndSubmitPage<int>(
              fetchLoader: const Text('instance-loader'),
              dataFetcher: () => completer.future,
              builder: (data, _, __) => Text('value: $data'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('instance-loader'), findsOneWidget);
      expect(find.text('config-loader'), findsNothing);

      completer.complete(DataFetchSucceed(data: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('falls back to default loader without config', (tester) async {
      final completer = Completer<DataFetchingResponse<int>>();

      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<int>(
            dataFetcher: () => completer.future,
            builder: (data, _, __) => Text('value: $data'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);

      completer.complete(DataFetchSucceed(data: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('invokes config.onFetchError when fetch fails', (tester) async {
      const error = _Boom();
      String? capturedMessage;
      Object? capturedException;

      Future<DataFetchingResponse<int>> fetchData() async =>
          DataFetchFailed(message: 'fetch boom', exception: error);

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultOnFetchError: (message, exception) {
              capturedMessage = message;
              capturedException = exception;
            },
            child: FetchAndSubmitPage<int>(
              dataFetcher: fetchData,
              builder: (data, _, __) => Text('value: $data'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedMessage, 'fetch boom');
      expect(capturedException, same(error));
    });

    testWidgets('page-level onFetchError takes precedence over config',
        (tester) async {
      String? configMessage;
      String? pageMessage;

      Future<DataFetchingResponse<int>> fetchData() async =>
          DataFetchFailed(message: 'fetch boom');

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultOnFetchError: (message, _) => configMessage = message,
            child: FetchAndSubmitPage<int>(
              onFetchError: (message, _) => pageMessage = message,
              dataFetcher: fetchData,
              builder: (data, _, __) => Text('value: $data'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(pageMessage, 'fetch boom');
      expect(configMessage, isNull);
    });

    testWidgets('invokes config.onSubmitError when submit fails',
        (tester) async {
      String? captured;
      Future<DataFetchingResponse<int>> fetchData() async =>
          DataFetchSucceed(data: 0);
      Future<DataSubmitResponse<void>> submitFailed() async =>
          DataSubmitFailed<void>(message: 'submit boom');

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultOnSubmitError: (message, _) => captured = message,
            child: FetchAndSubmitPage<int>(
              dataFetcher: fetchData,
              builder: (data, submitter, _) => GestureDetector(
                onTap: () => submitter.submit(dataSubmitter: submitFailed),
                child: const Text('press'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('press'));
      await tester.pumpAndSettle();

      expect(captured, 'submit boom');
    });
  });

  group('SubmitPage with FluttyStateConfig', () {
    testWidgets('invokes config.onSubmitError when submit fails',
        (tester) async {
      String? captured;
      Future<DataSubmitResponse<void>> submitFailed() async =>
          DataSubmitFailed<void>(message: 'submit boom');

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultOnSubmitError: (message, _) => captured = message,
            child: SubmitPage(
              builder: (submitter, _) => GestureDetector(
                onTap: () => submitter.submit(dataSubmitter: submitFailed),
                child: const Text('press'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('press'));
      await tester.pumpAndSettle();

      expect(captured, 'submit boom');
    });

    testWidgets('page-level onSubmitError takes precedence over config',
        (tester) async {
      String? configCalls;
      String? pageCalls;
      Future<DataSubmitResponse<void>> submitFailed() async =>
          DataSubmitFailed<void>(message: 'submit boom');

      await tester.pumpWidget(
        MaterialApp(
          home: FluttyStateConfig(
            defaultOnSubmitError: (message, _) => configCalls = message,
            child: SubmitPage(
              onSubmitError: (message, _) => pageCalls = message,
              builder: (submitter, _) => GestureDetector(
                onTap: () => submitter.submit(dataSubmitter: submitFailed),
                child: const Text('press'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('press'));
      await tester.pumpAndSettle();

      expect(pageCalls, 'submit boom');
      expect(configCalls, isNull);
    });
  });

  group('FluttyStateConfig constructor', () {
    test('requires child or appBuilder', () {
      expect(
        () => FluttyStateConfig(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects both child and appBuilder', () {
      expect(
        () => FluttyStateConfig(
          child: const SizedBox.shrink(),
          appBuilder: (_, __) => const SizedBox.shrink(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
