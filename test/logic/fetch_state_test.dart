import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/logic/fetch_cubit.dart';

void main() {
  group('FetchState', () {
    test('FetchInitial should be a FetchState', () {
      final state = FetchInitial<String>();
      expect(state, isA<FetchState<String>>());
    });

    test('Fetching should be a FetchState', () {
      final state = Fetching<String>();
      expect(state, isA<FetchState<String>>());
    });

    test('FetchSucceed should store data', () {
      const data = 'test data';
      const state = FetchSucceed<String>(data: data);

      expect(state.data, data);
      expect(state, isA<FetchState<String>>());
    });

    test('FetchSucceed props should include data', () {
      const state1 = FetchSucceed<String>(data: 'test');
      const state2 = FetchSucceed<String>(data: 'test');
      const state3 = FetchSucceed<String>(data: 'different');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('FetchFailed should store message and exception', () {
      const message = 'Failed to fetch';
      final exception = Exception('Network error');
      final state = FetchFailed<String>(message, exception: exception);

      expect(state.failedMessage, message);
      expect(state.exception, exception);
      expect(state, isA<FetchState<String>>());
    });

    test('FetchFailed should work without exception', () {
      const message = 'Failed to fetch';
      const state = FetchFailed<String>(message);

      expect(state.failedMessage, message);
      expect(state.exception, isNull);
    });

    test('FetchFailed props should include message', () {
      const state1 = FetchFailed<String>('error');
      const state2 = FetchFailed<String>('error');
      const state3 = FetchFailed<String>('different error');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('RefreshState', () {
    test('RefreshState should extend FetchState', () {
      final state = RefreshFetching<String>();
      expect(state, isA<FetchState<String>>());
      expect(state, isA<RefreshState<String>>());
    });

    test('RefreshFetching should be a RefreshState', () {
      final state = RefreshFetching<String>();
      expect(state, isA<RefreshState<String>>());
    });

    test('RefreshFailed should store message and exception', () {
      const message = 'Failed to refresh';
      final exception = Exception('Network error');
      final state = RefreshFailed<String>(message, exception: exception);

      expect(state.failedMessage, message);
      expect(state.exception, exception);
      expect(state, isA<RefreshState<String>>());
    });

    test('RefreshFailed should work without exception', () {
      const message = 'Failed to refresh';
      const state = RefreshFailed<String>(message);

      expect(state.failedMessage, message);
      expect(state.exception, isNull);
    });

    test('RefreshFailed props should include message', () {
      const state1 = RefreshFailed<String>('error');
      const state2 = RefreshFailed<String>('error');
      const state3 = RefreshFailed<String>('different error');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
