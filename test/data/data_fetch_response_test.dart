import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_fetch_response.dart';

void main() {
  group('DataFetchingResponse', () {
    test('DataFetchSucceed should store data', () {
      const testData = 'test data';
      final response = DataFetchSucceed<String>(data: testData);

      expect(response.data, testData);
      expect(response, isA<DataFetchingResponse<String>>());
    });

    test('DataFetchSucceed should work with different types', () {
      final intResponse = DataFetchSucceed<int>(data: 42);
      expect(intResponse.data, 42);

      final listResponse = DataFetchSucceed<List<String>>(data: ['a', 'b']);
      expect(listResponse.data, ['a', 'b']);
    });

    test('DataFetchFailed should store message and exception', () {
      const message = 'Failed to fetch';
      final exception = Exception('Network error');
      final response = DataFetchFailed<String>(
        message: message,
        exception: exception,
      );

      expect(response.message, message);
      expect(response.exception, exception);
      expect(response, isA<DataFetchingResponse<String>>());
    });

    test('DataFetchFailed should work without exception', () {
      const message = 'Failed to fetch';
      final response = DataFetchFailed<String>(message: message);

      expect(response.message, message);
      expect(response.exception, isNull);
    });

    test('DataFetchingResponse should be sealed', () {
      final succeed = DataFetchSucceed<int>(data: 1);
      final failed = DataFetchFailed<int>(message: 'error');

      expect(succeed, isA<DataFetchingResponse<int>>());
      expect(failed, isA<DataFetchingResponse<int>>());
    });

    test('should support pattern matching', () {
      final DataFetchingResponse<String> response =
          DataFetchSucceed<String>(data: 'success');

      final result = switch (response) {
        DataFetchSucceed(:final data) => 'Got: $data',
        DataFetchFailed(:final message) => 'Error: $message',
      };

      expect(result, 'Got: success');
    });

    test('should support pattern matching for failed case', () {
      final DataFetchingResponse<String> response =
          DataFetchFailed<String>(message: 'network error');

      final result = switch (response) {
        DataFetchSucceed(:final data) => 'Got: $data',
        DataFetchFailed(:final message) => 'Error: $message',
      };

      expect(result, 'Error: network error');
    });
  });
}
