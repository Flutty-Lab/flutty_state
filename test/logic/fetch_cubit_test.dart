import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';

void main() {
  group('FetchCubit error handling', () {
    test('fetch emits FetchFailed and invokes onFetchError on exception',
        () async {
      final captured = <Object>[];
      final cubit = FetchCubit<String>(
        onFetchError: (error, _) => captured.add(error),
      );
      final boom = Exception('boom');

      await cubit.fetch(dataFetcher: () async => throw boom);

      expect(cubit.state, isA<FetchFailed<String>>());
      final state = cubit.state as FetchFailed<String>;
      expect(state.failedMessage, 'Unexpected error');
      expect(state.exception, boom);
      expect(captured, [boom]);

      await cubit.close();
    });

    test('fetch propagates timeout exception and custom timeout message',
        () async {
      final captured = <Object>[];
      final cubit = FetchCubit<String>(
        timeoutMessage: 'Custom timeout',
        onFetchError: (error, _) => captured.add(error),
      );

      await cubit.fetch(
        dataFetcher: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return DataFetchSucceed(data: 'unreached');
        },
        timeout: const Duration(milliseconds: 1),
      );

      expect(cubit.state, isA<FetchFailed<String>>());
      final state = cubit.state as FetchFailed<String>;
      expect(state.failedMessage, 'Custom timeout');
      expect(state.exception, isA<TimeoutException>());
      expect(captured.single, isA<TimeoutException>());

      await cubit.close();
    });

    test('refresh propagates exception to RefreshFailed and onFetchError',
        () async {
      final captured = <Object>[];
      final cubit = FetchCubit<String>(
        onFetchError: (error, _) => captured.add(error),
      );
      final boom = StateError('refresh boom');

      await cubit.refresh(dataFetcher: () async => throw boom);

      expect(cubit.state, isA<RefreshFailed<String>>());
      final state = cubit.state as RefreshFailed<String>;
      expect(state.exception, boom);
      expect(captured, [boom]);

      await cubit.close();
    });

    test('onFetchError is optional', () async {
      final cubit = FetchCubit<String>();
      await cubit.fetch(dataFetcher: () async => throw Exception('boom'));
      expect(cubit.state, isA<FetchFailed<String>>());
      await cubit.close();
    });
  });
}
